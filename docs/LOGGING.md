# 📑 Centralized Logging (EFK/Opensearch)

## 1. Logging Architecture

- All applications write logs to stdout/stderr
- Fluentd/Fluentbit DaemonSet collects logs from nodes
- Logs are sent to Elasticsearch/Opensearch
- Kibana/Opensearch Dashboards for search and visualization

## 2. EFK Installation via Helm
```bash
helm repo add elastic https://helm.elastic.co
helm repo update
helm upgrade --install elasticsearch elastic/elasticsearch --namespace logging --create-namespace
helm upgrade --install kibana elastic/kibana --namespace logging
helm upgrade --install fluentd stable/fluentd --namespace logging
```

## 3. Shipping logs from pods

### Fluentd/Fluentbit DaemonSet
- Collects logs from /var/log/containers/*.log
- Example configuration — see MONITORING.md

### Sidecar logging (optional)
- For critical services, you can use a sidecar container for logging

## 4. Best Practices
- Log only to stdout/stderr (12-factor)
- Use structured logs (JSON)
- Add trace_id/request_id for correlation
- Limit log volume (log rotation)
- Set up alerts for error/exception spikes

## 5. Troubleshooting
- Check DaemonSet status: `kubectl get ds -n logging`
- Check Fluentd logs: `kubectl logs <fluentd-pod> -n logging`
- Check Elasticsearch/Kibana availability
- Check that logs appear in Kibana

## 6. Useful Links
- [EFK Stack](https://www.elastic.co/what-is/efk-stack)
- [Fluentd Docs](https://docs.fluentd.org/)
- [Opensearch](https://opensearch.org/) 