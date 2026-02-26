# Python + React Docker 개발 환경

Ubuntu 24.04 + Python 3.12 + React + Node.js 22 LTS 기반 Docker 개발 환경입니다.

## 📋 시스템 요구사항

- **OrbStack** 또는 **Docker Desktop** (실행 중)
- **macOS** (XQuartz - X11 앱 개발 시 선택)

---

## 📂 프로젝트 구조

```
~/Docker/ContainerFolder/
├── ssh_docker/               ← SSH 키 (setup-and-run.sh가 자동 동기화)
├── CurSorServer/             ← Cursor 서버 캐시 (Dev Container 재사용)
├── CurSor/                   ← Cursor 설정 영속
├── GeMiNi/                   ← Gemini AI 설정 영속
├── ClauDe/                   ← Claude Code CLI 설정 영속 (컨테이너 전용)
└── dockerTest/               ← 프로젝트 폴더
    ├── .devcontainer/
    │   ├── devcontainer.json  (Cursor/VS Code Dev Container 설정)
    │   ├── Dockerfile         (Dev Container + Docker Compose 공용 이미지)
    │   └── DEV_CONTAINER_GUIDE.md
    ├── backend/
    │   ├── Dockerfile         (미사용 - 참고용)
    │   ├── requirements.txt   (Python 의존성)
    │   └── app.py             (FastAPI 애플리케이션)
    ├── frontend/
    │   ├── Dockerfile         (React 전용 이미지)
    │   ├── package.json
    │   ├── public/
    │   └── src/
    ├── docker-compose.yml     (Docker Compose 설정)
    ├── setup-and-run.sh       (실행 스크립트)
    ├── docker_down.sh         (중지 스크립트)
    ├── CURSOR_SETUP.md        (Dev Container 가이드)
    └── README.md
```

---

## 🎯 두 가지 실행 방식

### 방식 1: Cursor / VS Code Dev Container (개발용 권장)

```
Cursor 열기 → "Reopen in Container"
  → devcontainer.json 읽음
  → docker-compose.yml 실행 (backend + frontend 모두 시작)
  → IDE가 backend 컨테이너 내부에 연결됨
```

→ 자세한 내용: [CURSOR_SETUP.md](CURSOR_SETUP.md)

### 방식 2: Docker Compose 직접 실행 (서비스 테스트용)

```bash
cd ~/Docker/ContainerFolder/dockerTest
./setup-and-run.sh
```

두 방식 모두 **동일한 `.devcontainer/Dockerfile` 이미지**를 사용합니다.

---

## 🚀 빠른 시작 (Docker Compose)

```bash
cd ~/Docker/ContainerFolder/dockerTest
./setup-and-run.sh
```

`setup-and-run.sh`는 실행 전 자동으로:
1. 마운트 폴더 생성 (`ContainerFolder` 하위)
2. `~/.ssh` → `ssh_docker` 동기화
3. macOS X11 접근 허용 (`xhost +localhost`)
4. Docker Compose 빌드 및 실행

### 접속 주소

| 서비스 | URL |
|--------|-----|
| Frontend UI | http://localhost:3000 |
| Backend API | http://localhost:8000 |
| API 상태 확인 | http://localhost:8000/api/status |

---

## 🛠️ 주요 명령어

### 실행 / 중지

```bash
# 실행 (SSH 동기화 + xhost 포함)
./setup-and-run.sh

# 중지
./docker_down.sh

# 수동 실행
docker compose up -d

# 수동 중지
docker compose down
```

### 컨테이너 접속

```bash
# backend (Python 환경)
docker compose exec backend bash

# frontend (Node.js 환경)
docker compose exec frontend sh

# root 권한으로 접속
docker compose exec --user root backend bash
```

### 로그 확인

```bash
docker compose logs -f
docker compose logs -f backend
docker compose logs -f frontend
```

### 이미지 재빌드

```bash
# 변경사항 반영하여 재빌드
docker compose up -d --build

# 캐시 없이 완전 재빌드
docker compose down --rmi all
docker compose up -d --build
```

---

## 🔧 이미지 구성

`.devcontainer/Dockerfile` 한 개로 Dev Container와 Docker Compose 모두 동작합니다.

### 설치된 환경

| 항목 | 버전 |
|------|------|
| OS | Ubuntu 24.04 |
| Python | 3.12 |
| Node.js | 22 LTS |
| pip 패키지 | FastAPI, uvicorn, pytest, black, flake8, pylint, mypy, ipython 등 |
| 기타 | Claude Code CLI, X11 지원 |

### 볼륨 마운트 (backend)

| 호스트 경로 | 컨테이너 경로 | 용도 |
|-------------|--------------|------|
| `./backend` | `/app` | 앱 코드 |
| `~/Docker/ContainerFolder/ssh_docker` | `/home/juitem/.ssh` | SSH 키 |
| `~/Docker/ContainerFolder` | `/home/juitem/ContainerFolder` | 공유 작업 공간 |
| `~/Docker/ContainerFolder/CurSor` | `/home/juitem/.cursor` | Cursor 설정 |
| `~/Docker/ContainerFolder/GeMiNi` | `/home/juitem/.gemini` | Gemini 설정 |
| `~/Docker/ContainerFolder/ClauDe` | `/home/juitem/.claude` | Claude Code 설정 |

---

## 🔄 개발 워크플로우

### Python 백엔드 수정

`backend/app.py` 수정 → uvicorn이 자동 reload

### Python 패키지 추가

```bash
# 1. requirements.txt에 추가
# 2. 재빌드
docker compose up -d --build backend
```

### React 프론트엔드 수정

`frontend/src/` 파일 수정 → 자동 reload

### Node.js 패키지 추가

```bash
# frontend 컨테이너 내부에서
npm install package-name
```

---

## 📚 API 예제

### 상태 조회

```bash
curl http://localhost:8000/api/status
```

응답:
```json
{
  "status": "running",
  "python_version": "3.12",
  "platform": "Ubuntu 24.04"
}
```

### 데이터 처리

```bash
curl -X POST http://localhost:8000/api/process \
  -H "Content-Type: application/json" \
  -d '{"data": "test"}'
```

---

## 🐛 트러블슈팅

### 포트 충돌 (3000, 8000)

`docker-compose.yml`에서 포트 변경:
```yaml
ports:
  - "3001:3000"
  - "8001:8000"
```

### 빌드 실패 / 이미지 초기화

```bash
docker compose down --rmi all
docker compose up -d --build
```

### 파일 권한 문제

`setup-and-run.sh`를 통해 실행하면 호스트 UID/GID로 빌드되어 자동 해결됩니다.

### X11 앱이 실행 안 됨

1. XQuartz 설치 및 실행
2. `setup-and-run.sh` 실행 (xhost 자동 설정)
3. 또는 수동으로: `xhost +localhost`

### SSH / git push 안 됨

`setup-and-run.sh` 실행 시 `~/.ssh`가 자동 동기화됩니다.
수동 동기화: `cp -r ~/.ssh/. ~/Docker/ContainerFolder/ssh_docker/`

---

## 🗄️ 데이터베이스 추가 예시

`docker-compose.yml`에 서비스 추가:
```yaml
services:
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_PASSWORD: password
    ports:
      - "5432:5432"
```
