#!/bin/bash

# Variables
CLUSTER_NAME="${1:-my-eks-cluster}"
REGION="${2:-us-east-2}"
SERVICE_ACCOUNT_NAME="aws-load-balancer-controller"

# Add EKS Helm repo
helm repo add eks https://aws.github.io/eks-charts
helm repo update

# Install ALB Ingress Controller
echo "Installing ALB Ingress Controller..."
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=$CLUSTER_NAME \
  --set serviceAccount.create=false \
  --set serviceAccount.name=$SERVICE_ACCOUNT_NAME

echo "ALB Ingress Controller installed successfully!"
