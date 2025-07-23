#!/bin/bash

# =================================================================
# Minikube Cluster and Application Setup
# Author: Illia Rizvash (Reviewed by Gemini)
# Date: 2025-07
#
# This script starts a Minikube cluster and deploys Jenkins,
# ArgoCD, and KEDA using Helm. It assumes that Docker, Minikube,
# Kubectl, and Helm are already installed.
#
# 🟢 How to use:
# 1. Run 'install-prerequisites.sh' first.
# 2. Ensure your user is in the 'docker' group (re-login if needed).
# 3. Save the script: minikube_cluster_setup.sh
# 4. Make it executable: chmod +x minikube_cluster_setup.sh
# 5. Run it as a regular user: ./minikube_cluster_setup.sh
# =================================================================

set -e

# --- Step 1: Dependency Check ---
echo "🔎 Checking for dependencies (docker, minikube, kubectl, helm)..."
for cmd in docker minikube kubectl helm; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "❌ Error: $cmd is not installed. Please run the prerequisites installer first."
    exit 1
  fi
done
echo "✅ Dependencies are satisfied."

# --- Step 2: Minikube Cluster Startup ---
echo "🔍 Verifying Minikube cluster status..."
if ! minikube status &> /dev/null; then
    echo "🚀 Starting Minikube cluster..."
    minikube start --driver=docker
else
    echo "✅ Minikube is already running."
fi

# --- Step 3: Helm Repository Management ---
echo "📦 Adding Helm repositories..."
helm repo add jenkins https://charts.jenkins.io
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add kedacore https://kedacore.github.io/charts
echo "🔄 Updating Helm repositories..."
helm repo update

# --- Step 4: Jenkins Installation ---
echo "📦 Installing Jenkins..."
helm upgrade --install jenkins jenkins/jenkins \
  --namespace jenkins \
  --create-namespace \
  --set controller.serviceType=NodePort \
  --wait
echo "✅ Jenkins is ready."

# --- Step 5: ArgoCD Installation ---
echo "📦 Installing ArgoCD..."
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  --wait
echo "✅ ArgoCD is ready."

# --- Step 6: KEDA Installation ---
echo "📦 Installing KEDA..."
helm upgrade --install keda kedacore/keda \
  --namespace keda \
  --create-namespace \
  --wait
echo "✅ KEDA is ready."

# --- Final Instructions ---
echo "🎉 All components installed successfully!"
echo "🔑 Your ArgoCD initial admin password is:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d && echo
