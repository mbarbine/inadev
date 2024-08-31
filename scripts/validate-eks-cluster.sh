#!/bin/bash

# Set the AWS Region and Cluster Name
REGION=${1:-"us-east-2"}
CLUSTER_NAME=$(aws eks list-clusters --query 'clusters[0]' --output text --region "$REGION")

log() {
    echo "$1"
}

log "===== Validating EKS Cluster and Communication ====="

# 1. Validate EKS Cluster Status
log "Validating EKS Cluster status..."
CLUSTER_STATUS=$(aws eks describe-cluster --name "$CLUSTER_NAME" --query 'cluster.status' --output text --region "$REGION")

if [ "$CLUSTER_STATUS" == "ACTIVE" ]; then
    log "EKS Cluster '$CLUSTER_NAME' is ACTIVE."
else
    log "EKS Cluster '$CLUSTER_NAME' is not active. Status: $CLUSTER_STATUS"
    exit 1
fi

# 2. Validate EKS Node Health
log "Validating EKS Node status..."
EKS_NODES=$(kubectl get nodes --no-headers | awk '{print $1" "$2}')

if echo "$EKS_NODES" | grep -q "Ready"; then
    log "All EKS nodes are healthy and in Ready state."
else
    log "Some EKS nodes are not ready."
    echo "$EKS_NODES"
    exit 1
fi

# 3. Validate Security Groups for EKS, Jenkins, and ALB
log "Validating Security Groups for Ingress and Egress Rules..."

# Security Groups
CLUSTER_SECURITY_GROUP=$(aws eks describe-cluster --name "$CLUSTER_NAME" --query 'cluster.resourcesVpcConfig.clusterSecurityGroupId' --output text --region "$REGION")
JENKINS_SECURITY_GROUP=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=Jenkins" --query 'Reservations[0].Instances[0].SecurityGroups[0].GroupId' --output text --region "$REGION")
ALB_SECURITY_GROUP=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[0].SecurityGroups[0]' --output text --region "$REGION")

log "Cluster Security Group: $CLUSTER_SECURITY_GROUP"
log "Jenkins Security Group: $JENKINS_SECURITY_GROUP"
log "ALB Security Group: $ALB_SECURITY_GROUP"

# Validate Ingress and Egress Rules for EKS, Jenkins, and ALB
validate_security_group() {
    SG_ID=$1
    SG_INGRESS_RULES=$(aws ec2 describe-security-groups --group-ids "$SG_ID" --query 'SecurityGroups[0].IpPermissions' --output json --region "$REGION")
    SG_EGRESS_RULES=$(aws ec2 describe-security-groups --group-ids "$SG_ID" --query 'SecurityGroups[0].IpPermissionsEgress' --output json --region "$REGION")

    log "Ingress Rules for $SG_ID:\n$SG_INGRESS_RULES"
    log "Egress Rules for $SG_ID:\n$SG_EGRESS_RULES"

    if [ -z "$SG_INGRESS_RULES" ]; then
        log "No ingress rules found for security group $SG_ID."
        exit 1
    fi

    if [ -z "$SG_EGRESS_RULES" ]; then
        log "No egress rules found for security group $SG_ID."
        exit 1
    fi
}

validate_security_group "$CLUSTER_SECURITY_GROUP"
validate_security_group "$JENKINS_SECURITY_GROUP"
validate_security_group "$ALB_SECURITY_GROUP"

# 4. Validate IAM Roles and Policies
log "Validating IAM Roles and Policies..."

# Check Jenkins IAM Role
JENKINS_IAM_ROLE=$(aws ec2 describe-instances --instance-ids "$JENKINS_INSTANCE_ID" --query 'Reservations[0].Instances[0].IamInstanceProfile.Arn' --output text --region "$REGION")
log "Jenkins IAM Role: $JENKINS_IAM_ROLE"

