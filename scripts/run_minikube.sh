#!/bin/bash

# Start minikube with Docker driver and enough resources for KEDA demo
set -e

echo "🚀 Starting minikube..."

minikube start --driver=docker --cpus=2 --memory=4096

echo "✅ Minikube started."

echo "📦 Enabling ingress addon (optional)..."
minikube addons enable ingress
