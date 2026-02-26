# Cursor / VS Code Dev Container 가이드

**Ubuntu 24.04 + Python 3.12 + Node.js 22 LTS + React**

---

## 📋 전체 폴더 구조

```
~/Docker/ContainerFolder/
├── ssh_docker/               ← SSH 키 (setup-and-run.sh가 자동 동기화)
├── CurSorServer/             ← Cursor 서버 캐시 (Dev Container 재사용)
├── CurSor/                   ← Cursor 설정 영속
├── GeMiNi/                   ← Gemini AI 설정 영속
├── ClauDe/                   ← Claude Code CLI 설정 (컨테이너 전용 context)
└── dockerTest/
    ├── .devcontainer/
    │   ├── devcontainer.json  (Dev Container 설정)
    │   ├── Dockerfile         (Dev Container + Docker Compose 공용 이미지)
    │   └── DEV_CONTAINER_GUIDE.md
    ├── backend/
    │   ├── requirements.txt
    │   └── app.py
    ├── frontend/
    │   ├── Dockerfile         (React 전용)
    │   ├── package.json
    │   └── src/
    ├── docker-compose.yml
    ├── setup-and-run.sh       (Docker Compose 실행 스크립트)
    ├── docker_down.sh         (Docker Compose 중지 스크립트)
    └── README.md
```

---

## 🎯 두 가지 개발 방식

### 방식 1: Cursor Dev Container (개발 권장) ⭐

```
Cursor 열기
  ↓
"Reopen in Container"
  ↓
devcontainer.json → docker-compose.yml 실행
  ↓
Ubuntu 컨테이너 내부에서 IDE 동작
  ↓
코드 편집 + 실행 + 디버깅 + Claude Code CLI
```

**특징:**
- 컨테이너 내부 터미널 직접 접근
- Python IntelliSense, 디버깅 지원
- SSH 키, Claude/Cursor/Gemini 설정 자동 마운트
- Dev Container 재생성 후에도 설정 유지

### 방식 2: Docker Compose 직접 실행 (서비스 테스트용)

```
./setup-and-run.sh
  ↓
SSH 동기화 + xhost 설정
  ↓
Backend (Python) + Frontend (React) 실행
  ↓
http://localhost:8000 + http://localhost:3000
```

두 방식 모두 **동일한 `.devcontainer/Dockerfile`** 이미지를 사용합니다.

---

## 🔥 빠른 시작 (Dev Container)

### Step 1: Cursor에서 폴더 열기

```bash
cursor ~/Docker/ContainerFolder/dockerTest
```

또는:
- Cursor 실행 → `File > Open Folder`
- `~/Docker/ContainerFolder/dockerTest` 선택

### Step 2: Dev Container 시작

**방법 A: UI 버튼**
- 오른쪽 아래 초록색 `><` 버튼 클릭
- "Reopen in Container" 선택

**방법 B: 명령 팔레트**
- `Cmd + Shift + P`
- "Dev Containers: Reopen in Container"
- Enter

### Step 3: 빌드 완료 대기

첫 실행은 이미지 빌드로 수 분 소요됩니다.
이후 실행은 `.cursor-server` 캐시 덕분에 빠르게 시작됩니다.

### Step 4: Backend 실행

Cursor 터미널에서:

```bash
cd /workspace/backend
python -m uvicorn app:app --reload
```

### Step 5: API 확인

```bash
curl http://localhost:8000/api/status
# {"status":"running","python_version":"3.12","platform":"Ubuntu 24.04"}
```

---

## 💻 컨테이너 내부 개발

### Python 작업

```bash
python --version          # Python 3.12

pip install numpy pandas   # 패키지 설치

pytest                     # 테스트 실행
black app.py               # 코드 포매팅
flake8 app.py              # 코드 검사
```

### Frontend 작업

```bash
cd /workspace/frontend
npm install
npm start
```

### Claude Code CLI (컨테이너 전용 context)

```bash
claude                     # 첫 실행 시 인증 필요 (1회)
# 인증 정보는 ~/Docker/ContainerFolder/ClauDe에 저장됨
# 컨테이너 재생성 후에도 유지
```

### SSH / Git 작업

