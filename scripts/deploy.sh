#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# Set environment variables
REGION="us-east-2"
ENVIRONMENT=${1:-"stage"}
TERRAFORM_DIR="../terraform/us-east-2"
INFRA_DIR="../infra/us-east-2"
SCRIPTS_DIR="../scripts"
ALERT_EMAIL="michael@barbineworldwide.com"

# Step 1: Install necessary CLI tools
echo "Installing necessary CLI tools..."
source "$SCRIPTS_DIR/install-cli-brew.sh"

# Step 2: Initialize and apply Terraform
echo "Initializing Terraform..."
cd "$TERRAFORM_DIR"
terraform init

echo "Applying Terraform configuration for environment: $ENVIRONMENT..."
terraform apply -var-file="$INFRA_DIR/vars/$ENVIRONMENT.tfvars" -auto-approve

# Step 3: Configure kubectl for EKS
echo "Configuring kubectl for EKS..."
source "$SCRIPTS_DIR/aws-eks.sh"

# Step 4: Deploy Next.js Chat Service to EKS
echo "Deploying Next.js Chat Service..."
source "$SCRIPTS_DIR/deploy-nextjs.sh"

# Step 5: Configure Jenkins
echo "Configuring Jenkins on EC2..."
source "$SCRIPTS_DIR/configure-jenkins.sh"

echo "Deployment completed successfully!"
