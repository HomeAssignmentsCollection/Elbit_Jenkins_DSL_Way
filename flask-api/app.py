from flask import Flask, jsonify
import docker
import os

app = Flask(__name__)


# Security: Check if Docker socket is available and accessible
def get_docker_client():
    try:
        if not os.path.exists("/var/run/docker.sock"):
            return None, "Docker socket not found"

        client = docker.from_env()
        client.ping()
        return client, None
    except docker.errors.DockerException as e:
        return None, (f"Docker connection failed: {str(e)}")
    except Exception as e:
        return None, (f"Unexpected error: {str(e)}")


client, client_error = get_docker_client()


@app.route("/api/containers", methods=["GET"])
def list_containers():
    if not client:
        return (
            jsonify(
                {
                    "error": "Docker client unavailable",
                    "details": client_error,
                    "containers": [],
                }
            ),
            503,
        )

    try:
        containers = client.containers.list()
        response = []
        for container in containers:
            response.append(
                {
                    "id": container.short_id,
                    "name": container.name,
                    "image": (
                        container.image.tags[0] if container.image.tags else "unknown"
                    ),
                    "status": container.status,
                }
            )
        return jsonify({"containers": response, "count": len(response)})
    except Exception as e:
        return jsonify({"error": str(e), "containers": []}), 500


# ✅ Add this to fix healthcheck
@app.route("/health")
def health():
    return "OK", 200


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)


# from flask import Flask, jsonify
# import docker
# import os

# app = Flask(__name__)

# # Security: Check if Docker socket is available and accessible
# def get_docker_client():
#     try:
#         # Check if Docker socket exists and is accessible
#         if not os.path.exists('/var/run/docker.sock'):
#             return None, "Docker socket not found"

#         client = docker.from_env()
#         # Test connection
#         client.ping()
#         return client, None
#     except docker.errors.DockerException as e:
#         return None, f"Docker connection failed: {str(e)}"
#     except Exception as e:
#         return None, f"Unexpected error: {str(e)}"

# # Initialize Docker client
# client, client_error = get_docker_client()

# @app.route('/api/containers', methods=['GET'])
# def list_containers():
#     if not client:
#         return jsonify({
#             'error': 'Docker client unavailable',
#             'details': client_error,
#             'containers': []
#         }), 503

#     try:
#         containers = client.containers.list()
#         response = []
#         for container in containers:
#             response.append({
#                 'id': container.short_id,
#                 'name': container.name,
#                 'image': container.image.tags[0] if container.image.tags else 'unknown',
#                 'status': container.status
#             })
#         return jsonify({
#             'containers': response,
#             'count': len(response)
#         })
#     except Exception as e:
#         return jsonify({
#             'error': 'Failed to list containers',
#             'details': str(e),
#             'containers': []
#         }), 500

# @app.route('/health', methods=['GET'])
# def health_check():
#     """Health check endpoint for Kubernetes probes"""
#     if not client:
#         return jsonify({'status': 'unhealthy', 'error': client_error}), 503

#     try:
#         # Test Docker connection
#         client.ping()
#         return jsonify({'status': 'healthy'}), 200
#     except Exception as e:
#         return jsonify({'status': 'unhealthy', 'error': str(e)}), 503

# if __name__ == '__main__':
#     # Security: Use environment variable for host binding
#     host = os.environ.get('FLASK_HOST', '0.0.0.0')
#     port = int(os.environ.get('FLASK_PORT', 5000))

#     # Run on all interfaces, in production use gunicorn or uwsgi
#     app.run(host=host, port=port, debug=False)


# # from flask import Flask, jsonify
# # import docker

# # app = Flask(__name__)
# # client = docker.from_env()

# # @app.route('/api/containers', methods=['GET'])
# # def list_containers():
# #     containers = client.containers.list()
# #     response = []
# #     for container in containers:
# #         response.append({
# #             'id': container.short_id,
# #             'name': container.name,
# #             'image': container.image.tags
# #         })
# #     return jsonify(response)

# # if __name__ == '__main__':
# #     app.run(host='0.0.0.0', port=5000)
