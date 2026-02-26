# 🎯 Dev Container 개발 가이드 (Cursor AI)

Cursor AI에서 Dev Container를 사용하여 컨테이너 내부에서 Python + React 개발을 할 수 있습니다.

## 🚀 시작하기

### 1단계: Cursor에서 폴더 열기

```bash
# 프로젝트 폴더를 Cursor에서 열기
cd /Users/juitem/Docker/dockerTest
cursor .
```

또는 Cursor에서 `File > Open Folder` → `/Users/juitem/Docker/dockerTest` 선택

### 2단계: Dev Container 시작

1. **Cursor 명령팔레트 열기**: `Cmd + Shift + P`
2. **명령 입력**: "Dev Containers: Reopen in Container"
3. **Enter** 누르기

또는 오른쪽 아래 초록색 버튼 `><` 클릭 → "Reopen in Container"

### 3단계: 자동 설정 완료 대기

- 첫 실행은 3-5분 소요
- Python 3.13 + 개발 도구 자동 설치
- 로그는 터미널에서 확인 가능

---

## 💻 Dev Container 내부에서 개발

### Python 백엔드 실행

Cursor 터미널 (Cmd + `)에서:

```bash
# 백엔드 실행
cd /workspace/backend
python -m uvicorn app:app --reload

# 또는 필요한 경우
pip install -r requirements.txt
python -m uvicorn app:app --reload
```

**API 테스트:**
```bash
# 새 터미널에서
curl http://localhost:8000/api/status
```

### React 프론트엔드 개발

다른 터미널에서:

```bash
cd /workspace/frontend

# 의존성 설치 (처음만)
npm install

# 개발 서버 실행
npm start
```

**포트 포워딩 자동 설정됨:**
- Backend (8000) → 자동 포워딩
- Frontend (3000) → 수동으로 포워딩 가능

---

## 🔍 Dev Container 기능

### ✅ 자동 활성화

- ✅ **Python 확장**: IntelliSense, 디버깅, 포매팅
- ✅ **Git 통합**: 컨테이너 내부에서 git 사용
- ✅ **포트 포워딩**: 8000번 포트 자동 포워딩
- ✅ **SSH/Git 자격증명**: 호스트의 설정 자동 마운트

### 📦 설치된 개발 도구

```
Python 3.13 + 개발 도구:
- ipython        (향상된 Python 셸)
- ipdb           (Python 디버거)
- pytest         (테스트 프레임워크)
- black          (코드 포매터)
- flake8         (코드 검사)
- pylint         (린터)
- mypy           (타입 검사)

Node.js 최신 버전 (React 개발용)
```

---

## 🎨 Cursor 설정 (자동 적용)

Dev Container 시작 시 자동으로 설정됩니다:

### Python 포매팅
- **Black** 자동 포매팅 (저장 시)
- **Ruff** 린팅

### 확장 프로그램
- Python 3.13 (Pylance)
- Git Lens
- GitHub Copilot
- Make Tools

---

## 🔗 포트 포워딩

### 자동 포워딩 (8000)
Backend API가 자동으로 포워딩됩니다.

### 수동 포트 추가 (Frontend 3000)

**방법 1: Cursor UI**
1. `Ports` 탭 클릭 (아래 패널)
2. `+` 버튼 → `3000` 입력

**방법 2: devcontainer.json 수정**
```json
"forwardPorts": [8000, 3000],
"portsAttributes": {
  "8000": { "label": "Backend" },
  "3000": { "label": "Frontend" }
}
```

---

## 📝 주요 명령어

### 터미널 명령어

```bash
# Python 버전 확인
python --version

# 현재 폴더
pwd

# 파일 구조
ls -la /workspace

# Backend 디렉토리
cd /workspace/backend

# Frontend 디렉토리
cd /workspace/frontend

# Python 패키지 설치
pip install package-name

# Node 패키지 설치
npm install package-name

# 테스트 실행 (pytest)
pytest

# 코드 품질 검사
flake8 app.py
pylint app.py
mypy app.py
```

---

## 🛑 Dev Container 종료/재시작

### 종료
Cursor 명령팔레트 (`Cmd + Shift + P`):
```
Dev Containers: Reopen Folder Locally
```

### 재시작
```
Dev Containers: Rebuild Container
```

### 완전 삭제
```bash
# 호스트 터미널에서
cd /Users/juitem/Docker/dockerTest
docker compose down --rmi all
```

---

## 🔄 Docker Compose와 함께 사용

### 시나리오 1: Dev Container만 사용 (권장)
- Cursor에서 Dev Container로 개발
- Backend + Frontend 코드 작성 및 테스트

### 시나리오 2: Docker Compose 전체 환경 + Dev Container

**호스트 터미널에서:**
```bash
cd /Users/juitem/Docker/dockerTest
docker compose up -d
```

**Cursor에서:**
- Dev Container로 Backend 개발
- http://localhost:3000으로 Frontend 접속

### 시나리오 3: Frontend 개발만

Cursor에서 `frontend` 서비스로 Dev Container 시작:

`.devcontainer/devcontainer.json` 수정:
```json
"service": "frontend",  // "backend" → "frontend"
```

---

## 🐛 트러블슈팅

### Dev Container 시작 실패

```bash
# Docker daemon 확인
docker ps

# OrbStack/Docker Desktop 재시작 후 다시 시도
```

### Python 패키지 설치 안 됨

```bash
# Dev Container 내부에서
pip install --upgrade pip
pip install -r /workspace/backend/requirements.txt
```

### 포트 충돌

`.devcontainer/devcontainer.json`에서 포트 변경:
```json
"forwardPorts": [8001],  // 8000 → 8001
```

### Git 명령어 작동 안 함

```bash
# Dev Container 내부에서
git config --global user.email "your-email@example.com"
git config --global user.name "Your Name"
```

---

## 💡 팁

### 1. 빠른 재시작
```
Dev Containers: Rebuild Container (Without Cache)
```
캐시 없이 완전히 재빌드

### 2. 기본 설정 변경
`.devcontainer/devcontainer.json` 수정 후:
```
Dev Containers: Rebuild Container
```

### 3. Cursor에서 Python 선택
```
Cmd + Shift + P → Python: Select Interpreter
→ /usr/bin/python3.13 선택
```

### 4. 디버깅 설정
`.vscode/launch.json` 생성:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Python: FastAPI",
      "type": "python",
      "request": "launch",
      "module": "uvicorn",
      "args": ["app:app", "--reload"],
      "cwd": "/workspace/backend"
    }
  ]
}
```

---

## 📚 참고 자료

- [Dev Containers 공식 문서](https://containers.dev)
- [Cursor AI 문서](https://docs.cursor.sh)
- [Docker Compose 문서](https://docs.docker.com/compose)

---

## ✨ 다음 단계

1. ✅ Dev Container 시작
2. ✅ Backend + Frontend 코드 작성
3. ✅ `docker-compose up -d`로 전체 테스트
4. ✅ 배포!

**Happy coding! 🚀**
