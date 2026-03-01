#!/bin/bash

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Project directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Export host UID/GID for docker-compose build args
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

log_error() {
    echo -e "${RED}[✗]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Title
echo -e "\n${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  🚀 Python + React GUI - Docker Setup${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"

# Create mount directories if missing
mkdir -p ~/Docker/ContainerFolder/ssh_docker
mkdir -p ~/Docker/ContainerFolder/CurSorServer
mkdir -p ~/Docker/ContainerFolder/CurSor
mkdir -p ~/Docker/ContainerFolder/GeMiNi
mkdir -p ~/Docker/ContainerFolder/ClauDe

# Sync SSH keys to container mount directory
log_info "Syncing SSH keys..."
cp -r ~/.ssh/. ~/Docker/ContainerFolder/ssh_docker/
chmod 700 ~/Docker/ContainerFolder/ssh_docker
log_success "SSH keys synced"

# macOS X11 access (only effective when XQuartz is running)
if [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v xhost &> /dev/null; then
        if [ -z "$DISPLAY" ]; then
            export DISPLAY=:0
        fi
        # +local: allows all local Unix socket connections
        xhost +local: > /dev/null 2>&1 \
            && log_success "X11 access granted (xhost +local:)" \
            || log_warning "xhost failed (is XQuartz running?)"
    else
        log_warning "xhost not found - install XQuartz to use X11 apps"
    fi

    # Generate Xauth cookie for Docker containers (wildcard - works with any display address)
    # OrbStack containers connect to XQuartz over TCP, so MIT-MAGIC-COOKIE auth is required
    if command -v xauth &> /dev/null; then
        touch /tmp/.docker.xauth 2>/dev/null
        xauth nlist :0 2>/dev/null | sed -e 's/^..../ffff/' | xauth -f /tmp/.docker.xauth nmerge - 2>/dev/null \
            && log_success "X11 auth cookie generated (/tmp/.docker.xauth)" \
            || log_warning "X11 cookie generation failed (is XQuartz running?)"
        log_info "For X11 apps (gitk etc.): XQuartz Preferences → Security → check 'Allow connections from network clients'"
    fi
fi

# Check Docker installation
log_info "Checking Docker installation..."
if ! command -v docker &> /dev/null; then
    log_error "Docker is not installed."
    log_info "Please install OrbStack or Docker Desktop and try again."
    exit 1
fi
log_success "Docker is installed."

# Check Docker daemon
log_info "Checking Docker daemon..."
if ! docker info &> /dev/null; then
    log_error "Docker daemon is not running."
    log_info "Please start OrbStack or Docker Desktop."
    exit 1
fi
log_success "Docker daemon is running."

# Check Docker Compose
log_info "Checking Docker Compose..."
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    log_error "Docker Compose is not installed."
    exit 1
fi
log_success "Docker Compose is available."

# Verify project directory
log_info "Project directory: $PROJECT_DIR"
if [ ! -f "$PROJECT_DIR/docker-compose.yml" ]; then
    log_error "docker-compose.yml not found."
    exit 1
fi
log_success "Project structure verified."

# Stop existing containers
log_info "Stopping existing containers..."
cd "$PROJECT_DIR"
docker compose down 2>/dev/null || true

# Build image and start containers
log_info "Building Docker image and starting containers..."
echo -e "\n${YELLOW}(This may take a few minutes on first run)${NC}\n"

if docker compose up -d; then
    log_success "Docker Compose started."
else
    log_error "Failed to start Docker Compose."
    exit 1
fi

# Wait for services
log_info "Waiting for services to start..."
sleep 5

# Check service status
log_info "Checking service status..."
echo ""

BACKEND_READY=false
FRONTEND_READY=false
COUNTER=0
MAX_ATTEMPTS=30

while [ $COUNTER -lt $MAX_ATTEMPTS ]; do
    if ! $BACKEND_READY && curl -s http://localhost:8000/api/status > /dev/null 2>&1; then
        log_success "Backend API is ready ✓"
        BACKEND_READY=true
    fi

    if ! $FRONTEND_READY && curl -s http://localhost:3000 > /dev/null 2>&1; then
        log_success "Frontend is ready ✓"
        FRONTEND_READY=true
    fi

    if $BACKEND_READY && $FRONTEND_READY; then
        break
    fi

    sleep 1
    COUNTER=$((COUNTER + 1))
done

if ! $BACKEND_READY || ! $FRONTEND_READY; then
    log_warning "Some services may still be starting up."
    log_info "Check logs with: docker compose logs -f"
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Setup complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}\n"

# Open browser
log_info "Application is ready.\n"

echo -e "${BLUE}Access URLs:${NC}"
echo -e "  🌐 Frontend: ${GREEN}http://localhost:3000${NC}"
echo -e "  📡 Backend:  ${GREEN}http://localhost:8000${NC}"
echo -e "  📊 API:      ${GREEN}http://localhost:8000/api/status${NC}"
echo ""

# Auto-open browser on Mac
if [[ "$OSTYPE" == "darwin"* ]]; then
    read -p "Open in browser? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "Opening browser..."
        sleep 2
        open "http://localhost:3000"
    fi
fi

echo -e "${BLUE}Useful commands:${NC}"
echo -e "  • View logs:        ${YELLOW}docker compose logs -f${NC}"
echo -e "  • Container status: ${YELLOW}docker compose ps${NC}"
echo -e "  • Stop services:    ${YELLOW}docker compose down${NC}"
echo -e "  • Access backend:   ${YELLOW}docker compose exec backend bash${NC}"
echo -e "  • Access frontend:  ${YELLOW}docker compose exec frontend sh${NC}"
echo ""

echo -e "${GREEN}✓ Docker is running. To view logs:${NC}"
echo -e "  ${YELLOW}cd $PROJECT_DIR && docker compose logs -f${NC}\n"
