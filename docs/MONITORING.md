# 📊 Monitoring & Alerting

## 1. Prometheus + Grafana + Alertmanager (Helm)

### Installation via Helm
```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Prometheus + Alertmanager
helm upgrade --install prometheus prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --set grafana.enabled=true

# Check status
kubectl get pods -n monitoring

# Get Grafana password
kubectl get secret --namespace monitoring prometheus-grafana -o jsonpath="{.data.admin-password}" | base64 --decode ; echo

# Port-forward for Grafana access
kubectl port-forward svc/prometheus-grafana -n monitoring 3000:80
```

### Dashboards and Alerts
- Import dashboards from Grafana Marketplace (Kubernetes, Docker, Nginx, Flask)
- Set up alerts for:
  - Pod/service availability
  - Log errors
  - High load (CPU, memory)
  - Anomalies (slow requests, spike errors)
- Alertmanager: email, Slack, Telegram

## 2. Logging (EFK/Opensearch)

### EFK Installation via Helm
```bash
helm repo add elastic https://helm.elastic.co
helm repo update
helm upgrade --install elasticsearch elastic/elasticsearch --namespace logging --create-namespace
helm upgrade --install kibana elastic/kibana --namespace logging
helm upgrade --install fluentd stable/fluentd --namespace logging
```

### Log Shipping
- Fluentd/Fluentbit sidecar or DaemonSet
- Example configuration:
```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluentd-config
  namespace: logging
data:
  fluent.conf: |
    <source>
      @type tail
      path /var/log/containers/*.log
      pos_file /var/log/fluentd-containers.log.pos
      tag kube.*
      format json
    </source>
    <match **>
      @type elasticsearch
      host elasticsearch.logging.svc.cluster.local
      port 9200
      logstash_format true
    </match>
```

## 3. Distributed Tracing (Jaeger)

### Jaeger Installation via Helm
```bash
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm repo update
helm upgrade --install jaeger jaegertracing/jaeger --namespace tracing --create-namespace
```

### Integration with Flask
- Use opentelemetry-instrumentation-flask
- Example:
```python
from opentelemetry.instrumentation.flask import FlaskInstrumentor
FlaskInstrumentor().instrument_app(app)
```

---

## 4. Example Alerts (PrometheusRule)
```yaml
apiVersion: monitoring.coreos.com/v1
kind: PrometheusRule
metadata:
  name: flask-api-alerts
  namespace: monitoring
spec:
  groups:
    - name: flask-api.rules
      rules:
        - alert: FlaskApiDown
          expr: kube_deployment_status_replicas_unavailable{deployment="flask-api"} > 0
          for: 2m
          labels:
            severity: critical
          annotations:
            summary: "Flask API deployment is down"
            description: "No available replicas for Flask API deployment."
```

---

## 5. Useful Links
- [Prometheus Helm Chart](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)
- [Grafana Dashboards](https://grafana.com/grafana/dashboards)
- [EFK Stack](https://www.elastic.co/what-is/efk-stack)
- [Jaeger Tracing](https://www.jaegertracing.io/docs/) 