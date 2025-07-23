#!/bin/bash

# Test the /api/containers endpoint from nginx proxy
set -e

echo "🔍 Sending test request to http://localhost:8080/api/containers..."

curl -s http://localhost:8080/api/containers | jq .
