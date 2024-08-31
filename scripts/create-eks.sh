#!/bin/bash

# Variables
CLUSTER_NAME="${1:-my-eks-cluster}"
REGION="${2:-us-east-2}"

# Update kubeconfig to interact with EKS
echo "Updating kubeconfig for EKS cluster..."
aws eks --region $REGION update-kubeconfig --name $CLUSTER_NAME

echo "kubectl configured successfully for EKS cluster $CLUSTER_NAME in region $REGION!"
