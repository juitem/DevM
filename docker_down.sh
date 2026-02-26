#!/bin/bash

# 색상 정의
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 프로젝트 디렉토리
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 호스트 UID/GID export
export USER_ID=$(id -u)
export GROUP_ID=$(id -g)

# 함수: 로깅
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

# 제목 출력
echo -e "\n${BLUE}═══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  🛑 Python + React GUI - Docker Stop${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"

# docker-compose.yml 확인
if [ ! -f "$PROJECT_DIR/docker-compose.yml" ]; then
    log_error "docker-compose.yml 파일을 찾을 수 없습니다."
    exit 1
fi

# 실행 중인 컨테이너 확인
log_info "컨테이너 상태 확인 중..."
cd "$PROJECT_DIR"

BACKEND_RUNNING=$(docker compose ps --status running --services 2>/dev/null | grep -c "backend" || true)
FRONTEND_RUNNING=$(docker compose ps --status running --services 2>/dev/null | grep -c "frontend" || true)

if [ "$BACKEND_RUNNING" -eq 0 ] && [ "$FRONTEND_RUNNING" -eq 0 ]; then
    log_warning "실행 중인 컨테이너가 없습니다."
    exit 0
fi

# 실행 중인 서비스 출력
echo ""
docker compose ps --format "table {{.Name}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null || docker compose ps
echo ""

# 컨테이너 중지
log_info "컨테이너 중지 중..."
if docker compose down; then
    echo ""
    echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ 컨테이너가 정상적으로 중지되었습니다.${NC}"
    echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}\n"
else
    log_error "컨테이너 중지에 실패했습니다."
    exit 1
fi
