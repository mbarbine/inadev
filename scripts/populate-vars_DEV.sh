#!/bin/bash

# Set the AWS Region
REGION=${1:-"us-east-2"}
CLUSTER_NAME="weather-lama-eks-cluster"
DOMAIN_NAME_1="inadev.cheeseusfries.com"
DOMAIN_NAME_2="jenkins.cheeseusfries.com"
DOMAIN_NAME_DEV="localhost"
SCRIPTS_DIR="scripts"
TERRAFORM_DIR="terraform/us-east-2"
ECR_REPOSITORY = 'nextjs-app-repo'
CLUSTER_NAME = 'my-eks-cluster'
EKS_NAMESPACE = 'default'
ECR_REPO_URI = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPOSITORY}"
JENKINS_ADMIN_USER="admin"
JENKINS_ADMIN_PASSWORD="adminpassword"
JENKINS_IMAGE = "${ECR_REPO_URI}:jenkins"
JENKINS_PORT = 8080
JENKINS_VOLUME = 'jenkins-home'
JENKINS_VOLUME_SIZE = 20
JENKINS_BACKUP_BUCKET = 'jenkins-backups'
JENKINS_BACKUP_LIFECYCLE = 30
JENKINS_BACKUP_SCHEDULE = 'cron(0 0 * * *)'
JENKINS_BACKUP_RETENTION = 7
JENKINS_BACKUP_IMAGE = "${ECR_REPO_URI}:jenkins-backup"
JENKINS_BACKUP_PORT = 8080
JENKINS_BACKUP_VOLUME = 'jenkins-backup'
JENKINS_BACKUP_VOLUME_SIZE = 20
INFRA_DIR="infra/us-east-2"
VARS_DIR="infra/us-east-2/vars"
vpc_id = "$VPC_ID"
subnet_1_id = "$SUBNET_1"
subnet_2_id = "$SUBNET_2"
availability_zone_1 = "$AZ_1"
availability_zone_2 = "$AZ_2"
nat_gateway_id = "$NAT_GATEWAY_ID"
ecr_repo_uri = "$ECR_REPO_URI"
s3_bucket_name = "$S3_BUCKET"
alb_dns_name = "$ALB_DNS_NAME"
jenkins_iam_role_arn = "$JENKINS_ROLE_ARN"
eks_iam_role_arn = "$EKS_ROLE_ARN"
ALB_DNS_NAME=""
DOMAIN_NAME="cheeseusfries.com"
HOSTED_ZONE_ID="Z35SXDOTRQ7X7K"

# Determine the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VARS_DIR="$SCRIPT_DIR/../infra/us-east-2/vars"

# Ensure the vars directory exists
mkdir -p "$VARS_DIR"

# Functions to query AWS resources
get_vpc_id() {
  echo "Fetching VPC ID..."
  aws ec2 describe-vpcs \
    --query 'Vpcs[?IsDefault==`true`].VpcId' \
    --output text \
    --region $REGION
}

get_subnet_ids() {
  echo "Fetching Subnet IDs..."
  aws ec2 describe-subnets \
    --query 'Subnets[?MapPublicIpOnLaunch==`true`].SubnetId' \
    --output text \
    --region $REGION
}

get_availability_zones() {
  echo "Fetching Availability Zones..."
  aws ec2 describe-availability-zones \
    --query 'AvailabilityZones[?State==`available`].ZoneName' \
    --output text \
    --region $REGION
}

get_nat_gateway_id() {
  echo "Fetching NAT Gateway ID..."
  aws ec2 describe-nat-gateways \
    --query 'NatGateways[?State==`available`].NatGatewayId' \
    --output text \
    --region $REGION
}

get_ecr_repository_uri() {
  echo "Fetching ECR Repository URI..."
  aws ecr describe-repositories \
    --query 'repositories[?repositoryName==`nextjs-app-repo`].repositoryUri' \
    --output text \
    --region $REGION
}

get_s3_bucket_name() {
  echo "Fetching S3 Bucket for Jenkins backups..."
  aws s3api list-buckets --query 'Buckets[?contains(Name, `jenkins-backups`) == `true`].Name' --output text
}

get_alb_dns_name() {
  echo "Fetching ALB DNS Name..."
  aws elbv2 describe-load-balancers \
    --query 'LoadBalancers[?State.Code==`active`].DNSName' \
    --output text \
    --region $REGION
}

get_iam_role_arn() {
  echo "Fetching IAM Role ARN for $1..."
  aws iam list-roles \
    --query "Roles[?RoleName=='$1'].Arn" \
    --output text
}

