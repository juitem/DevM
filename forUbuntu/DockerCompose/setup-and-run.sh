#!/bin/bash

# Ubuntu only script
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "This script is for Ubuntu only."
    exit 1
fi

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

export USER_ID=$(id -u)
export GROUP_ID=$(id -g)

log_info()    { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[✓]${NC} $1"; }
log_error()   { echo -e "${RED}[✗]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[!]${NC} $1"; }

echo -e "\n${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  🚀 Python + React GUI - Docker Setup (Ubuntu)${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"

# Create mount directories
mkdir -p ~/Docker/ContainerFolder/ssh_docker
mkdir -p ~/Docker/ContainerFolder/CurSorServer
mkdir -p ~/Docker/ContainerFolder/CurSor
mkdir -p ~/Docker/ContainerFolder/GeMiNi
mkdir -p ~/Docker/ContainerFolder/ClauDe

# Sync SSH keys
log_info "Syncing SSH keys..."
cp -r ~/.ssh/. ~/Docker/ContainerFolder/ssh_docker/
chmod 700 ~/Docker/ContainerFolder/ssh_docker
log_success "SSH keys synced"

# X11 access
if command -v xhost &> /dev/null; then
    xhost +local:docker > /dev/null 2>&1 \
        && log_success "X11 access granted (xhost +local:docker)" \
        || log_warning "xhost failed"
else
    log_warning "xhost not found - run 'sudo apt install x11-xserver-utils' to use X11 apps"
fi

# Check Docker
log_info "Checking Docker installation..."
if ! command -v docker &> /dev/null; then
    log_error "Docker is not installed."
    exit 1
fi
log_success "Docker is installed."

log_info "Checking Docker daemon..."
if ! docker info &> /dev/null; then
    log_error "Docker daemon is not running."
    log_info "Run: sudo systemctl start docker"
    exit 1
fi
log_success "Docker daemon is running."

log_info "Checking Docker Compose..."
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    log_error "Docker Compose is not installed."
    exit 1
fi
log_success "Docker Compose is available."

log_info "Project directory: $PROJECT_DIR"
if [ ! -f "$PROJECT_DIR/docker-compose.yml" ]; then
    log_error "docker-compose.yml not found."
    exit 1
fi
log_success "Project structure verified."

log_info "Stopping existing containers..."
cd "$PROJECT_DIR"
docker compose down 2>/dev/null || true

log_info "Building Docker image and starting containers..."
echo -e "\n${YELLOW}(This may take a few minutes on first run)${NC}\n"

if docker compose up -d; then
    log_success "Docker Compose started."
else
    log_error "Failed to start Docker Compose."
    exit 1
fi

log_info "Waiting for services to start..."
sleep 5

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
    if $BACKEND_READY && $FRONTEND_READY; then break; fi
    sleep 1
    COUNTER=$((COUNTER + 1))
done

if ! $BACKEND_READY || ! $FRONTEND_READY; then
    log_warning "Some services may still be starting up."
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ Setup complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}\n"

echo -e "${BLUE}Access URLs:${NC}"
echo -e "  🌐 Frontend: ${GREEN}http://localhost:3000${NC}"
echo -e "  📡 Backend:  ${GREEN}http://localhost:8000${NC}"
echo -e "  📊 API:      ${GREEN}http://localhost:8000/api/status${NC}"
echo ""

read -p "Open in browser? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    log_info "Opening browser..."
    sleep 2
    xdg-open "http://localhost:3000" &
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
