# 🚀 Cursor AI Dev Container 완벽 설정 가이드

**Ubuntu 24.04 + Python 3.13 + React + Cursor AI**

---

## 📋 전체 폴더 구조

```
dockerTest/
├── .devcontainer/                  ← Dev Container 설정 폴더
│   ├── devcontainer.json          (Cursor Dev Container 설정)
│   ├── Dockerfile                 (Dev Container용 이미지)
│   └── DEV_CONTAINER_GUIDE.md      (상세 가이드)
├── backend/
│   ├── Dockerfile                 (일반 Docker용 이미지)
│   ├── requirements.txt
│   └── app.py
├── frontend/
│   ├── Dockerfile
│   ├── package.json
│   ├── public/
│   └── src/
├── docker-compose.yml             (Docker Compose 설정)
├── setup-and-run.sh               (자동 실행 스크립트)
├── CURSOR_SETUP.md                (이 파일)
├── README.md                       (전체 프로젝트 가이드)
└── .gitignore
```

---

## 🎯 두 가지 개발 방식

### 방식 1️⃣: Cursor Dev Container (권장) ⭐

```
Cursor AI
  ↓
.devcontainer/devcontainer.json
  ↓
Ubuntu 24.04 + Python 3.13 (컨테이너)
  ↓
코드 편집 + 실행 + 디버깅
```

**장점:**
- ✅ Cursor 내부에서 완전한 개발 환경
- ✅ 컨테이너 내부 터미널 직접 접근
- ✅ Python IntelliSense, 디버깅 지원
- ✅ Git, npm, pip 모두 컨테이너 내부에서 실행

**추천 대상:** Cursor에서만 개발할 때

---

### 방식 2️⃣: Docker Compose (전체 환경)

```
docker compose up -d
  ↓
Backend (Python)  +  Frontend (React)
  ↓
http://localhost:3000  +  http://localhost:8000
```

**장점:**
- ✅ Backend + Frontend 동시 실행
- ✅ 배포 환경과 동일
- ✅ API + UI 통합 테스트

**추천 대상:** 전체 애플리케이션을 테스트할 때

---

## 🔥 빠른 시작 (Cursor Dev Container)

### Step 1: Cursor에서 폴더 열기

```bash
cursor /Users/juitem/Docker/dockerTest
```

또는:
- Cursor 실행
- `File > Open Folder`
- `/Users/juitem/Docker/dockerTest` 선택

### Step 2: Dev Container 시작

**방법 A: UI 버튼**
- 오른쪽 아래 초록색 `><` 버튼 클릭
- "Reopen in Container" 선택

**방법 B: 명령팔레트**
- `Cmd + Shift + P`
- "Dev Containers: Reopen in Container" 입력
- Enter

### Step 3: 자동 설정 대기 (3-5분)

터미널에서 진행 상황 확인:
```
[Container] Building...
[Container] Installing Python 3.13...
[Container] Installing dependencies...
[Container] Ready!
```

### Step 4: Backend 실행

Cursor 터미널 (`Cmd + ⌃ + `` `)에서:

```bash
cd /workspace/backend
python -m uvicorn app:app --reload
```

출력:
```
INFO:     Uvicorn running on http://0.0.0.0:8000
INFO:     Application startup complete
```

### Step 5: API 테스트

새 터미널 (`Cmd + ⌃ + `` `)에서:

```bash
curl http://localhost:8000/api/status
```

응답:
```json
{"status":"running","python_version":"3.13","platform":"Ubuntu 24.04"}
```

---

## 💻 Cursor에서 개발하기

### 터미널 작업

```bash
# Python 버전 확인
python --version  # 3.13

# 패키지 설치
pip install numpy pandas

# 테스트 실행
pytest

# 코드 검사
black --check app.py
flake8 app.py
```

### Frontend 개발 (Frontend도 같은 컨테이너)

```bash
cd /workspace/frontend
npm install
npm start
```

**포트 포워딩 자동 설정됨**: 3000도 자동 포워딩 추가 가능

### 디버깅

Cursor 좌측 패널 → `Run and Debug` (`Cmd + Shift + D`)

`.vscode/launch.json` 자동으로 Python 디버깅 지원

---

## 🔄 Docker Compose와 함께 사용

### 전체 스택 테스트하고 싶을 때

**호스트 터미널 (Cursor 외부)에서:**

```bash
# Cursor를 닫거나, 다른 터미널 열기
cd /Users/juitem/Docker/dockerTest

# 전체 환경 시작
./setup-and-run.sh

# 또는 수동으로
docker compose up -d

# 로그 확인
docker compose logs -f
```

**결과:**
- Backend: http://localhost:8000
- Frontend: http://localhost:3000

---

## ⚙️ Dev Container 커스터마이징

### 설치 도구 추가하기

`.devcontainer/devcontainer.json`에서:

