#!/bin/bash

# Rotate SSH key for Jenkins
KEY_NAME="my-aws-key"
NEW_KEY_NAME="${KEY_NAME}-$(date +%Y%m%d%H%M%S)"

# Create a new key pair
aws ec2 create-key-pair --key-name $NEW_KEY_NAME --query 'KeyMaterial' --output text > ~/.ssh/$NEW_KEY_NAME.pem
chmod 400 ~/.ssh/$NEW_KEY_NAME.pem

# Attach the new key to Jenkins EC2 instance
INSTANCE_ID=$(aws ec2 describe-instances --filters "Name=tag:Name,Values=${ENVIRONMENT}-jenkins-server" --query "Reservations[*].Instances[*].InstanceId" --output text)
aws ec2 modify-instance-attribute --instance-id $INSTANCE_ID --key-name $NEW_KEY_NAME

echo "SSH key rotated successfully. New key name: $NEW_KEY_NAME"
