#!/bin/bash

# Deploy all Kubernetes resources for the CI/CD application
# This script applies resources in the correct order to avoid dependency issues

set -e

echo "🚀 Deploying CI/CD application to Kubernetes..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check if minikube is running
if ! minikube status | grep -q "Running"; then
    echo "⚠️  Minikube is not running. Starting minikube..."
    minikube start
fi

# Create namespace
echo "📦 Creating namespace..."
kubectl apply -f k8s/namespace.yaml

# Apply resource quotas and limits
echo "⚖️  Applying resource quotas..."
kubectl apply -f k8s/resource-quota.yaml

# Apply RBAC configuration
echo "🔐 Applying RBAC configuration..."
kubectl apply -f k8s/rbac.yaml

# Apply ConfigMap and Secrets
echo "⚙️  Applying configuration..."
kubectl apply -f k8s/configmap.yaml

# Apply services first
echo "🌐 Applying services..."
kubectl apply -f k8s/flask-service.yaml
kubectl apply -f k8s/service.yaml

# Apply deployments
echo "📦 Applying deployments..."
kubectl apply -f k8s/flask-deployment.yaml
kubectl apply -f k8s/nginx-deployment.yaml

# Apply network policies
echo "🛡️  Applying network policies..."
kubectl apply -f k8s/network-policy.yaml

# Apply KEDA ScaledObject
echo "📈 Applying KEDA scaling configuration..."
kubectl apply -f k8s/keda-scaledobject.yaml

# Wait for deployments to be ready
echo "⏳ Waiting for deployments to be ready..."
kubectl wait --for=condition=available --timeout=300s deployment/flask-api -n ci-cd-app
kubectl wait --for=condition=available --timeout=300s deployment/nginx-proxy -n ci-cd-app

echo "✅ Deployment completed successfully!"
echo ""
echo "📊 Current status:"
kubectl get pods -n ci-cd-app
echo ""
echo "🌐 Services:"
kubectl get services -n ci-cd-app
echo ""
echo "🔗 To access the application:"
echo "   kubectl port-forward -n ci-cd-app service/nginx-service 8080:80"
echo "   Then visit: http://localhost:8080/api/containers" 