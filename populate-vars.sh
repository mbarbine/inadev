#!/bin/bash

# Set the AWS Region and default instance types
REGION=${1:-"us-east-2"}
STAGE_INSTANCE_TYPE=${2:-"t3.small"}
PROD_INSTANCE_TYPE=${3:-"t3.large"}

# Determine the directory of the current script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VARS_DIR="$SCRIPT_DIR/../vars"

# Ensure AWS CLI is installed
if ! command -v aws &> /dev/null; then
  echo "Error: AWS CLI is not installed."
  exit 1
fi

# Functions to query AWS resources
get_vpc_id() {
  echo "Fetching VPC ID..."
  VPC_ID=$(aws ec2 describe-vpcs \
    --query 'Vpcs[?IsDefault==`true`].VpcId' \
    --output text \
    --region "$REGION")
  
  if [ -z "$VPC_ID" ]; then
    echo "Error: No default VPC found in region $REGION. Please create a VPC or specify the VPC ID manually."
    exit 1
  fi

  echo "VPC ID: $VPC_ID"
}

get_subnet_ids() {
  echo "Fetching Subnet IDs..."
  SUBNET_IDS=$(aws ec2 describe-subnets \
    --query 'Subnets[?MapPublicIpOnLaunch==`true`].SubnetId' \
    --output text \
    --region "$REGION")
  
  if [ -z "$SUBNET_IDS" ]; then
    echo "Error: No public subnets found in region $REGION. Please create subnets or specify them manually."
    exit 1
  fi

  echo "Subnet IDs: $SUBNET_IDS"
}

get_availability_zones() {
  echo "Fetching Availability Zones..."
  AVAILABILITY_ZONES=$(aws ec2 describe-availability-zones \
    --query 'AvailabilityZones[?State==`available`].ZoneName' \
    --output text \
    --region "$REGION")

  if [ -z "$AVAILABILITY_ZONES" ]; then
    echo "Error: No available availability zones found in region $REGION."
    exit 1
  fi

  echo "Availability Zones: $AVAILABILITY_ZONES"
}

# Execute functions
get_vpc_id
get_subnet_ids
get_availability_zones

# Split Subnets and Availability Zones into arrays
IFS=' ' read -r -a SUBNETS_ARRAY <<< "$SUBNET_IDS"
IFS=' ' read -r -a AZ_ARRAY <<< "$AVAILABILITY_ZONES"

# Assign values for the first two subnets and availability zones
SUBNET_1=${SUBNETS_ARRAY[0]}
SUBNET_2=${SUBNETS_ARRAY[1]}
AZ_1=${AZ_ARRAY[0]}
AZ_2=${AZ_ARRAY[1]}

# Ensure the vars directory exists
mkdir -p "$VARS_DIR"

# Function to populate variable files
populate_vars() {
  local environment=$1
  local instance_type=$2
  local file_name="$VARS_DIR/$environment.tfvars"

  echo "Populating $file_name..."
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
EOL
}

# Populate common.tfvars
echo "Populating common.tfvars..."
cat > "$VARS_DIR/common.tfvars" <<EOL
region = "$REGION"
vpc_id = "$VPC_ID"
subnet_1_id = "$SUBNET_1"
subnet_2_id = "$SUBNET_2"
availability_zone_1 = "$AZ_1"
availability_zone_2 = "$AZ_2"
EOL

# Populate stage.tfvars and prod.tfvars
populate_vars "stage" "$STAGE_INSTANCE_TYPE"
populate_vars "prod" "$PROD_INSTANCE_TYPE"

echo "Variable population completed successfully!"