# Validate Jenkins IAM Policies
JENKINS_IAM_ROLE_NAME=$(basename "$JENKINS_IAM_ROLE")
JENKINS_POLICIES=$(aws iam list-attached-role-policies --role-name "$JENKINS_IAM_ROLE_NAME" --query 'AttachedPolicies[*].PolicyName' --output text --region "$REGION")
log "Attached Policies for Jenkins IAM Role:\n$JENKINS_POLICIES"

# Check EKS Node IAM Role
EKS_NODE_ROLE=$(aws iam list-roles --query 'Roles[?RoleName!=null]|[?contains(RoleName, `eks-node-role`)].Arn' --output text --region "$REGION")
log "EKS Node IAM Role: $EKS_NODE_ROLE"

# 5. Validate SSL Certificates for ALB
log "Validating SSL certificates for ALB..."
ACM_CERT_ARN=$(aws acm list-certificates --query 'CertificateSummaryList[0].CertificateArn' --output text --region "$REGION")
SSL_STATUS=$(aws acm describe-certificate --certificate-arn "$ACM_CERT_ARN" --query 'Certificate.Status' --output text --region "$REGION")

if [ "$SSL_STATUS" == "ISSUED" ]; then
    log "SSL certificate is valid and issued."
else
    log "SSL certificate is not valid. Status: $SSL_STATUS"
    exit 1
fi

# 6. Validate Jenkins and Next.js Health
log "Performing Health Check for Jenkins..."
JENKINS_HEALTH_CHECK=$(curl -s -o /dev/null -w "%{http_code}" "http://$JENKINS_PUBLIC_IP:8080/login")
log "Jenkins Health Check HTTP Status: $JENKINS_HEALTH_CHECK"

log "Performing Health Check for Next.js Application..."
NEXTJS_HEALTH_CHECK=$(curl -s -o /dev/null -w "%{http_code}" "https://inadev.cheeseusfries.com")
log "Next.js Health Check HTTP Status: $NEXTJS_HEALTH_CHECK"

# 7. Validate CloudWatch Log Presence
log "Validating CloudWatch Logs..."

# Check if EKS logs are being sent to CloudWatch
EKS_LOG_GROUP=$(aws logs describe-log-groups --log-group-name-prefix "/aws/eks" --query 'logGroups[0].logGroupName' --output text --region "$REGION")
if [ -n "$EKS_LOG_GROUP" ]; then
    log "EKS logs are present in CloudWatch: $EKS_LOG_GROUP"
else
    log "No EKS logs found in CloudWatch."
    exit 1
fi

# Check if Jenkins logs are being sent to CloudWatch
JENKINS_LOG_GROUP=$(aws logs describe-log-groups --log-group-name-prefix "/aws/ec2/Jenkins" --query 'logGroups[0].logGroupName' --output text --region "$REGION")
if [ -n "$JENKINS_LOG_GROUP" ]; then
    log "Jenkins logs are present in CloudWatch: $JENKINS_LOG_GROUP"
else
    log "No Jenkins logs found in CloudWatch."
    exit 1
fi

log "===== EKS Cluster and Orbiting System Validation Complete ====="
#!/bin/bash

# Set AWS Region and verbosity level
REGION=${1:-"us-east-2"}
VERBOSE=true

log() {
    if [ "$VERBOSE" = true ]; then
        echo "$1"
    fi
}

log "===== Testing Infrastructure in Region: $REGION ====="

# 1. Check VPC and Subnets
log "Checking VPC and Subnets..."
VPC_ID=$(aws ec2 describe-vpcs --query 'Vpcs[?IsDefault==`true`].VpcId' --output text --region "$REGION")
SUBNET_IDS=$(aws ec2 describe-subnets --query 'Subnets[?VpcId==`'"$VPC_ID"'`].SubnetId' --output text --region "$REGION")

log "VPC ID: $VPC_ID"
log "Subnets: $SUBNET_IDS"

# 2. Check EKS Cluster and Nodes
log "Checking EKS Cluster..."
CLUSTER_NAME=$(aws eks list-clusters --query 'clusters[0]' --output text --region "$REGION")
EKS_NODES=$(kubectl get nodes)

