# 🛠️ Runbooks: Troubleshooting, Recovery, Update

## 1. Startup and Update

### First Launch
1. Install dependencies: Docker, kubectl, minikube, helm, terraform (see install_prerequisites.sh)
2. Start minikube: `minikube start`
3. Deploy infrastructure: `./scripts/deploy-all.sh`
4. Check status: `kubectl get pods -n ci-cd-app`
5. Test API: `curl http://localhost:8080/api/containers`

### Application Update
1. Make changes to code/manifests
2. Rebuild images: Jenkins pipeline or `docker compose build`
3. Load images into minikube: `minikube image load ...`
4. Apply new manifests: `kubectl apply -f k8s/`
5. Check rollout: `kubectl rollout status deployment/<name> -n ci-cd-app`

## 2. Troubleshooting

### Pod Issues
- `kubectl get pods -n ci-cd-app`
- `kubectl describe pod <pod> -n ci-cd-app`
- `kubectl logs <pod> -n ci-cd-app`

### Network Issues
- Check services: `kubectl get svc -n ci-cd-app`
- Check NetworkPolicy: `kubectl get networkpolicy -n ci-cd-app`
- Check API availability: `curl http://localhost:8080/`

### Deployment Issues
- Rollback: `kubectl rollout undo deployment/<name> -n ci-cd-app`
- Helm rollback: `helm rollback <release> <revision>`

## 3. Disaster Recovery

### Backup
- PVC: `kubectl get pvc -n ci-cd-app`
- etcd: regular snapshots (if self-hosted)
- Docker images: store in registry
- Manifests and configs: git

### Restore
- Restore PVC: `kubectl apply -f <pvc-backup>.yaml`
- Restore images: `docker pull ...`
- Apply manifests: `kubectl apply -f k8s/`

### Post-Failure Recovery
- Check cluster state: `kubectl get nodes,pods,svc -A`
- Restart pods: `kubectl delete pod <pod> -n ci-cd-app`
- Check logs: `kubectl logs <pod> -n ci-cd-app`
- Check alerts in Grafana/Alertmanager

## 4. Incidents and Typical Scenarios

### Secret Leak
- Change secret in Vault/K8s Secrets
- Restart pods
- Audit access

### Deployment Failure
- Rollback to previous version
- Check logs and metrics
- Notify team via Alertmanager/Slack

### Data Loss
- Restore from backup
- Check data integrity

---

## Useful Commands
- `kubectl get all -n ci-cd-app`
- `kubectl top pods -n ci-cd-app`
- `kubectl get events -n ci-cd-app`
- `kubectl auth can-i --list -n ci-cd-app` 