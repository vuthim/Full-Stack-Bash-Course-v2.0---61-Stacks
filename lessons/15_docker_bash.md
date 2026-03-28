# 🐳 STACK 15: DOCKER & BASH
## Container Automation with Shell Scripts

---

## 🔰 Why Docker for Scripts?

Docker provides:
- **Consistent environment** - Same运行环境 everywhere
- **Isolation** - Scripts don't affect host system
- **Portability** - Run anywhere Docker is installed
- **Reproducibility** - Version-controlled environments
- **Resource management** - Control CPU, memory, networking

---

## ⚙️ Docker Installation

### Install Docker
```bash
# Ubuntu/Debian
curl -fsSL https://get.docker.com | sh

# Add user to docker group
sudo usermod -aG docker $USER

# Start and enable
sudo systemctl start docker
sudo systemctl enable docker

# Verify
docker --version
docker run hello-world
```

### Docker Basics
```bash
# Check Docker status
docker version
docker info

# Run a container
docker run hello-world
docker run -it ubuntu bash  # Interactive

# List containers
docker ps              # Running only
docker ps -a          # All containers
docker ps -q          # Quiet (IDs only)

# Container operations
docker start <container>
docker stop <container>
docker restart <container>
docker rm <container>
docker rm -f <container>  # Force remove

# Logs
docker logs <container>
docker logs -f <container>  # Follow
docker logs --tail 100 <container>
```

---

## 🐚 Essential Docker Commands

### Running Containers
```bash
# Run in background (detached)
docker run -d nginx

# Run with name
docker run -d --name my-nginx nginx

# Run with port mapping
docker run -d -p 8080:80 nginx
docker run -d -p 3000:3000 -p 3001:3001 myapp

# Run with environment variables
docker run -d -e APP_ENV=production -e DB_HOST=localhost myapp

# Run with volume mount
docker run -d -v /host/path:/container/path myapp
docker run -d -v $(pwd)/data:/data myapp

# Run with restart policy
docker run -d --restart unless-stopped myapp
docker run -d --restart on-failure myapp
docker run -d --restart always myapp

# Interactive shell
docker run -it ubuntu bash
docker run -it --rm ubuntu bash  # Auto-remove on exit
```

### Working with Images
```bash
# List images
docker images
docker images -a

# Pull image
docker pull nginx:latest

# Remove image
docker rmi nginx
docker rmi -f nginx  # Force

# Build image
docker build -t myapp:latest .

# Tag image
docker tag myapp:latest myregistry.com/myapp:latest

# Push to registry
docker push myregistry.com/myapp:latest
```

### Inspecting Containers
```bash
# Container details
docker inspect mycontainer

# Container processes
docker top mycontainer

# Container stats
docker stats mycontainer
docker stats --no-stream mycontainer

# Container logs
docker logs -f --tail 100 mycontainer

# Execute command in container
docker exec -it mycontainer bash
docker exec mycontainer ./script.sh

# Copy files
docker cp mycontainer:/app/logs ./logs
docker cp ./config mycontainer:/app/config
```

---

## 📝 Dockerfile Deep Dive

### Basic Dockerfile
```dockerfile
FROM ubuntu:22.04

# Set environment
ENV APP_DIR=/app
ENV DEBIAN_FRONTEND=noninteractive

# Create directory
RUN mkdir -p $APP_DIR

# Copy files
COPY script.sh $APP_DIR/
COPY config/ $APP_DIR/config/

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set working directory
WORKDIR $APP_DIR

# Make script executable
RUN chmod +x script.sh

# Expose port
EXPOSE 8080

# Run script
CMD ["./script.sh"]
```

### Multi-stage Builds
```dockerfile
# Build stage
FROM node:18 AS builder
WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production
COPY . .
RUN npm run build

# Production stage
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/node_modules ./node_modules

CMD ["node", "dist/index.js"]
```

