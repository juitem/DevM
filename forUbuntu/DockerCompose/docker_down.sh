#!/bin/bash

# Ubuntu only script
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "This script is for Ubuntu only."
    exit 1
fi

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
echo -e "${BLUE}  🛑 Python + React GUI - Docker Stop${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"

if [ ! -f "$PROJECT_DIR/docker-compose.yml" ]; then
    log_error "docker-compose.yml not found."
    exit 1
fi

log_info "Checking container status..."
cd "$PROJECT_DIR"

BACKEND_RUNNING=$(docker compose ps --status running --services 2>/dev/null | grep -c "backend" || true)
FRONTEND_RUNNING=$(docker compose ps --status running --services 2>/dev/null | grep -c "frontend" || true)

if [ "$BACKEND_RUNNING" -eq 0 ] && [ "$FRONTEND_RUNNING" -eq 0 ]; then
    log_warning "No running containers found."
    exit 0
fi

echo ""
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || docker compose ps
echo ""

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
