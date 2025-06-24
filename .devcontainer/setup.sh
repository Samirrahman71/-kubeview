#!/bin/bash

# Setup script for Kubeview development environment

echo "🚀 Setting up Kubeview development environment..."

# Install kind
echo "📦 Installing kind..."
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

# Verify installations
echo "✅ Verifying installations..."
go version
docker --version
kubectl version --client
helm version
kind version

# Initialize Go modules
echo "📋 Initializing Go modules..."
go mod tidy

# Create kind cluster and deploy
echo "🏗️ Creating kind cluster and deploying kubeview..."
make cluster
make setup

echo "🎉 Setup complete! Kubeview is ready for development."
echo "🔗 Access the service at http://localhost:8080 after port-forwarding"