log "EKS Cluster: $CLUSTER_NAME"
log "EKS Nodes:\n$EKS_NODES"

# 3. Check Jenkins EC2 Instance
log "Checking Jenkins EC2 Instance..."
JENKINS_INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=Jenkins" --query 'Reservations[*].Instances[*].InstanceId' --output text --region "$REGION")
JENKINS_PUBLIC_IP=$(aws ec2 describe-instances --instance-ids "$JENKINS_INSTANCE_ID" --query 'Reservations[*].Instances[*].PublicIpAddress' --output text --region "$REGION")

log "Jenkins EC2 Instance ID: $JENKINS_INSTANCE_ID"
log "Jenkins Public IP: $JENKINS_PUBLIC_IP"

# 4. Check ALB and Listener Rules
log "Checking ALB and Listener Rules..."
ALB_ARN=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[0].LoadBalancerArn' --output text --region "$REGION")
ALB_DNS_NAME=$(aws elbv2 describe-load-balancers --query 'LoadBalancers[0].DNSName' --output text --region "$REGION")
ALB_LISTENERS=$(aws elbv2 describe-listeners --load-balancer-arn "$ALB_ARN" --query 'Listeners[*].ListenerArn' --output text --region "$REGION")

log "ALB ARN: $ALB_ARN"
log "ALB DNS Name: $ALB_DNS_NAME"
log "ALB Listeners: $ALB_LISTENERS"

# 5. Check Route 53 DNS Records
log "Checking Route 53 DNS Records..."
ROUTE53_RECORDS=$(aws route53 list-resource-record-sets --query 'ResourceRecordSets[*].[Name,Type]' --output text --region "$REGION")

log "Route 53 DNS Records:\n$ROUTE53_RECORDS"

# 6. Check SSL Certificates in ACM
log "Checking SSL Certificates in ACM..."
ACM_CERTS=$(aws acm list-certificates --query 'CertificateSummaryList[*].[DomainName,CertificateArn]' --output text --region "$REGION")

log "ACM Certificates:\n$ACM_CERTS"

# 7. Check S3 Buckets
log "Checking S3 Buckets..."
S3_BUCKETS=$(aws s3api list-buckets --query 'Buckets[*].Name' --output text --region "$REGION")

log "S3 Buckets:\n$S3_BUCKETS"

# 8. Check CloudWatch Logs and Alarms
log "Checking CloudWatch Logs and Alarms..."
CLOUDWATCH_LOG_GROUPS=$(aws logs describe-log-groups --query 'logGroups[*].logGroupName' --output text --region "$REGION")
CLOUDWATCH_ALARMS=$(aws cloudwatch describe-alarms --query 'MetricAlarms[*].[AlarmName,StateValue]' --output text --region "$REGION")

log "CloudWatch Log Groups:\n$CLOUDWATCH_LOG_GROUPS"
log "CloudWatch Alarms:\n$CLOUDWATCH_ALARMS"

# 9. Check IAM Roles and Policies
log "Checking IAM Roles and Policies..."
IAM_ROLES=$(aws iam list-roles --query 'Roles[*].RoleName' --output text)
IAM_POLICIES=$(aws iam list-policies --query 'Policies[*].PolicyName' --output text)

log "IAM Roles:\n$IAM_ROLES"
log "IAM Policies:\n$IAM_POLICIES"

# 10. Perform Health Checks for Jenkins and Next.js
log "Performing Health Check for Jenkins..."
JENKINS_HEALTH_CHECK=$(curl -s -o /dev/null -w "%{http_code}" "http://$JENKINS_PUBLIC_IP:8080/login")
log "Jenkins Health Check HTTP Status: $JENKINS_HEALTH_CHECK"

log "Performing Health Check for Next.js Application..."
NEXTJS_HEALTH_CHECK=$(curl -s -o /dev/null -w "%{http_code}" "https://inadev.cheeseusfries.com")
log "Next.js Health Check HTTP Status: $NEXTJS_HEALTH_CHECK"

log "===== Infrastructure Testing Complete ====="
