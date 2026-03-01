#!/bin/bash

# Ubuntu only script
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "This script is for Ubuntu only."
    exit 1
fi

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)

cd "$PROJECT_DIR"

echo -e "\n${BLUE}Starting containers...${NC}"

if docker compose up -d; then
    echo -e "${GREEN}✓ Running${NC}"
    echo -e "  Frontend: ${GREEN}http://localhost:3000${NC}"
    echo -e "  Backend:  ${GREEN}http://localhost:8000${NC}\n"
else
    echo -e "${RED}✗ Failed to start containers${NC}"
    exit 1
fi
