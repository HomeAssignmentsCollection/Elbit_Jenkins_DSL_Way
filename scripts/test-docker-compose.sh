#!/bin/bash

# Test script for Docker Compose setup with full Docker socket access

set -e

echo "🚀 Starting Docker Compose test with full functionality..."

# Stop any existing containers
echo "🧹 Cleaning up existing containers..."
docker compose down -v 2>/dev/null || true

# Build and start services
echo "🔨 Building and starting services..."
docker compose up -d --build

# Wait for services to be healthy
echo "⏳ Waiting for services to be healthy..."
timeout=120
elapsed=0
while [ $elapsed -lt $timeout ]; do
    if docker compose ps | grep -q "healthy"; then
        echo "✅ Services are healthy!"
        break
    fi
    sleep 5
    elapsed=$((elapsed + 5))
    echo "⏳ Still waiting... ($elapsed/$timeout seconds)"
done

if [ $elapsed -ge $timeout ]; then
    echo "❌ Timeout waiting for services to be healthy"
    docker compose logs
    exit 1
fi

# Test Flask API directly
echo "🧪 Testing Flask API directly..."
sleep 5
curl -s http://localhost:5000/health | jq .

# Test Flask API containers endpoint
echo "🧪 Testing Flask API containers endpoint..."
curl -s http://localhost:5000/api/containers | jq .

# Test Nginx proxy health
echo "🧪 Testing Nginx proxy health..."
curl -s http://localhost:8080/

# Test Nginx proxy to Flask API
echo "🧪 Testing Nginx proxy to Flask API..."
curl -s http://localhost:8080/api/containers | jq .

# Show running containers
echo "📊 Current Docker containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo "✅ Docker Compose test completed successfully!"
echo ""
echo "🌐 Access points:"
echo "   Flask API: http://localhost:5000"
echo "   Nginx Proxy: http://localhost:8080"
echo "   API Endpoint: http://localhost:8080/api/containers"
echo ""
echo "📝 To view logs: docker compose logs -f"
echo "🛑 To stop: docker compose down" 