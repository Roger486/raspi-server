#!/bin/bash
# Exit immediately if a command exits with a non-zero status
set -e

# -------------------------------
# Configuration
# -------------------------------

PROJECT_NAME="hostcontrol"
COMPOSE_FILE="docker-compose.yml"

# Detect system user (supports sudo)
USER_NAME="${SUDO_USER:-$USER}"
DEPLOY_PATH="/home/${USER_NAME}/projects/mono/angular-laravel/HostControl"

# Whether to wipe DB and reseed (true = migrate:fresh, false = migrate)
RESET_DB=true

# -------------------------------
# Start deployment
# -------------------------------

echo "🚀 Deploying '$PROJECT_NAME' in: $DEPLOY_PATH"
cd "$DEPLOY_PATH"

# -------------------------------
# Stop and clean containers
# -------------------------------
echo "🧹 Stopping containers and removing volumes..."
docker compose -f "$COMPOSE_FILE" down -v --remove-orphans || true

# -------------------------------
# Remove old images (if exist)
# -------------------------------
echo "🧼 Removing old images (if any)..."
docker images --format '{{.Repository}}' | grep -q "^${PROJECT_NAME}-frontend$" && docker rmi "${PROJECT_NAME}-frontend" || true
docker images --format '{{.Repository}}' | grep -q "^${PROJECT_NAME}-backend$" && docker rmi "${PROJECT_NAME}-backend" || true

# -------------------------------
# Rebuild and start containers
# -------------------------------
echo "🔨 Rebuilding and starting services..."
docker compose -f "$COMPOSE_FILE" up -d --build

# -------------------------------
# Ensure .env file is in backend
# -------------------------------
if [ ! -f backend/.env ]; then
    echo "📄 Creating .env from .env.example..."
    cp backend/.env.example backend/.env
fi

# Wait a few seconds to ensure services are ready
echo "⏳ Waiting 10 seconds for backend to be ready..."
sleep 10

# -------------------------------
# Run Laravel migrations and seeders
# -------------------------------
echo "⚙️ Running Laravel setup..."
docker exec -i "${PROJECT_NAME}-backend" php artisan config:clear
docker exec -i "${PROJECT_NAME}-backend" php artisan config:cache
docker exec -i "${PROJECT_NAME}-backend" php artisan key:generate

if [ "$RESET_DB" = true ]; then
    echo "📦 Installing fakerphp/faker for seeding..."
    docker exec -i "${PROJECT_NAME}-backend" composer require fakerphp/faker --dev

    echo "⚠️ Running destructive migrations (fresh + seed)..."
    docker exec -i "${PROJECT_NAME}-backend" php artisan migrate:fresh --seed
else
    echo "🛠️ Running safe migrations..."
    docker exec -i "${PROJECT_NAME}-backend" php artisan migrate --force
fi

# -------------------------------
# Final confirmation
# -------------------------------
echo "✅ '$PROJECT_NAME' deployed successfully."
echo "🌐 Frontend available at: http://localhost:8081"
echo "🗄️  Adminer available at: http://localhost:8082"
echo "🔌 API available at: http://localhost:8000/api"
echo "📝 Note: To preserve database data, set RESET_DB=false"
echo "🧱 Adminer and DB containers haven't been touched if already present."