# Fetching values
VPC_ID=$(get_vpc_id)
SUBNET_IDS=$(get_subnet_ids)
AVAILABILITY_ZONES=$(get_availability_zones)
NAT_GATEWAY_ID=$(get_nat_gateway_id)
ECR_REPO_URI=$(get_ecr_repository_uri)
S3_BUCKET=$(get_s3_bucket_name)
ALB_DNS_NAME=$(get_alb_dns_name)
JENKINS_ROLE_ARN=$(get_iam_role_arn "jenkins-role")
EKS_ROLE_ARN=$(get_iam_role_arn "eks-role")

# Error handling
if [ -z "$VPC_ID" ]; then
  echo "No default VPC found. Please create a VPC or specify the VPC ID manually."
  exit 1
fi

if [ -z "$SUBNET_IDS" ]; then
  echo "No public subnets found. Please create subnets or specify them manually."
  exit 1
fi

if [ -z "$AVAILABILITY_ZONES" ]; then
  echo "No availability zones found. Please ensure your region is correctly set."
  exit 1
fi

if [ -z "$NAT_GATEWAY_ID" ]; then
  echo "No NAT Gateway found. Please ensure a NAT Gateway is properly configured."
  exit 1
fi

if [ -z "$ECR_REPO_URI" ]; then
  echo "No ECR Repository found. Please create an ECR repository."
  exit 1
fi

if [ -z "$S3_BUCKET" ]; then
  echo "No S3 Bucket found for Jenkins backups. Please create an S3 bucket."
  exit 1
fi

if [ -z "$ALB_DNS_NAME" ]; then
  echo "No ALB DNS Name found. Please ensure the ALB is properly configured."
  exit 1
fi

if [ -z "$JENKINS_ROLE_ARN" ]; then
  echo "No IAM role found for Jenkins. Please create an IAM role for Jenkins."
  exit 1
fi

if [ -z "$EKS_ROLE_ARN" ]; then
  echo "No IAM role found for EKS. Please create an IAM role for EKS."
  exit 1
fi

# Split Subnets into an array
IFS=' ' read -r -a SUBNETS_ARRAY <<< "$SUBNET_IDS"
SUBNET_1=${SUBNETS_ARRAY[0]}
SUBNET_2=${SUBNETS_ARRAY[1]}

# Split Availability Zones into an array
IFS=' ' read -r -a AZ_ARRAY <<< "$AVAILABILITY_ZONES"
AZ_1=${AZ_ARRAY[0]}
AZ_2=${AZ_ARRAY[1]}

# Populate common.tfvars
echo "Populating common.tfvars..."
cat > "$VARS_DIR/common.tfvars" <<EOL
region = "$REGION"
vpc_id = "$VPC_ID"
subnet_1_id = "$SUBNET_1"
subnet_2_id = "$SUBNET_2"
availability_zone_1 = "$AZ_1"
availability_zone_2 = "$AZ_2"
nat_gateway_id = "$NAT_GATEWAY_ID"
ecr_repo_uri = "$ECR_REPO_URI"
s3_bucket_name = "$S3_BUCKET"
alb_dns_name = "$ALB_DNS_NAME"
jenkins_iam_role_arn = "$JENKINS_ROLE_ARN"
eks_iam_role_arn = "$EKS_ROLE_ARN"
EOL

# Populate stage.tfvars
echo "Populating stage.tfvars..."
cat > "$VARS_DIR/stage.tfvars" <<EOL
environment = "stage"
eks_instance_type = "t3.small"
eks_desired_capacity = 1
eks_max_capacity = 2
eks_min_capacity = 1
vpc_id = "$VPC_ID"
subnet_1_id = "$SUBNET_1"
subnet_2_id = "$SUBNET_2"
availability_zone_1 = "$AZ_1"
availability_zone_2 = "$AZ_2"
nat_gateway_id = "$NAT_GATEWAY_ID"
ecr_repo_uri = "$ECR_REPO_URI"
s3_bucket_name = "$S3_BUCKET"
alb_dns_name = "$ALB_DNS_NAME"
jenkins_iam_role_arn = "$JENKINS_ROLE_ARN"
eks_iam_role_arn = "$EKS_ROLE_ARN"
EOL

# Populate prod.tfvars
echo "Populating prod.tfvars..."
cat > "$VARS_DIR/prod.tfvars" <<EOL
environment = "prod"
eks_instance_type = "t3.large"
eks_desired_capacity = 3
eks_max_capacity = 5
eks_min_capacity = 2
vpc_id = "$VPC_ID"
subnet_1_id = "$SUBNET_1"
subnet_2_id = "$SUBNET_2"
availability_zone_1 = "$AZ_1"
availability_zone_2 = "$AZ_2"
nat_gateway_id = "$NAT_GATEWAY_ID"
ecr_repo_uri = "$ECR_REPO_URI"
s3_bucket_name = "$S3_BUCKET"
alb_dns_name = "$ALB_DNS_NAME"
jenkins_iam_role_arn = "$JENKINS_ROLE_ARN"
eks_iam_role_arn = "$EKS_ROLE_ARN"
EOL

echo "Variable population completed successfully!"
