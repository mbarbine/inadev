#!/bin/bash

# Set the AWS Region and other defaults
export REGION=${1:-"us-east-2"}
export CLUSTER_NAME="weather-lama-eks-cluster"
export DOMAIN_NAME_1="inadev.cheeseusfries.com"
export DOMAIN_NAME_2="jenkins.cheeseusfries.com"
export DOMAIN_NAME_DEV="localhost"
export STAGE_INSTANCE_TYPE=${2:-"t3.small"}
export PROD_INSTANCE_TYPE=${3:-"t3.large"}
export SCRIPTS_DIR="scripts"
export TERRAFORM_DIR="terraform/us-east-2"
export ECR_REPOSITORY='nextjs-app-repo'
export EKS_NAMESPACE='default'
export AVAILABILITY_ZONES='us-east-2a us-east-2b'
export AWS_REGION='us-east-2'
export KMS_KEY_ALIAS='alias/eks-kms-key'
export KMS_KEY_ID='arn:aws:kms:us-east-2:123456789012:key/12345678-1234-1234-1234-123456789012'
export S3_BUCKETS='weather-lama-eks-cluster'
export JENKINS_ADMIN_USER="admin"
export JENKINS_ADMIN_PASSWORD="adminpassword"
export JENKINS_PORT=8080
export BACKUP_DIR='jenkins-backups'
export JENKINS_VOLUME='jenkins-home'
export JENKINS_VOLUME_SIZE=20
export JENKINS_BACKUP_BUCKET='jenkins-backups'
export JENKINS_BACKUP_LIFECYCLE=30
export JENKINS_BACKUP_SCHEDULE='cron(0 0 * * *)'
export JENKINS_BACKUP_RETENTION=7
export JENKINS_BACKUP_IMAGE="${ECR_REPO_URI}:jenkins-backup"
export JENKINS_BACKUP_PORT=8080
export JENKINS_BACKUP_VOLUME='jenkins-backup'
export JENKINS_BACKUP_VOLUME_SIZE=20
export INFRA_DIR="infra/us-east-2/"
export VARS_DIR="$SCRIPT_DIR/infra/us-east-2/vars"
export DOMAIN_NAME="cheeseusfries.com"
export HOSTED_ZONE_ID="Z35SXDOTRQ7X7K"

# Logging function for better traceability
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >&2
}

# Determine the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VARS_DIR="$SCRIPT_DIR/infra/us-east-2/vars"

# Ensure the vars directory exists
mkdir -p "$VARS_DIR"
log "Vars directory: $VARS_DIR"

# Check if the AWS CLI is installed
if ! command -v aws &> /dev/null; then
    log "AWS CLI is not installed. Please install the AWS CLI before running this script."
    exit 1
fi

# Functions to query AWS resources
get_vpc_id() {
  aws ec2 describe-vpcs \
    --query 'Vpcs[?IsDefault==`true`].VpcId' \
    --output text \
    --region $REGION
}

get_subnet_ids() {
  aws ec2 describe-subnets \
    --query 'Subnets[?MapPublicIpOnLaunch==`true`].SubnetId' \
    --output text \
    --region $REGION
}

get_availability_zones() {
  aws ec2 describe-availability-zones \
    --query 'AvailabilityZones[?State==`available`].ZoneName' \
    --output text \
    --region $REGION
}

get_nat_gateway_id() {
  aws ec2 describe-nat-gateways \
    --query 'NatGateways[?State==`available`].NatGatewayId' \
    --output text \
    --region $REGION
}

get_ecr_repository_uri() {
  aws ecr describe-repositories \
    --query 'repositories[?repositoryName==`nextjs-app-repo`].repositoryUri' \
    --output text \
    --region $REGION
}

get_s3_bucket_name() {
  aws s3api list-buckets --query 'Buckets[?contains(Name, `jenkins-backups`) == `true`].Name' --output text
}

get_alb_dns_name() {
  aws elbv2 describe-load-balancers \
    --query 'LoadBalancers[?State.Code==`active`].DNSName' \
    --output text \
    --region $REGION
}

get_iam_role_arn() {
  aws iam list-roles \
    --query "Roles[?RoleName=='$1'].Arn" \
    --output text
}

# Fetching values (overriding environment variables if necessary)
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
handle_error() {
    if [ -z "$1" ]; then
        log "$2"
        exit 1
    fi
}

