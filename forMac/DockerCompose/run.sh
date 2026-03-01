#!/bin/bash

# macOS 전용 스크립트
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "이 스크립트는 macOS 전용입니다. 컨테이너 내부에서 실행하지 마세요."
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
