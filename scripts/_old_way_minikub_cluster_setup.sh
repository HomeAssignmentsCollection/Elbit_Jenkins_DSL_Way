#!/bin/bash

# Exit script on any error
set -e

# --- Dependency Check ---
echo "🔎 Checking for dependencies (docker, minikube, kubectl)..."
for cmd in docker minikube kubectl; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "❌ Error: $cmd is not installed. Please install it first."
    exit 1
  fi
done
echo "✅ Dependencies are satisfied."

# --- System Update and Utility Installation ---
echo "🔧 Updating system and installing required packages..."
sudo apt-get update -y > /dev/null
sudo apt-get install -y curl wget apt-transport-https gnupg lsb-release > /dev/null
echo "✅ System updated."

# --- Helm Installation ---
if ! command -v "helm" &> /dev/null; then
    echo "🚀 Installing Helm..."
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi
echo "✅ Helm is installed."

# --- Minikube Startup ---
echo "🔍 Verifying Minikube status..."
if ! minikube status &> /dev/null; then
    echo "🚀 Starting Minikube..."
    minikube start --driver=docker
else
    echo "✅ Minikube is already running."
fi

# --- Helm Repository Management ---
echo "📦 Adding Helm repositories..."
helm repo add jenkins https://charts.jenkins.io
helm repo add kedacore https://kedacore.github.io/charts
echo "🔄 Updating Helm repositories..."
helm repo update

# --- Jenkins Installation ---
echo "📦 Installing Jenkins..."
helm upgrade --install jenkins jenkins/jenkins \
  --namespace jenkins \
  --create-namespace \
  --set controller.serviceType=NodePort

echo "⏳ Waiting for Jenkins to be ready..."
kubectl wait --namespace jenkins \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=jenkins-controller \
  --timeout=300s
echo "✅ Jenkins is ready."

# --- ArgoCD Installation ---
echo "📦 Installing ArgoCD..."
kubectl create namespace argocd || true
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

echo "⏳ Waiting for ArgoCD server to be ready..."
kubectl wait --namespace argocd \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=argocd-server \
  --timeout=300s
echo "✅ ArgoCD is ready."

# --- KEDA Installation ---
echo "📦 Installing KEDA..."
helm upgrade --install keda kedacore/keda \
  --namespace keda \
  --create-namespace

echo "⏳ Waiting for KEDA operator to be ready..."
kubectl wait --namespace keda \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/name=keda-operator \
  --timeout=120s
echo "✅ KEDA is ready."


# --- Final Instructions ---
echo "🎉 All components installed successfully!"
echo "🔑 Your ArgoCD initial admin password is:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
