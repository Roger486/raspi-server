#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

# -------------------------------
# Configuration (hardcoded here for simplicity)
# -------------------------------

# Project info
PROJECT_NAME="roger-portfolio"
SERVICE_NAME="frontend"

# Construct names from convention
CONTAINER_NAME="${PROJECT_NAME}-${SERVICE_NAME}"      # => roger-portfolio-frontend
IMAGE_NAME="${PROJECT_NAME}-${SERVICE_NAME}"          # => roger-portfolio-frontend

# Detect system user (supports sudo)
USER_NAME="${SUDO_USER:-$USER}"

# Path to the React project (must contain Dockerfile and nginx.conf)
PROJECT_DIR="/home/$USER_NAME/projects/front/react/${PROJECT_NAME}"

# Port on the Raspberry Pi to expose the app (maps to port 80 inside the container)
PORT=8083

# -------------------------------
# Start Deployment Process
# -------------------------------

echo "🚀 Starting deployment of '$CONTAINER_NAME' from directory: $PROJECT_DIR"

# Navigate to the project directory
cd "$PROJECT_DIR"

# -------------------------------
# Stop and remove the old container (if it exists)
# -------------------------------
if docker ps -a --format '{{.Names}}' | grep -Eq "^$CONTAINER_NAME$"; then
  echo "🛑 Stopping and removing existing container '$CONTAINER_NAME'..."
  docker stop "$CONTAINER_NAME"
  docker rm "$CONTAINER_NAME"
else
  echo "ℹ️ No existing container named '$CONTAINER_NAME' found."
fi

# -------------------------------
# Build/Overwrite the Docker image
# -------------------------------
echo "🔨 Building Docker image '$IMAGE_NAME' from Dockerfile..."
docker build -t "$IMAGE_NAME" .

# -------------------------------
# Run the new container
# -------------------------------
echo "🚀 Starting new container '$CONTAINER_NAME'..."
docker run -d \
  --name "$CONTAINER_NAME" \
  -p "$PORT:80" \
  --restart unless-stopped \
  "$IMAGE_NAME"

# -------------------------------
# Final confirmation
# -------------------------------
echo "✅ Deployment completed successfully!"
echo "🌐 App is now available at: http://localhost:$PORT/ or via Cloudflare Tunnel if configured."