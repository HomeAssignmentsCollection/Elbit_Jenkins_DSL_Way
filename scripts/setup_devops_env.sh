#!/bin/bash

# =================================================================
# Full DevOps Environment Setup Script
# Author: Illia Rizvash (Reviewed by Gemini)
# Date: 2025-07
#
# This script installs a complete DevOps environment on Ubuntu 22.04+,
# including Docker, Kubectl, Minikube, Helm, and Terraform.
# It then deploys Jenkins, ArgoCD, and KEDA into the Minikube cluster.
#
# 🟢 How to use:
# 1. Save the script: setup_devops_env.sh
# 2. Make it executable: chmod +x setup_devops_env.sh
# 3. Run with sudo: sudo ./setup_devops_env.sh
# =================================================================

# Exit immediately if a command exits with a non-zero status.
set -e

# --- Check for root privileges ---
if [ "$EUID" -ne 0 ]; then
  echo "❌ This script must be run as root. Please use sudo."
  exit 1
fi

# --- System Update and Prerequisite Installation ---
echo "🔧 Updating system and installing required packages..."
apt-get update -y
apt-get install -y curl wget apt-transport-https gnupg lsb-release software-properties-common

# --- Docker Installation ---
# This is a dependency for Minikube, so we ensure it's installed first.
if ! command -v "docker" &> /dev/null; then
    echo "🚀 Installing Docker..."
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
    chmod a+r /etc/apt/keyrings/docker.gpg
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
    apt-get update -y
    apt-get install -y docker-ce docker-ce-cli containerd.io
    # Add current user to docker group
    usermod -aG docker "$SUDO_USER"
    echo "✅ Docker installed. Note: You may need to relogin for group changes to take effect."
else
    echo "✅ Docker is already installed."
fi

# --- Kubectl Installation ---
if ! command -v "kubectl" &> /dev/null; then
    echo "🚀 Installing kubectl..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    echo "✅ kubectl installed."
else
    echo "✅ kubectl is already installed."
fi

# --- Minikube Installation ---
if ! command -v "minikube" &> /dev/null; then
    echo "🚀 Installing Minikube..."
    curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    install minikube /usr/local/bin/
    rm minikube
    echo "✅ Minikube installed."
else
    echo "✅ Minikube is already installed."
fi

# --- Helm Installation ---
if ! command -v "helm" &> /dev/null; then
    echo "🚀 Installing Helm..."
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
    echo "✅ Helm is already installed."
fi

# --- Terraform Installation ---
if ! command -v "terraform" &> /dev/null; then
    echo "🚀 Installing Terraform..."
    curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
    echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list
    apt-get update -y
    apt-get install -y terraform
    echo "✅ Terraform installed."
else
    echo "✅ Terraform is already installed."
fi


# --- Minikube Cluster Startup ---
echo "🔍 Verifying Minikube cluster status..."
if ! minikube status &> /dev/null; then
    echo "🚀 Starting Minikube cluster..."
    # Run minikube start as the original user to avoid permission issues in ~/.minikube
    sudo -u "$SUDO_USER" minikube start --driver=docker
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