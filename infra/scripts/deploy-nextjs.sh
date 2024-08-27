#!/bin/bash

# Variables
NAMESPACE="${1:-default}"
CHART_NAME="${2:-nextjs-chat-service}"

# Deploy Next.js Chat Service using Helm
echo "Deploying Next.js Chat Service..."
helm install $CHART_NAME ./helm-chart --namespace $NAMESPACE --values ./infra/us-east-2/eks/nextjs-values.yaml

echo "Next.js Chat Service deployed successfully!"
