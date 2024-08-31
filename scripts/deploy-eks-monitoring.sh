#!/bin/bash

# Variables
NAMESPACE="${1:-monitoring}"

# Create the monitoring namespace
kubectl create namespace $NAMESPACE

# Deploy Prometheus and Grafana using Helm
echo "Deploying Prometheus and Grafana..."

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

helm install prometheus prometheus-community/prometheus --namespace $NAMESPACE
helm install grafana grafana/grafana --namespace $NAMESPACE --set adminPassword='admin'

echo "Prometheus and Grafana deployed successfully!"

# Display Grafana admin password and port-forwarding command
echo "Grafana login: admin/admin"
echo "Run the following command to access Grafana:"
echo "kubectl port-forward svc/grafana 3000:80 -n $NAMESPACE"