```json
"postCreateCommand": "pip install --upgrade pip && pip install numpy pandas scipy"
```

그 후:
```
Cmd + Shift + P → Dev Containers: Rebuild Container
```

### 포트 포워딩 추가

`.devcontainer/devcontainer.json`에서:

```json
"forwardPorts": [8000, 3000, 5432],
"portsAttributes": {
  "8000": { "label": "Backend" },
  "3000": { "label": "Frontend" },
  "5432": { "label": "Database" }
}
```

### VS Code/Cursor 확장 추가

`.devcontainer/devcontainer.json`에서:

```json
"customizations": {
  "vscode": {
    "extensions": [
      "ms-python.python",
      "ms-python.vscode-pylance",
      "ms-python.debugpy",
      "charliermarsh.ruff"
    ]
  }
}
```

---

## 🛑 Dev Container 제어

### 다시 열기 (로컬로)
```
Cmd + Shift + P → Dev Containers: Reopen Folder Locally
```

### 재구축 (캐시 유지)
```
Cmd + Shift + P → Dev Containers: Rebuild Container
```

### 재구축 (캐시 삭제)
```
Cmd + Shift + P → Dev Containers: Rebuild Container (Without Cache)
```

### 삭제
```bash
# 호스트 터미널에서
cd /Users/juitem/Docker/dockerTest
docker compose down --rmi all
```

---

## 🐛 트러블슈팅

### ❌ "Dev Container 시작 안 됨"

**확인:**
1. Docker/OrbStack 실행 중인가?
   ```bash
   docker ps
   ```
2. 다시 시도:
   ```
   Cmd + Shift + P → Dev Containers: Rebuild Container
   ```

### ❌ "Python 인터프리터를 못 찾음"

Cursor에서:
```
Cmd + Shift + P → Python: Select Interpreter
→ /usr/bin/python3.13 선택
```

### ❌ "포트 충돌 (3000, 8000 이미 사용 중)"

`.devcontainer/devcontainer.json`에서 포트 변경:
```json
"forwardPorts": [8001, 3001]
```

### ❌ "npm/pip 설치 실패"

```bash
# Dev Container 내부에서
pip install --upgrade pip
npm install -g npm@latest

# 다시 설치
pip install -r /workspace/backend/requirements.txt
```

---

## 📚 파일별 설명

| 파일 | 용도 |
|---|---|
| `.devcontainer/devcontainer.json` | Cursor Dev Container 설정 |
| `.devcontainer/Dockerfile` | Dev Container 이미지 (Python 3.13 + 개발 도구) |
| `docker-compose.yml` | Docker Compose 설정 (일반 실행) |
| `backend/Dockerfile` | Backend 이미지 (프로덕션용) |
| `setup-and-run.sh` | Docker Compose 자동 실행 스크립트 |

---

## 🎨 Cursor 추천 설정

Cursor 설정 (`Cursor > Preferences > Settings`):

```json
{
  "python.defaultInterpreterPath": "/usr/bin/python3.13",
  "python.formatting.provider": "black",
  "[python]": {
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "ms-python.python"
  },
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.organizeImports": "explicit"
  }
}
```

---

## 🚀 다음 단계

### 1️⃣ 즉시 시작
```bash
cursor /Users/juitem/Docker/dockerTest
# → Cmd + Shift + P → Dev Containers: Reopen in Container
```

### 2️⃣ Backend 개발
```bash
cd /workspace/backend
python -m uvicorn app:app --reload
```

### 3️⃣ Frontend 개발
```bash
cd /workspace/frontend
npm install && npm start
```

### 4️⃣ 통합 테스트
```bash
# 호스트 터미널에서
cd /Users/juitem/Docker/dockerTest
docker compose up -d
```

### 5️⃣ 배포
문서 참고: [`README.md`](README.md)

---

## 📖 추가 정보

- **Dev Container 공식 문서**: https://containers.dev
- **Cursor AI 문서**: https://docs.cursor.sh
- **상세 가이드**: [`.devcontainer/DEV_CONTAINER_GUIDE.md`](.devcontainer/DEV_CONTAINER_GUIDE.md)
- **프로젝트 전체**: [`README.md`](README.md)

---

## ✨ 핵심 요약

| 작업 | 명령어 |
|---|---|
| **Cursor로 열기** | `cursor /Users/juitem/Docker/dockerTest` |
| **Dev Container 시작** | `Cmd + Shift + P` → "Reopen in Container" |
| **Backend 실행** | `python -m uvicorn app:app --reload` |
| **Frontend 실행** | `npm start` |
| **전체 스택 테스트** | `docker compose up -d` |
| **로그 보기** | `docker compose logs -f` |
| **Dev Container 재시작** | `Cmd + Shift + P` → "Rebuild Container" |

---

**축하합니다! 🎉 Cursor AI + Dev Container 개발 환경이 완성되었습니다!**

**Happy coding! 🚀**
