from flask import Flask, jsonify

app = Flask(__name__)


@app.route("/api/containers", methods=["GET"])
def list_containers():
    # Mock response for testing when Docker is not available
    return jsonify(
        [
            {
                "id": "test123",
                "name": "test-container",
                "image": ["test-image:latest"],
                "status": "running",
            },
            {
                "id": "test456",
                "name": "flask-api",
                "image": ["flask-docker-api:latest"],
                "status": "running",
            },
        ]
    )


@app.route("/health", methods=["GET"])
def health_check():
    return jsonify({"status": "healthy", "message": "Flask API is running"})


@app.route("/", methods=["GET"])
def root():
    return jsonify(
        {"message": "Flask Docker API", "endpoints": ["/api/containers", "/health"]}
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
