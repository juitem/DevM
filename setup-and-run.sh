#!/bin/bash

# 색상 정의
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 프로젝트 디렉토리
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 호스트 UID/GID를 환경변수로 export (docker-compose build args에 주입)
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
echo -e "${BLUE}  🚀 Python + React GUI - Docker Setup${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════${NC}\n"

# 마운트 폴더 생성 (없을 경우 대비)
mkdir -p ~/Docker/ContainerFolder/ssh_docker
mkdir -p ~/Docker/ContainerFolder/CurSorServer
mkdir -p ~/Docker/ContainerFolder/CurSor
mkdir -p ~/Docker/ContainerFolder/GeMiNi
mkdir -p ~/Docker/ContainerFolder/ClauDe

# SSH 키를 컨테이너 마운트 폴더에 자동 동기화
log_info "SSH 키 동기화 중..."
cp -r ~/.ssh/. ~/Docker/ContainerFolder/ssh_docker/
chmod 700 ~/Docker/ContainerFolder/ssh_docker
log_success "SSH 키 동기화 완료"

# macOS X11 접근 허용 (XQuartz 실행 중일 때만 유효)
if [[ "$OSTYPE" == "darwin"* ]]; then
    if command -v xhost &> /dev/null; then
        # DISPLAY가 설정되지 않은 경우 XQuartz 기본값으로 설정
        if [ -z "$DISPLAY" ]; then
            export DISPLAY=:0
        fi
        xhost +localhost > /dev/null 2>&1 \
            && log_success "X11 접근 허용 (xhost +localhost)" \
            || log_warning "xhost 실행 실패 (XQuartz가 실행 중인지 확인하세요)"
    else
        log_warning "xhost 없음 - X11 앱 사용 시 XQuartz 설치 필요"
    fi
fi

# Docker 설치 확인
log_info "Docker 설치 확인 중..."
if ! command -v docker &> /dev/null; then
    log_error "Docker가 설치되어 있지 않습니다."
    log_info "Docker Desktop을 설치하고 실행한 후 다시 시도하세요."
    exit 1
fi
log_success "Docker가 설치되어 있습니다."

# Docker daemon 실행 확인
log_info "Docker daemon 확인 중..."
if ! docker info &> /dev/null; then
    log_error "Docker daemon이 실행 중이 아닙니다."
    log_info "Docker Desktop을 실행해주세요."
    exit 1
fi
log_success "Docker daemon이 실행 중입니다."

# Docker Compose 확인
log_info "Docker Compose 확인 중..."
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    log_error "Docker Compose가 설치되어 있지 않습니다."
    exit 1
fi
log_success "Docker Compose가 설치되어 있습니다."

# 프로젝트 디렉토리 확인
log_info "프로젝트 디렉토리: $PROJECT_DIR"
if [ ! -f "$PROJECT_DIR/docker-compose.yml" ]; then
    log_error "docker-compose.yml 파일을 찾을 수 없습니다."
    exit 1
fi
log_success "프로젝트 구조 확인 완료"

# 기존 컨테이너 정리 (선택)
log_info "기존 컨테이너 정리 중..."
cd "$PROJECT_DIR"
docker compose down 2>/dev/null || true

# Docker 이미지 빌드 및 컨테이너 실행
log_info "Docker 이미지 빌드 및 컨테이너 실행 중..."
echo -e "\n${YELLOW}(이 과정은 처음에는 몇 분이 걸릴 수 있습니다)${NC}\n"

if docker compose up -d; then
    log_success "Docker Compose가 시작되었습니다."
else
    log_error "Docker Compose 시작에 실패했습니다."
    exit 1
fi

# 서비스 대기
log_info "서비스가 시작될 때까지 대기 중..."
sleep 5

# 서비스 상태 확인
log_info "서비스 상태 확인 중..."
echo ""

BACKEND_READY=false
FRONTEND_READY=false
COUNTER=0
MAX_ATTEMPTS=30

while [ $COUNTER -lt $MAX_ATTEMPTS ]; do
    if ! $BACKEND_READY && curl -s http://localhost:8000/api/status > /dev/null 2>&1; then
        log_success "Backend API가 준비되었습니다 ✓"
        BACKEND_READY=true
    fi

    if ! $FRONTEND_READY && curl -s http://localhost:3000 > /dev/null 2>&1; then
        log_success "Frontend가 준비되었습니다 ✓"
        FRONTEND_READY=true
    fi

    if $BACKEND_READY && $FRONTEND_READY; then
        break
    fi

    sleep 1
    COUNTER=$((COUNTER + 1))
done

if ! $BACKEND_READY || ! $FRONTEND_READY; then
    log_warning "일부 서비스가 아직 준비 중일 수 있습니다."
    log_info "로그를 확인하려면: docker compose logs -f"
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}✓ 설정 완료!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}\n"

# 브라우저 자동 열기
log_info "브라우저에서 애플리케이션을 열 준비가 되었습니다.\n"

echo -e "${BLUE}접속 정보:${NC}"
echo -e "  🌐 Frontend: ${GREEN}http://localhost:3000${NC}"
echo -e "  📡 Backend:  ${GREEN}http://localhost:8000${NC}"
echo -e "  📊 API:      ${GREEN}http://localhost:8000/api/status${NC}"
echo ""

# Mac에서 브라우저 자동 열기
if [[ "$OSTYPE" == "darwin"* ]]; then
    read -p "브라우저에서 열시겠습니까? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        log_info "브라우저를 열고 있습니다..."
        sleep 2
        open "http://localhost:3000"
    fi
fi

echo -e "${BLUE}유용한 명령어:${NC}"
echo -e "  • 로그 보기:      ${YELLOW}docker compose logs -f${NC}"
echo -e "  • 컨테이너 상태:  ${YELLOW}docker compose ps${NC}"
echo -e "  • 서비스 중지:    ${YELLOW}docker compose down${NC}"
echo -e "  • Backend 접속:   ${YELLOW}docker compose exec backend bash${NC}"
echo -e "  • Frontend 접속:  ${YELLOW}docker compose exec frontend sh${NC}"
echo ""

echo -e "${GREEN}✓ Docker가 실행 중입니다. 로그를 보려면 아래 명령어를 실행하세요:${NC}"
echo -e "  ${YELLOW}cd $PROJECT_DIR && docker compose logs -f${NC}\n"
