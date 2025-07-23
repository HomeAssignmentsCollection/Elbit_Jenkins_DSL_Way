# CI/CD & Kubernetes Home Assignment

## ⏱ Timeline
Estimated time spent: **2–3 hours**

---

## 📌 Task Overview

You are asked to implement a multi-step CI/CD and DevOps workflow using Jenkins, Docker, and Kubernetes (including KEDA). The required steps:

1. Use **Job DSL** to create three Jenkins pipeline jobs.
2. First job:
   - Pulls Flask-based app from GitHub
   - Builds a Docker image and pushes to DockerHub
   - Flask app lists running Docker containers
3. Second job:
   - Builds a modified NGINX container
   - Adds proxy_pass to Flask container
   - Injects source IP into headers
   - Pushes image to DockerHub
4. Third job:
   - Runs both containers
   - Exposes only NGINX port
   - Sends curl request to verify full flow
5. Deploy to Kubernetes:
   - One app must use volume
   - Apply **KEDA autoscaling**

---

## 🧱 Architecture & CI/CD Structure

### 🧩 Jenkins Job DSL
- A single `jobs.groovy` script creates three pipeline jobs.
- Each job pulls a dedicated `Jenkinsfile` from GitHub.
- Jobs are parameterized for flexibility.

### 📦 Docker Images
- Flask App:
  - Python app using Docker SDK to list running containers (`/api/containers`)
  - Multi-stage Dockerfile with non-root user and `HEALTHCHECK`
- NGINX Proxy:
  - Default image extended with custom `nginx.conf`
  - Adds proxy_pass to Flask container with `proxy_set_header X-Forwarded-For $remote_addr;`

### ✅ CI/CD Flow
- Job 1: Build & push Flask image
- Job 2: Build & push NGINX proxy image
- Job 3:
  - Run both containers locally in isolated Docker network
  - Expose only NGINX
  - Send request to proxy → Flask → Docker engine
  - Verify response (200 OK + JSON)

---

## ☸️ Kubernetes + KEDA Deployment

- Deployed using **Minikube** (local K8s cluster)
- Manifests include:
  - Deployment + Service for both apps
  - `emptyDir` volume attached to Flask
  - Probes for readiness/liveness
- **KEDA** configured with:
  - TriggerAuthentication
  - ScaledObject based on CPU or HTTP requests

---

## ⚙️ Technologies Used

- Jenkins + Job DSL
- Docker (multi-stage, healthchecks, networks)
- Flask + Docker SDK
- NGINX
- Kubernetes (with `kubectl apply`)
- KEDA
- Bash scripting for local runs

---

## 📁 Delivered Files

- `jobs.groovy`: Jenkins Job DSL definition
- `Jenkinsfile.api`: Flask app pipeline
- `Jenkinsfile.proxy`: NGINX proxy pipeline
- `Jenkinsfile.test`: Local run and verification
- `Dockerfile.api`, `Dockerfile.proxy`
- `nginx.conf`: custom proxy configuration
- `k8s/`: Kubernetes manifests for deployment
- `README.md`: this file
- `ProjectAnalysis.md`: rationale behind key decisions

---

## 📌 Key Design Decisions

- Used **declarative Jenkins pipelines** for readability and structure
- Containers communicate over **custom bridge network**
- No use of `docker-compose` — pure CLI scripts
- `proxy_set_header` used to inject source IP into the Flask app
- Health and readiness probes ensure production safety
- Scripts and manifests use **parameterized, reusable patterns**

---

## 🚫 Not Included

While the following were considered, they are **out of scope for the 2–3h assignment**:
- Terraform-based provisioning of K8s cluster and registry
- GitHub Actions CI
- PR validation and GitHub branch protection rules
- Persistent volume claims
- TLS termination and ingress controller in K8s

---

## 🧪 Testing & Limitations

- The pipeline logic was built to be **production-aligned** and **modular**
- All local runs validated using `curl`, container logs, and port checks
- Due to local resource constraints, K8s load testing was limited
- Can be deployed live upon request if remote infra is available

---

## 🧠 Final Notes

This assignment demonstrates:
- Strong CI/CD design using Jenkins and Docker
- Secure and optimized Dockerfiles
- Kubernetes deployment with auto-scaling
- Thoughtful, reproducible structure aligned with DevOps best practices 