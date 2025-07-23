#!/bin/bash

# ========================================================
# Docker CE + Compose Plugin + Buildx installer for Ubuntu 22.04+
# Author: ChatGPT for Illia Rizvash (Reviewed by Gemini)
# Date: 2025-07
#
# This script installs Docker from the official Docker repository,
# including docker-compose plugin and buildx support.
# It also adds the current user to the 'docker' group.
#
# 🟢 How to use:
# 1. Save the script: install_docker_ubuntu.sh
# 2. Make it executable: chmod +x install_docker_ubuntu.sh
# 3. Run with sudo: sudo ./install_docker_ubuntu.sh
# ========================================================

set -e

# --- Check for root privileges ---
if [ "$EUID" -ne 0 ]; then
  echo "❌ This script must be run as root. Please use sudo."
  exit 1
fi

# --- Step 1: Install required packages ---
echo "🧩 Step 1: Installing required packages..."
apt-get update
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# --- Step 2: Add Docker's official GPG key ---
echo "🔐 Step 2: Adding Docker GPG key..."
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

# --- Step 3: Add Docker repository ---
echo "📦 Step 3: Adding Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

# --- Step 4: Install Docker Engine, CLI, Compose plugin, and Buildx ---
echo "🚀 Step 4: Installing Docker Engine and plugins..."
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# --- Step 5: Verify Docker service is running ---
echo "✅ Step 5: Verifying Docker installation..."
if systemctl is-active --quiet docker; then
    echo "🟢 Docker service is active and running."
else
    echo "🔴 Docker service failed to start."
    exit 1
fi

# --- Step 6: Add current user to the 'docker' group ---
if [ -n "$SUDO_USER" ]; then
    echo "👤 Step 6: Adding user '$SUDO_USER' to the 'docker' group..."
    usermod -aG docker "$SUDO_USER"
else
    echo "⚠️ Could not determine the user who ran sudo. Skipping add to 'docker' group."
fi

# --- Final Instructions ---
echo "🎉 Docker installation and setup complete!"
echo "‼️ IMPORTANT: For the group changes to take effect, you must log out and log back in, or restart your system."
