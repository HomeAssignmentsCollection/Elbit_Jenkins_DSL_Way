#!/bin/bash

# ========================================================
# Install DevOps tools: Dockle, Vault, Kind
# Target OS: Ubuntu 22.04+
# Author: ChatGPT for Illia Rizvash (Reviewed by Gemini)
# Date: 2025-07
#
# 🟢 How to use:
# 1. Save this file as: install_devops_tools.sh
# 2. Make executable: chmod +x install_devops_tools.sh
# 3. Run with sudo: sudo ./install_devops_tools.sh
# ========================================================

set -e

# --- Check for root privileges ---
if [ "$EUID" -ne 0 ]; then
  echo "❌ This script must be run as root. Please use sudo."
  exit 1
fi

# --- Initial System Update ---
echo "📦 Updating system packages..."
apt-get update
# Install jq for robust JSON parsing
apt-get install -y jq curl wget

# ========== Dockle ==========
echo "🐳 Installing Dockle (image linter)..."
# Use GitHub API to find the latest release URL dynamically
DOCKLE_URL=$(curl -s https://api.github.com/repos/goodwithtech/dockle/releases/latest | jq -r '.assets[] | select(.name | endswith("_Linux-64bit.tar.gz")) | .browser_download_url')

if [ -z "$DOCKLE_URL" ]; then
    echo "❌ Could not find a download URL for Dockle. Exiting."
    exit 1
fi

echo "🔽 Downloading Dockle from $DOCKLE_URL"
curl -sSfLo dockle.tar.gz "$DOCKLE_URL"
tar -zxvf dockle.tar.gz dockle
chmod +x dockle
mv dockle /usr/local/bin/
rm dockle.tar.gz # Clean up the archive
echo "✅ Dockle installed: $(dockle --version)"

# ========== HashiCorp Vault ==========
echo "🔐 Installing HashiCorp Vault..."
# Add HashiCorp GPG key
curl -fsSL https://apt.releases.hashicorp.com/gpg | gpg --dearmor | \
  tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
# Add the repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
  https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
  tee /etc/apt/sources.list.d/hashicorp.list

# Update package list again after adding new repo
apt-get update

# Install Vault
apt-get install -y vault
echo "✅ Vault installed: $(vault --version)"

# ========== Kind ==========
echo "☸️ Installing Kind (Kubernetes IN Docker)..."
# Get the latest stable version tag
KIND_LATEST_VERSION=$(curl -s https://api.github.com/repos/kubernetes-sigs/kind/releases/latest | jq -r '.tag_name')
if [ -z "$KIND_LATEST_VERSION" ]; then
    echo "❌ Could not find the latest version for Kind. Exiting."
    exit 1
fi
echo "🔽 Downloading Kind version ${KIND_LATEST_VERSION}..."
curl -Lo /usr/local/bin/kind "https://kind.sigs.k8s.io/dl/${KIND_LATEST_VERSION}/kind-linux-amd64"
chmod +x /usr/local/bin/kind
echo "✅ Kind installed: $(kind version)"

echo "🎉 All selected tools are installed!"