handle_error "$VPC_ID" "No default VPC found. Please create a VPC or specify the VPC ID manually."
handle_error "$SUBNET_IDS" "No public subnets found. Please create subnets or specify them manually."
handle_error "$AVAILABILITY_ZONES" "No availability zones found. Please ensure your region is correctly set."
handle_error "$NAT_GATEWAY_ID" "No NAT Gateway found. Please ensure a NAT Gateway is properly configured."
handle_error "$ECR_REPO_URI" "No ECR Repository found. Please create an ECR repository."
handle_error "$S3_BUCKET" "No S3 Bucket found for Jenkins backups. Please create an S3 bucket."
handle_error "$ALB_DNS_NAME" "No ALB DNS Name found. Please ensure the ALB is properly configured."
handle_error "$JENKINS_ROLE_ARN" "No IAM role found for Jenkins. Please create an IAM role for Jenkins."
handle_error "$EKS_ROLE_ARN" "No IAM role found for EKS. Please create an IAM role for EKS."

# Split Subnets into an array
IFS=' ' read -r -a SUBNETS_ARRAY <<< "$SUBNET_IDS"
SUBNET_1=${SUBNETS_ARRAY[0]}
SUBNET_2=${SUBNETS_ARRAY[1]}

# Split Availability Zones into an array
IFS=' ' read -r -a AZ_ARRAY <<< "$AVAILABILITY_ZONES"
AZ_1=${AZ_ARRAY[0]}
AZ_2=${AZ_ARRAY[1]}

populate_vars() {
  local environment=$1
  local instance_type=$2
  local file_name="$VARS_DIR/$environment.tfvars"

  log "Populating $file_name..."
  cat > "$file_name" <<EOL
environment = "$environment"
eks_instance_type = "$instance_type"
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
domain_name_1 = "$DOMAIN_NAME_1"
domain_name_2 = "$DOMAIN_NAME_2"
domain_name_dev = "$DOMAIN_NAME_DEV"
jenkins_port = "$JENKINS_PORT"
backup_dir = "$BACKUP_DIR"
jenkins_volume = "$JENKINS_VOLUME"
jenkins_volume_size = "$JENKINS_VOLUME_SIZE"
jenkins_backup_bucket = "$JENKINS_BACKUP_BUCKET"
jenkins_backup_lifecycle = "$JENKINS_BACKUP_LIFECYCLE"
jenkins_backup_schedule = "$JENKINS_BACKUP_SCHEDULE"
jenkins_backup_retention = "$JENKINS_BACKUP_RETENTION"
jenkins_backup_image = "$JENKINS_BACKUP_IMAGE"
jenkins_backup_port = "$JENKINS_BACKUP_PORT"
jenkins_backup_volume = "$JENKINS_BACKUP_VOLUME"
jenkins_backup_volume_size = "$JENKINS_BACKUP_VOLUME_SIZE"
EOL

  if [ $? -ne 0 ]; then
    log "Error writing to $file_name"
    exit 1
  fi
}

# Populate common.tfvars
log "Populating common.tfvars..."
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
domain_name_1 = "$DOMAIN_NAME_1"
domain_name_2 = "$DOMAIN_NAME_2"
domain_name_dev = "$DOMAIN_NAME_DEV"
jenkins_port = "$JENKINS_PORT"
backup_dir = "$BACKUP_DIR"
jenkins_volume = "$JENKINS_VOLUME"
jenkins_volume_size = "$JENKINS_VOLUME_SIZE"
jenkins_backup_bucket = "$JENKINS_BACKUP_BUCKET"
jenkins_backup_lifecycle = "$JENKINS_BACKUP_LIFECYCLE"
jenkins_backup_schedule = "$JENKINS_BACKUP_SCHEDULE"
jenkins_backup_retention = "$JENKINS_BACKUP_RETENTION"
jenkins_backup_image = "$JENKINS_BACKUP_IMAGE"
jenkins_backup_port = "$JENKINS_BACKUP_PORT"
jenkins_backup_volume = "$JENKINS_BACKUP_VOLUME"
jenkins_backup_volume_size = "$JENKINS_BACKUP_VOLUME_SIZE"
EOL

if [ $? -ne 0 ]; then
    log "Error writing to $VARS_DIR/common.tfvars"
    exit 1
fi

# Populate stage.tfvars and prod.tfvars
populate_vars "stage" "$STAGE_INSTANCE_TYPE"
populate_vars "prod" "$PROD_INSTANCE_TYPE"

log "Variable population completed successfully!"
log "Generated files:"
ls -l "$VARS_DIR"
