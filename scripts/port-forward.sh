#!/bin/bash

# Port-forward nginx service to localhost:8080
set -e

echo "🌐 Port-forwarding nginx-service..."

kubectl -n ci-cd-app port-forward svc/nginx-service 8080:80
