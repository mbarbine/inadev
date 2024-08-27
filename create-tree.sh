#!/bin/bash
# Root directory is "./"
BASE_DIR="."

# Create the directory structure for us-east-2
mkdir -p $BASE_DIR/infra/us-east-2/alb
mkdir -p $BASE_DIR/infra/us-east-2/ec2
mkdir -p $BASE_DIR/infra/us-east-2/eks
mkdir -p $BASE_DIR/infra/us-east-2/scripts
mkdir -p $BASE_DIR/infra/us-east-2/vars
mkdir -p $BASE_DIR/terraform/us-east-2/modules/alb
mkdir -p $BASE_DIR/terraform/us-east-2/modules/ec2
mkdir -p $BASE_DIR/terraform/us-east-2/modules/eks
mkdir -p $BASE_DIR/terraform/us-east-2/modules/vpc

# Create the structure for us-west-2 (blank for now)
mkdir -p $BASE_DIR/infra/us-west-2
mkdir -p $BASE_DIR/terraform/us-west-2

# Create placeholder files for us-east-2
touch $BASE_DIR/README.md
touch $BASE_DIR/infra/us-east-2/alb/alb.tf
touch $BASE_DIR/infra/us-east-2/ec2/ec2.tf
touch $BASE_DIR/infra/us-east-2/eks/main.tf
touch $BASE_DIR/infra/us-east-2/eks/nextjs-values.yaml
touch $BASE_DIR/infra/us-east-2/scripts/aws-eks.sh
touch $BASE_DIR/infra/us-east-2/scripts/create-eks.sh
touch $BASE_DIR/infra/us-east-2/scripts/deploy-nextjs.sh
touch $BASE_DIR/infra/us-east-2/scripts/deploy.sh
touch $BASE_DIR/infra/us-east-2/scripts/install-cli-brew.sh
touch $BASE_DIR/infra/us-east-2/vars/common.tfvars
touch $BASE_DIR/infra/us-east-2/vars/stage.tfvars
touch $BASE_DIR/infra/us-east-2/vars/prod.tfvars
touch $BASE_DIR/terraform/us-east-2/main.tf
touch $BASE_DIR/terraform/us-east-2/variables.tf
touch $BASE_DIR/terraform/us-east-2/modules/alb/alb.tf
touch $BASE_DIR/terraform/us-east-2/modules/ec2/ec2.tf
touch $BASE_DIR/terraform/us-east-2/modules/eks/eks.tf
touch $BASE_DIR/terraform/us-east-2/modules/eks/iam.tf
touch $BASE_DIR/terraform/us-east-2/modules/vpc/vpc.tf

# Create placeholder files for us-west-2 (blank)
touch $BASE_DIR/infra/us-west-2/README.md
touch $BASE_DIR/terraform/us-west-2/README.md

echo "Directory structure created successfully!"

