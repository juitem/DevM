#!/bin/bash

# Color definitions
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Project directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Export host UID/GID
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
echo -e "${BLUE}  🛑 Python + React GUI - Docker Stop${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"

# Check docker-compose.yml
if [ ! -f "$PROJECT_DIR/docker-compose.yml" ]; then
    log_error "docker-compose.yml not found."
    exit 1
fi

# Check running containers
log_info "Checking container status..."
cd "$PROJECT_DIR"

BACKEND_RUNNING=$(docker compose ps --status running --services 2>/dev/null | grep -c "backend" || true)
FRONTEND_RUNNING=$(docker compose ps --status running --services 2>/dev/null | grep -c "frontend" || true)

if [ "$BACKEND_RUNNING" -eq 0 ] && [ "$FRONTEND_RUNNING" -eq 0 ]; then
    log_warning "No running containers found."
    exit 0
fi

# Show running services
echo ""
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || docker compose ps
echo ""

# Stop containers
log_info "Stopping containers..."
if docker compose down; then
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ Containers stopped successfully.${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}\n"
else
    log_error "Failed to stop containers."
    exit 1
fi
