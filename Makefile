.PHONY: deps build image load deploy helm test clean

# Variables (because hardcoding is for amateurs)
IMAGE_NAME := kubeview
IMAGE_TAG := latest
CLUSTER_NAME := kubeview-cluster

# Get your Go modules sorted
deps:
	@echo "📦 Downloading dependencies (this might take a sec)..."
	go mod tidy

# Build the binary (the fun part)
build:
	@echo "🔨 Building kubeview binary..."
	mkdir -p bin
	go build -o bin/kubeview ./cmd
	@echo "✅ Binary ready in bin/ (it's probably huge, that's normal)"

# Build Docker image (containerize all the things)
image:
	@echo "🐳 Building Docker image..."
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) .
	@echo "✅ Image built: $(IMAGE_NAME):$(IMAGE_TAG)"

# Load image into kind cluster (because kind is picky)
load:
	@echo "📤 Loading image into kind cluster..."
	kind load docker-image $(IMAGE_NAME):$(IMAGE_TAG) --name $(CLUSTER_NAME)

# Deploy using raw Kubernetes manifests (old school)
deploy:
	@echo "🚀 Deploying to Kubernetes..."
	kubectl apply -f k8s/
	@echo "✅ Deployed! (hopefully)"

# Deploy using Helm (the fancy way)
helm:
	@echo "⛵ Deploying with Helm..."
	helm upgrade --install kubeview ./helm/kubeview --create-namespace --namespace kubeview
	@echo "✅ Helm deployment complete!"

# Test the deployment (cross your fingers)
test:
	@echo "🧪 Testing kubeview deployment..."
	@echo "⏳ Starting port-forward in background..."
	kubectl port-forward service/kubeview 8080:80 &
	sleep 5
	@echo "🏠 Testing home endpoint..."
	curl -f http://localhost:8080/ || (echo "❌ Home endpoint failed" && exit 1)
	@echo "🏥 Testing health endpoint..."
	curl -f http://localhost:8080/health || (echo "❌ Health check failed" && exit 1)
	@echo "📊 Testing metrics endpoint..."
	curl -f http://localhost:8080/metrics || (echo "❌ Metrics check failed" && exit 1)
	@echo "🎉 All tests passed! You're good to go."
	pkill -f "kubectl port-forward" || true

# Clean up everything (nuclear option)
clean:
	@echo "🧹 Cleaning up everything..."
	kind delete cluster --name $(CLUSTER_NAME) || true
	docker rmi $(IMAGE_NAME):$(IMAGE_TAG) || true
	rm -rf bin/
	@echo "✅ All clean! (like it never happened)"

# Create kind cluster (your local playground)
cluster:
	@echo "🏗️  Creating kind cluster..."
	kind create cluster --name $(CLUSTER_NAME)
	@echo "✅ Cluster ready! Welcome to your local Kubernetes playground."

# Full setup (the lazy developer's dream)
setup: cluster deps build image load deploy
	@echo "🎯 Full setup complete! Run 'make test' to verify everything works."

# Helm setup (for the organized folks)
helm-setup: cluster deps build image load helm
	@echo "🎯 Helm setup complete! Your service should be running."
