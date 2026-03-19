# 🐳 STACK 15: DOCKER & BASH
## Container Automation with Shell Scripts

---

## 🔰 What is Docker?

Docker packages applications with their dependencies into containers.

### Installation
```bash
# Install Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER

# Start Docker
sudo systemctl start docker
sudo systemctl enable docker
```

---

## 🐚 Basic Docker Commands

```bash
# Run a container
docker run hello-world
docker run -it ubuntu bash

# List containers
docker ps           # Running
docker ps -a        # All

# Container operations
docker start <id>
docker stop <id>
docker rm <id>

# Images
docker images
docker pull nginx
docker rmi <image>
```

---

## 📝 Dockerfile Basics

```dockerfile
FROM ubuntu:22.04

# Set environment
ENV APP_DIR=/app

# Create directory
RUN mkdir -p $APP_DIR

# Copy files
COPY script.sh $APP_DIR/
COPY data/ $APP_DIR/

# Set working directory
WORKDIR $APP_DIR

# Make script executable
RUN chmod +x script.sh

# Run script
CMD ["./script.sh"]
```

---

## 🔧 Docker with Bash Scripts

### Build & Run Custom Image
```bash
# Create Dockerfile
cat > Dockerfile << 'EOF'
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y curl
COPY backup.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/backup.sh
CMD ["backup.sh"]
EOF

# Build image
docker build -t my-backup-script .

# Run container
docker run my-backup-script
```

### Cron in Docker
```dockerfile
FROM ubuntu:22.04
COPY backup.sh /backup.sh
RUN chmod +x /backup.sh

# Install cron
RUN apt-get install -y cron

# Copy crontab
COPY crontab /etc/cron.daily/backup
RUN chmod 0644 /etc/cron.daily/backup

CMD ["cron", "-f"]
```

---

## 🔄 Docker Compose & Scripts

```yaml
# docker-compose.yml
version: '3'
services:
  app:
    build: .
    volumes:
      - ./data:/data
    environment:
      - MODE=production
    
  monitor:
    image: monitoring-script
    volumes:
      - ./logs:/logs
```

---

## 🏆 Practice: Dockerize Your Script

```bash
# 1. Create a script
cat > monitor.sh << 'EOF'
#!/bin/bash
while true; do
    echo "[$(date)] System running..."
    sleep 60
done
EOF

# 2. Create Dockerfile
cat > Dockerfile << 'EOF'
FROM ubuntu:22.04
COPY monitor.sh /monitor.sh
RUN chmod +x /monitor.sh
CMD ["/monitor.sh"]
EOF

# 3. Build and run
docker build -t system-monitor .
docker run -d system-monitor
```

---

## ✅ Stack 15 Complete!