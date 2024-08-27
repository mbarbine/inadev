# Step 1: Set Up Directory Structure
bash create-tree.sh

# Step 2: Populate AWS Environment Variables
bash populate-vars.sh

# Step 3: Deploy the Infrastructure
bash scripts/deploy.sh stage

# Step 4: Access Jenkins and Next.js
# Jenkins: Available via EC2 public IP/DNS
# Next.js Chat Service: Available via ALB DNS

# Step 5: Destroy Infrastructure (if needed)
cd terraform/us-east-2
terraform destroy -var-file="../infra/us-east-2/vars/stage.tfvars" -auto-approve
