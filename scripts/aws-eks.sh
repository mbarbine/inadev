#!/bin/bash

# Environment variables
REGION="us-east-2"
CLUSTER_NAME="${ENVIRONMENT}-eks-cluster"

# Check if the EKS cluster exists
echo "Setting up kubeconfig for EKS cluster: $CLUSTER_NAME in region: $REGION..."
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME
echo "kubectl is configured successfully for the EKS cluster!"

# Ensure kubectl is installed
if ! command -v kubectl &> /dev/null
then
    echo "kubectl not found. Installing kubectl..."
    curl -LO "https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
fi

# Configure kubectl for the EKS cluster
aws eks update-kubeconfig --region $REGION --name $CLUSTER_NAME
aws eks --region $REGION update-kubeconfig --name $CLUSTER_NAME

echo "kubectl has been configured to access the EKS cluster."