### Best Practices
```dockerfile
# Use specific versions
FROM node:18.16.0-alpine3.18

# Layer ordering (least frequently changed first)
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y curl
COPY requirements.txt ./
RUN pip install -r requirements.txt
COPY . .

# Use .dockerignore
# .dockerignore
node_modules
.git
*.log
.env
dist

# Combine RUN commands
RUN apt-get update && \
    apt-get install -y curl jq && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Use WORKDIR instead of cd
WORKDIR /app
```

---

## 🔧 Docker with Bash Scripts

### Build Script
```bash
#!/bin/bash
# build_image.sh

set -euo pipefail

IMAGE_NAME="${1:-myapp}"
IMAGE_TAG="${2:-latest}"

log() { echo "[$(date)] $*"; }

log "Building Docker image: $IMAGE_NAME:$IMAGE_TAG"

docker build -t "$IMAGE_NAME:$IMAGE_TAG" .

log "Tagging as latest..."
docker tag "$IMAGE_NAME:$IMAGE_TAG" "$IMAGE_NAME:latest"

log "Build complete!"
docker images | grep "$IMAGE_NAME"
```

### Run Script
```bash
#!/bin/bash
# run_container.sh

set -euo pipefail

CONTAINER_NAME="${1:-myapp}"
IMAGE="${2:-myapp:latest}"

# Check if container already running
if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
    echo "Container $CONTAINER_NAME exists. Removing..."
    docker rm -f "$CONTAINER_NAME"
fi

echo "Starting container $CONTAINER_NAME..."
docker run -d \
    --name "$CONTAINER_NAME" \
    -p 8080:8080 \
    -e APP_ENV=production \
    -v "$(pwd)/data:/data" \
    --restart unless-stopped \
    "$IMAGE"

echo "Container started!"
docker ps | grep "$CONTAINER_NAME"
```

### Management Script
```bash
#!/bin/bash
# docker_manage.sh

set -euo pipefail

CONTAINER_NAME="myapp"

case "${1:-start}" in
    start)
        echo "Starting container..."
        docker start "$CONTAINER_NAME"
        ;;
    stop)
        echo "Stopping container..."
        docker stop "$CONTAINER_NAME"
        ;;
    restart)
        echo "Restarting container..."
        docker restart "$CONTAINER_NAME"
        ;;
    logs)
        docker logs -f --tail 50 "$CONTAINER_NAME"
        ;;
    status)
        docker ps -a --filter "name=$CONTAINER_NAME" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        ;;
    shell)
        docker exec -it "$CONTAINER_NAME" /bin/bash
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|logs|status|shell}"
        exit 1
        ;;
esac
```

### Cron in Docker
```dockerfile
FROM ubuntu:22.04

ENV CRON_SCHEDULE="0 * * * *"

# Install cron
RUN apt-get update && \
    apt-get install -y cron curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy scripts
COPY backup.sh /usr/local/bin/
COPY cronfile /etc/cron.d/backup

RUN chmod 0644 /etc/cron.d/backup && \
    crontab /etc/cron.d/backup

# Run cron
CMD ["cron", "-f"]
```

### Health Check Script
```bash
#!/bin/bash
# healthcheck.sh

set -euo pipefail

# Check if service is responding
response=$(curl -sf http://localhost:8080/health || echo "failed")

if [ "$response" = "failed" ]; then
    echo "Health check failed!"
    exit 1
fi

echo "Health check passed"
exit 0
```

In Dockerfile:
```dockerfile
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD /usr/local/bin/healthcheck.sh
```

---

## 🔄 Docker Compose

### Basic docker-compose.yml
```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=production
      - DB_HOST=postgres
    depends_on:
      - postgres
    volumes:
      - ./data:/app/data
    restart: unless-stopped

  postgres:
    image: postgres:15
    environment:
      - POSTGRES_PASSWORD=secret
      - POSTGRES_DB=myapp
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  postgres_data:
```

### Compose Commands
```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# Rebuild and start
docker-compose up -d --build

# View logs
docker-compose logs -f
docker-compose logs -f app

# Scale service
docker-compose up -d --scale app=3

# Run one-off command
docker-compose exec app bash
```

