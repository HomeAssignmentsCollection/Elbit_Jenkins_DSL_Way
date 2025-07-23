#!/bin/bash

# ========================================================
# Install Rancher Management Platform on Rancher Desktop
# Target OS: Ubuntu 22.04+
# Author: Gemini for Illia Rizvash
# Date: 2025-07
#
# This script installs the Rancher UI into an existing
# Kubernetes cluster provided by Rancher Desktop.
#
# 🟢 How to use:
# 1. Make sure Rancher Desktop is installed and RUNNING.
# 2. Save this file as: install_rancher.sh
# 3. Make executable: chmod +x install_rancher.sh
# 4. Run the script: ./install_rancher.sh
# ========================================================

set -e

# --- Step 1: Check for dependencies (kubectl, helm) ---
echo "🔎 Checking for dependencies (kubectl, helm)..."
for cmd in kubectl helm; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "❌ Error: $cmd is not installed or not in your PATH."
    echo "Please ensure Rancher Desktop is running and its tools are in the system PATH."
    exit 1
  fi
done
echo "✅ Dependencies are satisfied."

# --- Step 2: Add Rancher Helm repository ---
echo "📦 Adding Rancher Helm repository..."
helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
helm repo update

# --- Step 3: Create namespace for Rancher ---
echo "🏗️ Creating 'cattle-system' namespace..."
# The '|| true' part ensures the script doesn't fail if the namespace already exists
kubectl create namespace cattle-system || true

# --- Step 4: Install Rancher via Helm ---
echo "🚀 Installing Rancher... This may take several minutes."
helm upgrade --install rancher rancher-latest/rancher \
  --namespace cattle-system \
  --set hostname=rancher.localhost \
  --set replicas=1 \
  --set bootstrapPassword=admin

# --- Step 5: Wait for Rancher to be ready ---
echo "⏳ Waiting for Rancher deployment to be ready..."
kubectl -n cattle-system wait --for=condition=ready pod -l app=rancher --timeout=600s

# --- Final Instructions ---
echo "🎉 Rancher installed successfully!"
echo "✅ You can now access the Rancher UI at: https://rancher.localhost"
echo "🔑 Login with the username 'admin' and the password 'admin'."
echo "ℹ️ Your browser may show a security warning for the self-signed certificate. This is normal, please proceed."
