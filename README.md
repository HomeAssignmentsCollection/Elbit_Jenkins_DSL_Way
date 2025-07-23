# 🚀 CI/CD Assignment — Flask API + Nginx + Jenkins + Kubernetes + KEDA

This project implements a full CI/CD pipeline using Jenkins, Docker, and Kubernetes.  
It builds and tests a Flask application that interacts with Docker, wraps it in a reverse proxy via Nginx, and deploys everything into a Kubernetes cluster with KEDA-based autoscaling.

---

## 🧱 Project Structure
```
ci-cd-assignment/
├── job-dsl/ # Jenkins Job DSL Groovy script
├── flask-api/ # Flask app, Dockerfile, Jenkinsfile
├── nginx-proxy/ # Nginx reverse proxy, Dockerfile, Jenkinsfile
├── runner-job/ # Jenkins pipeline to run and verify locally
├── k8s/ # K8s manifests: deployments, services, KEDA
├── scripts/ # Helper scripts for minikube, curl test
├── terraform/ # (Optional) infra-as-code
├── README.md # This file
└── .gitignore
```

---

## 📌 Jenkins Jobs (created by DSL)

Run the **seed job** pointing to:  
`job-dsl/jobs.groovy`

This will generate:

- `build-python-api`
- `build-nginx-proxy`
- `run-local-containers`

Each job is parameterized (image name, tag, etc.).

---

## 🐍 Flask API

- Exposes `/api/containers`
- Uses Docker SDK to list running containers
- Built via multi-stage, non-root Dockerfile
- Healthcheck and probes included

---

## 🌐 Nginx Proxy

- Routes `/api/` to the Flask app
- Injects `X-Forwarded-For` and `X-Real-IP` headers
- Minimal Alpine image, non-root, with healthcheck

---

## 🛡️ Pre-commit Hooks

This project uses [pre-commit](https://pre-commit.com/) to automate code checks before every commit. Pre-commit hooks help ensure code quality, style, and security by running linters and other tools automatically.

**What is checked:**
- Python formatting (`black`), linting (`flake8`), and import sorting (`isort`)
- YAML syntax and style (`yamllint`)
- Shell script analysis (`shellcheck`)
- Dockerfile best practices (`hadolint`)
- Secret detection (`detect-secrets`)

**How to set up:**
1. Install pre-commit (once):
   ```bash
   pip install pre-commit
   ```
2. Install hooks into your git repo (once):
   ```bash
   pre-commit install
   ```
3. (Optional) Run all hooks on all files:
   ```bash
   pre-commit run --all-files
   ```

If you see errors, fix them and recommit. This helps keep the codebase clean and secure!

## 🛡️ DevSecOps & Security Best Practices

- Non-root containers, drop capabilities, read-only rootfs
- RBAC, NetworkPolicy, resource quotas, namespace isolation
- ConfigMap and Secrets for configuration
- Admission control (OPA/Kyverno — recommended)
- Image scanning (Trivy, Dockle — recommended)
- Health endpoints, probes, graceful degradation

See more: [SECURITY.md](SECURITY.md)

---

## 📈 Observability: Monitoring, Logging, Tracing

- **Monitoring**: Prometheus + Grafana + Alertmanager (Helm chart, automation)
- **Logging**: stdout + shipping to EFK/Opensearch (recommended)
- **Tracing**: Jaeger/Tempo (recommended)
- Health endpoints, probes, alerts

See more:
- [MONITORING.md](docs/MONITORING.md)
- [LOGGING.md](docs/LOGGING.md)
- [TRACING.md](docs/TRACING.md)

---

## 📝 Runbooks & Disaster Recovery

- Backup/restore: PVC, etcd, images, configs
- Rollback: kubectl rollout undo, Helm rollback
- Troubleshooting: kubectl logs, describe, events, Prometheus/Grafana

See more: [RUNBOOKS.md](docs/RUNBOOKS.md)

---

## 📚 Architecture and Documentation

- [ARCHITECTURE.md](docs/ARCHITECTURE.md) — diagrams, flow description, CI/CD, security
- [RUNBOOKS.md](docs/RUNBOOKS.md) — launch, update, recovery, troubleshooting
- [MONITORING.md](docs/MONITORING.md) — monitoring, alerts
- [LOGGING.md](docs/LOGGING.md) — centralized logging
- [TRACING.md](docs/TRACING.md) — distributed tracing
- [SECURITY.md](SECURITY.md) — security measures
- [STATIC_ANALYSIS_TOOLS.md](STATIC_ANALYSIS_TOOLS.md) — static analysis
- [TASK_AND_SOLUTION.md](TASK_AND_SOLUTION.md) — task and solution
- [ProjectAnalysis.md](ProjectAnalysis.md) — architecture analysis, recommendations

---

## ⚠️ Limitations and Areas for Improvement

- Secrets management: Vault or similar is recommended
- No unit tests or detailed API documentation
- No production-grade disaster recovery (basic runbooks only)
- No TLS/Ingress (out of scope)
- No automation via Terraform (folder prepared)

---

## ☸️ Kubernetes Setup (minikube)

### 1. Start Cluster

scripts/run_minikube.sh
Requires: Docker and minikube installed

2. Create Namespace
kubectl apply -f k8s/namespace.yaml

3. Install KEDA
k8s/keda-install.sh

4. Deploy Application
```bash
# Option 1: Deploy all resources at once
./scripts/deploy-all.sh

# Option 2: Deploy manually (in order)
kubectl apply -f k8s/namespace.yaml
kubectl apply -f k8s/resource-quota.yaml
kubectl apply -f k8s/rbac.yaml
kubectl apply -f k8s/configmap.yaml
kubectl apply -f k8s/flask-service.yaml
kubectl apply -f k8s/service.yaml
kubectl apply -f k8s/flask-deployment.yaml
kubectl apply -f k8s/nginx-deployment.yaml
kubectl apply -f k8s/network-policy.yaml
kubectl apply -f k8s/keda-scaledobject.yaml
```

5. Port Forward and Test
scripts/port-forward.sh

'Then open in browser or run:'
scripts/test-api.sh

Expected output: list of container IDs running in the cluster (including itself and nginx).

🧪 Local Test via Jenkins
Run job: run-local-containers
This job will:

Start both containers in Docker
Verify connectivity via curl
Clean up everything automatically

🔐 Prerequisites
Jenkins with Docker and Job DSL Plugin
Docker Hub credentials in Jenkins (ID: dockerhub-creds)
docker, kubectl, jq, curl installed

🛡️ Security Features
- Non-root containers with security contexts
- Network policies for pod-to-pod communication
- RBAC with minimal required permissions
- Resource quotas and limits
- Health checks and monitoring
- ConfigMaps and Secrets for configuration management

⚠️ Important: Docker socket access is disabled by default for security. See SECURITY.md for details.

📦 Optional: Terraform
A terraform/ folder is prepared for possible future automation of:
Docker network and container startup
Kubernetes provisioning

✅ Status
This project is self-contained and reproducible.
To test it:

Start from DSL seed job
Trigger pipelines
Deploy and verify in K8s

👤 Author
Illia Rizvash
Email: rizvash.i@gmail.com
LinkedIn: linkedin.com/in/ilya-rizvash
