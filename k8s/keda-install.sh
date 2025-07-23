#!/bin/bash

# Install KEDA into the cluster using the official release

set -e

echo "📦 Installing KEDA..."

kubectl apply -f https://github.com/kedacore/keda/releases/download/v2.14.0/keda-2.14.0.yaml

echo "✅ KEDA installed successfully."
echo "⏳ Waiting for KEDA components to be ready..."

kubectl -n keda wait deployment/keda-operator --for=condition=Available=True --timeout=90s

echo "✅ KEDA operator is ready."
