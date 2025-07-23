#!/bin/bash

# =================================================================
# Prerequisites Installer Script
# Author: Illia Rizvash (Reviewed by Gemini)
# Date: 2025-07
#
# This script installs the core tools required for a DevOps environment
# on Ubuntu 22.04+, including Docker, Kubectl, Minikube, Helm,
# and Terraform.
#
# 🟢 How to use:
# 1. Save the script: install_prerequisites.sh
# 2. Make it executable: chmod +x install_prerequisites.sh
# 3. Run with sudo: sudo ./install_prerequisites.sh
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

echo "🎉 All prerequisite tools have been installed successfully!"
