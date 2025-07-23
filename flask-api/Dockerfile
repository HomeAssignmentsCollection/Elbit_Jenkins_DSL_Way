# --- Stage 1: Builder ---
FROM python:3.11-slim AS builder

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc=4:10.2.0-1+build2 \
    libffi-dev=3.3-4 \
    curl=7.74.0-1.3+deb11u7 \
    && rm -rf /var/lib/apt/lists/*

RUN pip install --upgrade pip==23.3.1

COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

COPY app.py .

# --- Stage 2: Runtime ---
FROM python:3.11-slim

RUN useradd --create-home --shell /bin/bash appuser

WORKDIR /app

COPY --from=builder /install /usr/local
COPY --from=builder /app /app

RUN chown -R appuser:appuser /app
USER appuser

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD curl --fail http://localhost:5000/api/containers || exit 1

ENTRYPOINT ["python", "app.py"]


# # ------------------------------------------------------------------------------
# # Multi-stage Dockerfile for Flask API
# # - Stage 1: Installs Python deps using build tools
# # - Stage 2: Minimal image with Flask app and a non-root user
# # ------------------------------------------------------------------------------

# # === Stage 1: Builder ===
# FROM python:3.11-slim AS builder

# WORKDIR /app

# # Ensure repeatable builds
# ENV PYTHONDONTWRITEBYTECODE=1
# ENV PYTHONUNBUFFERED=1

# # Install build dependencies
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     gcc \
#     libffi-dev \
#     curl \
#     && rm -rf /var/lib/apt/lists/*

# # Upgrade pip
# RUN pip install --upgrade pip

# # Install Python dependencies to a temporary prefix
# COPY requirements.txt .
# RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# # Copy source
# COPY app.py .

# # === Stage 2: Runtime ===
# FROM python:3.11-slim

# # Add app user
# RUN useradd --create-home --shell /bin/bash appuser

# WORKDIR /app

# # Copy installed packages and app source
# COPY --from=builder /install /usr/local
# COPY --from=builder /app /app

# # Set permissions
# RUN chown -R appuser:appuser /app
# USER appuser

# EXPOSE 5000

# # Healthcheck (requires curl or use wget --spider)
# HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
#   CMD curl --fail http://localhost:5000/api/containers || exit 1

# ENTRYPOINT ["python", "app.py"]



# # # ------------------------------------------------------------------------------
# # # Multi-stage Dockerfile for Flask API
# # # - Stage 1 installs Python dependencies with build tools
# # # - Stage 2 is a minimal runtime with only what is needed
# # # - Uses non-root user for security
# # # ------------------------------------------------------------------------------

# # # === Stage 1: Builder ===
# # FROM python:3.11-slim AS builder

# # WORKDIR /app

# # ENV PYTHONDONTWRITEBYTECODE=1
# # ENV PYTHONUNBUFFERED=1

# # RUN apt-get update && apt-get install -y --no-install-recommends \
# #     gcc \
# #     && pip install --upgrade pip

# # COPY requirements.txt .
# # RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# # COPY app.py .

# # # === Stage 2: Runtime Image ===
# # FROM python:3.11-slim

# # RUN useradd --create-home appuser

# # WORKDIR /app

# # COPY --from=builder /install /usr/local
# # COPY --from=builder /app /app

# # RUN chown -R appuser:appuser /app
# # USER appuser

# # EXPOSE 5000

# # HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
# #   CMD curl --fail http://localhost:5000/api/containers || exit 1

# # ENTRYPOINT ["python", "app.py"]

