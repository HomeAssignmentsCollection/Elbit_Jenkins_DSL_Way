# 🔍 Distributed Tracing (Jaeger, OpenTelemetry)

## 1. Why is tracing needed?
- Diagnostics of slow requests and errors
- Correlation of requests between services
- Performance analysis and bottlenecks

## 2. Jaeger Installation via Helm
```bash
helm repo add jaegertracing https://jaegertracing.github.io/helm-charts
helm repo update
helm upgrade --install jaeger jaegertracing/jaeger --namespace tracing --create-namespace
```

## 3. Integration with Flask
- Install dependencies:
  ```bash
  pip install opentelemetry-api opentelemetry-sdk opentelemetry-instrumentation-flask opentelemetry-exporter-jaeger
  ```
- Example code:
  ```python
  from opentelemetry.instrumentation.flask import FlaskInstrumentor
  from opentelemetry.exporter.jaeger.thrift import JaegerExporter
  from opentelemetry.sdk.trace import TracerProvider
  from opentelemetry.sdk.trace.export import BatchSpanProcessor
  from opentelemetry import trace

  app = Flask(__name__)
  FlaskInstrumentor().instrument_app(app)

  trace.set_tracer_provider(TracerProvider())
  jaeger_exporter = JaegerExporter(
      agent_host_name="jaeger.tracing.svc.cluster.local",
      agent_port=6831,
  )
  span_processor = BatchSpanProcessor(jaeger_exporter)
  trace.get_tracer_provider().add_span_processor(span_processor)
  ```
- Restart the application

## 4. Viewing Tracing
- Port-forward Jaeger UI:
  ```bash
  kubectl port-forward svc/jaeger-query -n tracing 16686:16686
  ```
- Open http://localhost:16686

## 5. Best Practices
- Add trace_id/request_id to logs
- Use auto-instrumentation for all services
- Configure sampling (default 100%)
- Enable alerts for slow/error tracing spans

## 6. Useful Links
- [Jaeger Docs](https://www.jaegertracing.io/docs/)
- [OpenTelemetry Python](https://opentelemetry.io/docs/instrumentation/python/) 