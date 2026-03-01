#!/bin/bash
# 컨테이너 내부 전용 시작 스크립트 (Ubuntu)
# postStartCommand에서 자동 실행됨

PROJECT=/home/juitem/ContainerFolder/devM/forMac/DockerSingle

# pip user 설치 경로를 PATH에 추가
export PATH="$HOME/.local/bin:$PATH"

# 기존 프로세스 종료
kill_port() {
    local port=$1
    local pid
    if command -v lsof &>/dev/null; then
        pid=$(lsof -ti tcp:"$port" 2>/dev/null)
    else
        # lsof 없을 때 Python으로 /proc/net/tcp 파싱
        pid=$(python3 - <<EOF
import os, struct, socket
target = format($port, '04X')
with open('/proc/net/tcp') as f:
    for line in f.readlines()[1:]:
        parts = line.split()
        if parts[1].endswith(':' + target) and parts[3] == '0A':
            inode = parts[9]
            for pid in os.listdir('/proc'):
                if not pid.isdigit():
                    continue
                try:
                    for fd in os.listdir(f'/proc/{pid}/fd'):
                        try:
                            if os.readlink(f'/proc/{pid}/fd/{fd}') == f'socket:[{inode}]':
                                print(pid)
                                raise SystemExit
                        except (OSError, PermissionError):
                            pass
                except (OSError, PermissionError):
                    pass
EOF
)
    fi
    if [ -n "$pid" ]; then
        echo "[dev-start] Killing existing process on port $port (PID: $pid)"
        kill -9 "$pid" 2>/dev/null
        sleep 1
    fi
}
kill_port 8000
kill_port 3000

# Backend (FastAPI)
echo "[dev-start] Starting backend..."
cd "$PROJECT/backend"
pip install --break-system-packages -q -r requirements.txt
uvicorn app:app --host 0.0.0.0 --port 8000 --reload &

# Frontend (React)
echo "[dev-start] Starting frontend..."
cd "$PROJECT/frontend"
npm install --silent
BROWSER=none npm start &

echo "[dev-start] Done. Backend: http://localhost:8000 | Frontend: http://localhost:3000"