### Compose for Scripts
```yaml
version: '3.8'

services:
  backup:
    build: ./backup
    volumes:
      - ./backups:/backups
      - app_data:/data
    environment:
      - SCHEDULE=0 2 * * *

  monitor:
    build: ./monitor
    volumes:
      - ./logs:/logs
    network_mode: host

volumes:
  app_data:
```

---

## 🐳 Docker Networking

### Network Basics
```bash
# List networks
docker network ls

# Create network
docker network create mynetwork

# Run with network
docker run --network mynetwork -d myapp

# Inspect network
docker network inspect mynetwork
```

### DNS and Containers
```bash
# Containers can reach each other by name
# app container can reach db container by hostname "db"

# Custom DNS
docker run --network mynetwork --dns 8.8.8.8 myapp

# Host network (no isolation)
docker run --network host myapp
```

---

## 💾 Docker Volumes

### Volume Types
```bash
# Named volumes
docker volume create mydata
docker run -v mydata:/data myapp

# Bind mounts (host paths)
docker run -v $(pwd):/app myapp
docker run -v /host/path:/container/path:ro myapp  # read-only

# tmpfs (in-memory)
docker run --tmpfs /tmp myapp
```

### Backup/Restore Volumes
```bash
#!/bin/bash
# backup_volume.sh

VOLUME_NAME="$1"
BACKUP_FILE="${2:-backup.tar.gz}"

# Create temporary container
docker run --rm \
    -v "$VOLUME_NAME":/data \
    -v $(pwd):/backup \
    alpine \
    tar czf "/backup/$BACKUP_FILE" -C /data .

echo "Backup created: $BACKUP_FILE"
```

```bash
#!/bin/bash
# restore_volume.sh

VOLUME_NAME="$1"
BACKUP_FILE="$2"

docker run --rm \
    -v "$VOLUME_NAME":/data \
    -v $(pwd):/backup \
    alpine \
    tar xzf "/backup/$BACKUP_FILE" -C /data

echo "Volume restored from: $BACKUP_FILE"
```

---

## 🔍 Troubleshooting Docker

### Common Issues
```bash
# Container won't start
docker logs <container>
docker inspect <container>

# Port already in use
docker ps | grep <port>
netstat -tlnp | grep <port>

# Permission denied
# Add :z or :Z for SELinux
docker run -v $(pwd):/app:z myapp

# Out of disk space
docker system df
docker system prune -a
docker volume prune
```

### Debug Container
```bash
# Run with privileged mode
docker run --privileged -it myapp /bin/bash

# Add capabilities
docker run --cap-add=NET_ADMIN myapp

# See what processes are running
docker top <container>
docker exec <container> ps aux

# Network debugging
docker run --network container:<name> nicolaka/netshoot
```

---

## 📋 Docker Best Practices

### Security
```dockerfile
# Run as non-root user
FROM node:18-alpine
RUN addgroup -g 1001 appgroup && \
    adduser -u 1001 -G appgroup -s /bin/sh -D appuser

USER appuser

# Read-only root filesystem
docker run --read-only myapp

# Limit resources
docker run --memory=512m --cpus=1.0 myapp
```

### Optimization
```dockerfile
# Use alpine for smaller images
FROM node:18-alpine

# Don't run as root
USER node

# Use multi-stage builds
# (see earlier example)

# .dockerignore
# Keep it minimal
```

---

## ✅ Stack 15 Complete!

You learned:
- ✅ Docker installation and basics
- ✅ Essential Docker commands
- ✅ Dockerfile deep dive
- ✅ Multi-stage builds
- ✅ Bash scripts for Docker (build, run, manage)
- ✅ Docker Compose basics
- ✅ Docker networking
- ✅ Docker volumes and backups
- ✅ Troubleshooting
- ✅ Security best practices

### Next: Stack 16 - SSH Remote →

---

*End of Stack 15*