SSH 키가 자동 마운트되어 바로 사용 가능합니다.

```bash
git clone git@github.com:...
git push origin main
```

### X11 GUI 앱 (XQuartz 필요)

```bash
# XQuartz 실행 + setup-and-run.sh 실행 후
xclock          # X11 테스트
python3 -c "import tkinter; tkinter.Tk()"  # tkinter 테스트
```

---

## 🗂️ 마운트 구성

| 호스트 경로 | 컨테이너 경로 | 용도 |
|-------------|--------------|------|
| `ContainerFolder/ssh_docker` | `/home/juitem/.ssh` | SSH 키 |
| `ContainerFolder/CurSorServer` | `/home/juitem/.cursor-server` | Cursor 서버 캐시 |
| `ContainerFolder/CurSor` | `/home/juitem/.cursor` | Cursor 설정 |
| `ContainerFolder/GeMiNi` | `/home/juitem/.gemini` | Gemini 설정 |
| `ContainerFolder/ClauDe` | `/home/juitem/.claude` | Claude Code context |
| `ContainerFolder` | `/home/juitem/ContainerFolder` | 공유 작업 공간 |

---

## ⚙️ Dev Container 커스터마이징

### 패키지 추가

`.devcontainer/devcontainer.json`에서:
```json
"postCreateCommand": "pip install numpy pandas scipy"
```

이후:
```
Cmd + Shift + P → Dev Containers: Rebuild Container
```

### 포트 포워딩 추가

```json
"forwardPorts": [8000, 3000, 5432],
"portsAttributes": {
  "3000": { "label": "Frontend" },
  "5432": { "label": "Database" }
}
```

### Cursor 확장 추가

```json
"customizations": {
  "vscode": {
    "extensions": ["ms-python.python", "charliermarsh.ruff"]
  }
}
```

---

## 🛑 Dev Container 제어

| 작업 | 명령 |
|------|------|
| 로컬로 복귀 | `Cmd+Shift+P` → "Reopen Folder Locally" |
| 재빌드 (캐시 유지) | `Cmd+Shift+P` → "Rebuild Container" |
| 재빌드 (캐시 삭제) | `Cmd+Shift+P` → "Rebuild Container (Without Cache)" |
| 이미지 삭제 | `docker compose down --rmi all` (호스트 터미널) |

---

## 🐛 트러블슈팅

### Dev Container 시작 안 됨

```bash
# Docker/OrbStack 실행 확인
docker ps

# 재시도
Cmd + Shift + P → Dev Containers: Rebuild Container
```

### Python 인터프리터 못 찾음

```
Cmd + Shift + P → Python: Select Interpreter
→ /usr/bin/python3.12 선택
```

### 포트 충돌

`.devcontainer/devcontainer.json`에서:
```json
"forwardPorts": [8001, 3001]
```

### pip 설치 실패

```bash
pip install --break-system-packages package-name
# 또는
pip install --upgrade pip
pip install -r /workspace/backend/requirements.txt
```

### Claude Code 인증 필요

컨테이너 내부 터미널에서:
```bash
claude
# 브라우저 인증 또는 API 키 입력 (1회)
```

---

## 📚 파일별 역할

| 파일 | 역할 |
|------|------|
| `.devcontainer/devcontainer.json` | Dev Container 설정 (마운트, 확장, 포트) |
| `.devcontainer/Dockerfile` | Dev Container + Docker Compose 공용 이미지 |
| `docker-compose.yml` | backend + frontend 서비스 정의 |
| `setup-and-run.sh` | Docker Compose 실행 (SSH 동기화, xhost 포함) |
| `docker_down.sh` | Docker Compose 중지 |

---

## ✨ 핵심 요약

| 작업 | 방법 |
|------|------|
| **Dev Container 시작** | `Cmd+Shift+P` → "Reopen in Container" |
| **Backend 실행** | `cd /workspace/backend && python -m uvicorn app:app --reload` |
| **Frontend 실행** | `cd /workspace/frontend && npm start` |
| **전체 스택 실행** | `./setup-and-run.sh` (호스트 터미널) |
| **중지** | `./docker_down.sh` 또는 `docker compose down` |
| **로그 확인** | `docker compose logs -f` |
