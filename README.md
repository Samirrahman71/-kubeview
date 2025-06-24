# kubeview 👀

*My first real Kubernetes project as an SRE intern*

## 🚀 Live Demo

**Check it out live!** → [https://kubeview-first-go-deployment.windsurf.build](https://kubeview-first-go-deployment.windsurf.build)

This is my actual first Go deployment running on Netlify! The app features:


*Status: LIVE and working! (my first go deployment)

## Background

Hey! I'm Samir, an SRE intern, and this is my personal project to actually understand how Kubernetes and Docker work together. Instead of just reading docs and tutorials, I wanted to build something from scratch and deploy it properly.

My mentor kept talking about "containerization" and "orchestration" but honestly, it didn't click until I started building this. Now I get why everyone's obsessed with K8s!

## What I'm learning

This project helped me understand:

- **Go web services**: How to build a simple HTTP server that doesn't crash
- **Docker**: Multi-stage builds, Alpine images, and why container size matters
- **Kubernetes**: Deployments, services, health probes, and why YAML is everywhere
- **Helm**: Package management for K8s (game changer!)
- **Observability**: Prometheus metrics and why monitoring is crucial in production

## What this thing does

It's intentionally simple because I'm still learning:

- Serves HTTP requests on configurable port (default 8080)
- Has a `/health` endpoint for Kubernetes health checks
- Exposes `/metrics` for Prometheus (my first time implementing this!)
- Runs in Docker containers
- Deploys to Kubernetes with proper resource management

## My learning setup

You'll need these tools (took me a while to get them all working):

- **Go 1.21+** - For building the service
- **Docker** - For containerization 
- **kubectl** - Kubernetes command line tool
- **kind** - Local Kubernetes clusters (way easier than minikube for learning)
- **helm** - Package manager for Kubernetes

## Running locally (baby steps)

First, let's just run it on your machine:

```bash
# Get dependencies
go mod tidy

# Build the binary
go build -o bin/kubeview ./cmd

# Run it
./bin/kubeview
```

Visit `http://localhost:8080` - if you see a message, you're good!

## Docker journey

Learning Docker was confusing at first, but here's what I figured out:

```bash
# Build the image (this creates layers - still wrapping my head around that)
docker build -t kubeview:latest .

# Run it in a container
docker run -p 8080:8080 kubeview:latest
```

The Dockerfile uses multi-stage builds (my mentor insisted on this for production readiness):
- **Stage 1**: Build the Go binary in a full Go environment
- **Stage 2**: Copy just the binary to a minimal Alpine image

This keeps the final image small (~20MB vs 800MB+).

## Kubernetes deployment (the real learning)

This is where it gets interesting. I'm using `kind` for local testing:

```bash
# Create a local cluster (still amazed this works on my laptop)
kind create cluster --name kubeview-cluster

# Build and load the image
docker build -t kubeview:latest .
kind load docker-image kubeview:latest --name kubeview-cluster

# Deploy to Kubernetes
kubectl apply -f k8s/

# Check if it's running
kubectl get pods
kubectl get services
```

### What I learned about K8s manifests:

**Deployment** (`k8s/deployment.yaml`):
- Defines how many replicas I want (starting with 1)
- Sets up health probes (liveness and readiness)
- Configures resource limits (still learning about this)

**Service** (`k8s/service.yaml`):
- Exposes the deployment internally
- Maps port 80 to container port 8080
- Uses ClusterIP (internal only for now)

## Helm charts (level up!)

Raw YAML gets messy fast. Helm makes it manageable:

```bash
# Validate the chart
helm lint ./helm/kubeview

# See what would be deployed
helm install kubeview ./helm/kubeview --dry-run --debug

# Actually deploy it
helm upgrade --install kubeview ./helm/kubeview --create-namespace --namespace kubeview
```

### Helm values I can customize:

```yaml
# values.yaml
replicaCount: 1          # How many pods
image:
  repository: kubeview   # Image name
  tag: latest           # Image version
service:
  type: ClusterIP       # Service type
  port: 80             # External port
```

Example: Deploy 3 replicas with LoadBalancer:
```bash
helm upgrade --install kubeview ./helm/kubeview \
  --set replicaCount=3 \
  --set service.type=LoadBalancer
```

## Testing my deployment

```bash
# Port forward to access the service
kubectl port-forward service/kubeview 8080:80

# Test the endpoints
curl http://localhost:8080/          # Home page
curl http://localhost:8080/health    # Health check
curl http://localhost:8080/metrics   # Prometheus metrics
```

## What I learned the hard way

**Docker gotchas:**
- Layer caching is your friend (and enemy when debugging)
- Alpine images are tiny but sometimes missing tools
- Multi-stage builds save tons of space

**Kubernetes surprises:**
- Pods can restart without warning (hence health checks)
- Services don't automatically update when pods change
- YAML indentation will ruin your day

**Helm insights:**
- Templates are powerful but can get complex
- Values files make deployments repeatable
- `--dry-run` saves you from broken deployments

## Project structure

```
.
├── cmd/main.go                    # The Go service
├── k8s/                          # Raw Kubernetes manifests
│   ├── deployment.yaml           # Pod definition
│   └── service.yaml              # Service definition
├── helm/kubeview/                # Helm chart
│   ├── Chart.yaml                # Chart metadata
│   ├── values.yaml               # Default values
│   └── templates/                # YAML templates
├── Dockerfile                    # Multi-stage container build
├── Makefile                      # Automation scripts
└── go.mod                        # Go dependencies
```

## 🌐 Web Deployment (Plot Twist!)

While this was originally built for Kubernetes, I also deployed it as a web app because... why not? 

**Live URL**: https://kubeview-first-go-deployment.windsurf.build

### What I learned about serverless:
- Converted the Go HTTP server to Netlify Functions
- Created a beautiful frontend with gradients (because 2025 vibes)
- Used serverless Go functions for `/api/health` and `/api/metrics`
- Deployed with a single command (mind = blown)

The web version still has all the personality:
- Health checks that say "Still breathing" 
- Metrics with fake Prometheus data
- The same "my first go deployment lololol" energy
- But now with a fancy UI that doesn't look like 1995

### Deployment was surprisingly easy:
```bash
# Just needed these files:
netlify.toml           # Configuration
public/index.html      # Frontend
netlify/functions/     # Go serverless functions

# Then one command:
netlify deploy --prod
```

This taught me that the same Go code can work in multiple environments - containers, Kubernetes, AND serverless! 🤯

## Next steps in my learning

Things I want to add:
- [ ] Ingress controller for external access
- [ ] ConfigMaps and Secrets management
- [ ] Horizontal Pod Autoscaling
- [ ] Persistent volumes (when I need storage)
- [ ] CI/CD pipeline with GitHub Actions
- [ ] Better monitoring and alerting

## Resources that helped me

- [Kubernetes Documentation](https://kubernetes.io/docs/) - Official docs
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/) - Container optimization
- [Helm Documentation](https://helm.sh/docs/) - Package management
- My mentor's patience with my endless questions!

## Running this yourself

If you're also learning, feel free to clone this and experiment:

```bash
git clone https://github.com/Samirrahman71/-kubeview.git
cd -kubeview

# If you have make (Linux/Mac)
make cluster setup test

# If you're on Windows like me
go build -o bin/kubeview.exe ./cmd
docker build -t kubeview:latest .
kind create cluster --name kubeview-cluster
kind load docker-image kubeview:latest --name kubeview-cluster
kubectl apply -f k8s/
```

## Questions or suggestions?

I'm still learning, so if you spot something I could do better or have questions about my approach, feel free to open an issue! Learning together is way more fun.

---

*Built during my SRE internship while trying to understand why everyone loves Kubernetes so much. Spoiler: I get it now!*
