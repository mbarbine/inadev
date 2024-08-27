#!/bin/bash

# Set the environment and region
ENVIRONMENT=$1
REGION="us-east-2"

if [ -z "$ENVIRONMENT" ]; then
  echo "Please specify an environment (stage or prod)."
  exit 1
fi

# Deploy infrastructure using Terraform
echo "Deploying infrastructure for environment $ENVIRONMENT in region $REGION..."

cd terraform/us-east-2
terraform init
terraform workspace select $ENVIRONMENT || terraform workspace new $ENVIRONMENT
terraform apply -var-file="../../infra/us-east-2/vars/common.tfvars" -var-file="../../infra/us-east-2/vars/$ENVIRONMENT.tfvars" -auto-approve

# Configure kubectl for EKS
cd ../../infra/us-east-2/scripts
./create-eks.sh my-eks-cluster $REGION

# Deploy Next.js Chat Service
./deploy-nextjs.sh default nextjs-chat-service

echo "Deployment completed for environment $ENVIRONMENT!"
