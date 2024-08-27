#!/bin/bash

# Root directory (update this to your desired root directory)
ROOT_DIR=$(pwd)

# Function to create directories
create_directory() {
    if [ ! -d "$1" ]; then
        mkdir -p "$1"
        echo "Created directory: $1"
    else
        echo "Directory already exists: $1"
    fi
}

# Function to create files if they don't exist
create_file() {
    if [ ! -f "$1" ]; then
        touch "$1"
        echo "Created file: $1"
    else
        echo "File already exists: $1"
    fi
}

# Ensure the scripts directory exists first
create_directory "$ROOT_DIR/scripts"

# Directory structure under infra
create_directory "$ROOT_DIR/infra/us-east-2/alb"
create_directory "$ROOT_DIR/infra/us-east-2/acm"
create_directory "$ROOT_DIR/infra/us-east-2/route53"
create_directory "$ROOT_DIR/infra/us-east-2/ec2"
create_directory "$ROOT_DIR/infra/us-east-2/eks"
create_directory "$ROOT_DIR/infra/us-east-2/iam"
create_directory "$ROOT_DIR/infra/us-east-2/monitoring"
create_directory "$ROOT_DIR/infra/us-east-2/s3"
create_directory "$ROOT_DIR/infra/us-east-2/ssm"
create_directory "$ROOT_DIR/infra/us-east-2/vpc"
create_directory "$ROOT_DIR/infra/us-east-2/security_groups"
create_directory "$ROOT_DIR/infra/us-east-2/vars"

# Directory structure under terraform
create_directory "$ROOT_DIR/terraform/us-east-2/modules/alb"
create_directory "$ROOT_DIR/terraform/us-east-2/modules/ec2"
create_directory "$ROOT_DIR/terraform/us-east-2/modules/ecr"
create_directory "$ROOT_DIR/terraform/us-east-2/modules/eks"
create_directory "$ROOT_DIR/terraform/us-east-2/modules/security_groups"
create_directory "$ROOT_DIR/terraform/us-east-2/modules/acm"
create_directory "$ROOT_DIR/terraform/us-east-2/modules/route53"
create_directory "$ROOT_DIR/terraform/us-east-2/modules/vpc"
create_directory "$ROOT_DIR/terraform/us-west-2"

# Create files for infra/us-east-2
create_file "$ROOT_DIR/infra/us-east-2/alb/alb.tf"
create_file "$ROOT_DIR/infra/us-east-2/acm/acm.tf"
create_file "$ROOT_DIR/infra/us-east-2/route53/route53.tf"
create_file "$ROOT_DIR/infra/us-east-2/ec2/ec2.tf"
create_file "$ROOT_DIR/infra/us-east-2/eks/eks.tf"
create_file "$ROOT_DIR/infra/us-east-2/eks/cluster-autoscaler.yaml"
create_file "$ROOT_DIR/infra/us-east-2/eks/nextjs-deployment.yaml"
create_file "$ROOT_DIR/infra/us-east-2/iam/jenkins_iam.tf"
create_file "$ROOT_DIR/infra/us-east-2/iam/eks_iam.tf"
create_file "$ROOT_DIR/infra/us-east-2/monitoring/cloudwatch.tf"
create_file "$ROOT_DIR/infra/us-east-2/monitoring/sns.tf"
create_file "$ROOT_DIR/infra/us-east-2/s3/s3.tf"
create_file "$ROOT_DIR/infra/us-east-2/ssm/ssm_parameters.tf"
create_file "$ROOT_DIR/infra/us-east-2/vpc/vpc.tf"
create_file "$ROOT_DIR/infra/us-east-2/security_groups/security_groups.tf"
create_file "$ROOT_DIR/infra/us-east-2/vars/common.tfvars"
create_file "$ROOT_DIR/infra/us-east-2/vars/prod.tfvars"
create_file "$ROOT_DIR/infra/us-east-2/vars/stage.tfvars"

# Create files for terraform/us-east-2
create_file "$ROOT_DIR/terraform/us-east-2/main.tf"
create_file "$ROOT_DIR/terraform/us-east-2/variables.tf"
create_file "$ROOT_DIR/terraform/us-east-2/modules/alb/alb.tf"
create_file "$ROOT_DIR/terraform/us-east-2/modules/ec2/ec2.tf"
create_file "$ROOT_DIR/terraform/us-east-2/modules/ecr/ecr.tf"
create_file "$ROOT_DIR/terraform/us-east-2/modules/eks/eks.tf"
create_file "$ROOT_DIR/terraform/us-east-2/modules/eks/iam.tf"
create_file "$ROOT_DIR/terraform/us-east-2/modules/security_groups/security_groups.tf"
create_file "$ROOT_DIR/terraform/us-east-2/modules/acm/acm.tf"
create_file "$ROOT_DIR/terraform/us-east-2/modules/route53/route53.tf"
create_file "$ROOT_DIR/terraform/us-east-2/modules/vpc/vpc.tf"
create_file "$ROOT_DIR/terraform/us-west-2/README.md"

# Create scripts if they don't exist
create_file "$ROOT_DIR/scripts/aws-eks.sh"
create_file "$ROOT_DIR/scripts/configure-jenkins.sh"
create_file "$ROOT_DIR/scripts/create-pipeline.groovy"
create_file "$ROOT_DIR/scripts/deploy.sh"
create_file "$ROOT_DIR/scripts/install-cli-brew.sh"
create_file "$ROOT_DIR/scripts/install-cloudwatch-agent.sh"
create_file "$ROOT_DIR/scripts/jenkins-backup.sh"
create_file "$ROOT_DIR/scripts/jenkins-restore.sh"
create_file "$ROOT_DIR/scripts/setup-dns.sh"
create_file "$ROOT_DIR/scripts/configure-acm.sh"
create_file "$ROOT_DIR/scripts/validate-eks-cluster.sh"
create_file "$ROOT_DIR/scripts/populate-vars.sh"
create_file "$ROOT_DIR/scripts/create-tree.sh"

# Final message
echo "Directory structure and files created successfully without overwriting existing ones!"
