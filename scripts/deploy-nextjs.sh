#!/bin/bash

# Variables
NAMESPACE="${1:-default}"
CHART_NAME="${2:-nextjs-chat-service}"
VALUES_FILE="../infra/us-east-2/eks/nextjs-values.yaml"


# create namespace if it doesn't exist
kubectl get namespace $NAMESPACE || kubectl create namespace $NAMESPACE

# Deploy Next.js application using Helm
echo "Deploying Next.js Chat Service with Helm..."
helm upgrade --install $CHART_NAME stable/nextjs --namespace $NAMESPACE -f $VALUES_FILE
helm ls -n $NAMESPACE

# Deploy Next.js Chat Service using Helm
echo "Deploying Next.js Chat Service..."
helm upgrade --install $CHART_NAME ./helm-chart --namespace $NAMESPACE --values ./infra/us-east-2/eks/nextjs-values.yaml --atomic --timeout 5m


if [ $? -ne 0 ]; then
  echo "Deployment failed, initiating rollback..."
  helm rollback $CHART_NAME
else
  echo "Next.js Chat Service deployed successfully!"
fi