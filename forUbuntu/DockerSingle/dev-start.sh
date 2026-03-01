#!/bin/bash
# Container-only startup script (runs inside the container)

PROJECT=/home/juitem/ContainerFolder/devM/forUbuntu/DockerSingle

# Add pip user install path to PATH
export PATH="$HOME/.local/bin:$PATH"

# Kill any process occupying the given port
kill_port() {
    local port=$1
    local pid
    if command -v lsof &>/dev/null; then
        pid=$(lsof -ti tcp:"$port" 2>/dev/null)
    else
        # Fallback: parse /proc/net/tcp with Python when lsof is unavailable
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
