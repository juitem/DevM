# Dev Container 개발 가이드

Ubuntu 24.04 + Python 3.12 + Node.js 22 LTS 컨테이너 환경에서 개발하는 방법입니다.

---

## 🚀 시작하기

### 1단계: Cursor에서 폴더 열기

```bash
cursor ~/Docker/ContainerFolder/dockerTest
```

또는 `File > Open Folder` → `~/Docker/ContainerFolder/dockerTest`

### 2단계: Dev Container 시작

- `Cmd + Shift + P` → "Dev Containers: Reopen in Container"
- 또는 오른쪽 아래 `><` 버튼 → "Reopen in Container"

### 3단계: 빌드 완료 대기

첫 실행 시 이미지를 빌드합니다 (수 분 소요).
`.cursor-server` 캐시가 마운트되어 있어 이후 재시작은 빠릅니다.

---

## 💻 컨테이너 내부 개발

### Python 백엔드 실행

```bash
cd /workspace/backend
python -m uvicorn app:app --reload
```

```bash
# 새 터미널에서 API 확인
curl http://localhost:8000/api/status
```

### React 프론트엔드 실행

```bash
cd /workspace/frontend
npm install    # 첫 실행 시만
npm start
```

포트 포워딩: Backend(8000) 자동 / Frontend(3000) Ports 탭에서 수동 추가

---

## 🔧 설치된 개발 도구

### Python 3.12

| 도구 | 용도 |
|------|------|
| ipython | 향상된 Python 셸 |
| ipdb | Python 디버거 |
| pytest / pytest-cov | 테스트 |
| black | 코드 포매터 (저장 시 자동 적용) |
| flake8 | 코드 검사 |
| pylint | 린터 |
| mypy | 타입 검사 |

### Node.js 22 LTS

React 개발 전용 (frontend 서비스)

### Claude Code CLI

```bash
claude    # 컨테이너 전용 context로 실행
          # 첫 실행 시 인증 필요 (1회)
          # 인증 정보는 컨테이너 재생성 후에도 유지됨
```

---

## 🗂️ 자동 마운트 구성

Dev Container 시작 시 자동으로 마운트됩니다.

| 기능 | 호스트 경로 | 컨테이너 경로 |
|------|------------|--------------|
| SSH 키 | `ContainerFolder/ssh_docker` | `/home/juitem/.ssh` |
| Cursor 서버 캐시 | `ContainerFolder/CurSorServer` | `/home/juitem/.cursor-server` |
| Cursor 설정 | `ContainerFolder/CurSor` | `/home/juitem/.cursor` |
| Gemini 설정 | `ContainerFolder/GeMiNi` | `/home/juitem/.gemini` |
| Claude Code | `ContainerFolder/ClauDe` | `/home/juitem/.claude` |
| 공유 작업 공간 | `ContainerFolder` | `/home/juitem/ContainerFolder` |

---

## 🔑 SSH / Git

SSH 키가 자동 마운트되어 컨테이너 내부에서 바로 git 사용 가능합니다.

```bash
git clone git@github.com:username/repo.git
git push origin main
```

`setup-and-run.sh` 실행 시 `~/.ssh`가 `ssh_docker` 폴더로 자동 동기화됩니다.

---

## 🖥️ X11 GUI 앱 (XQuartz 필요)

macOS에서 컨테이너 내 GUI 앱을 사용하려면:

1. [XQuartz](https://www.xquartz.org) 설치 및 실행
2. `setup-and-run.sh` 실행 (자동으로 `xhost +localhost` 처리)
3. 컨테이너 내부에서 테스트:

```bash
xclock                                          # X11 기본 앱
python3 -c "import tkinter; tkinter.Tk()"       # Python GUI 테스트
```

---

## 📝 주요 경로

```bash
/workspace/           # 프로젝트 루트 (Dev Container workspaceFolder)
/workspace/backend/   # Python FastAPI 앱
/workspace/frontend/  # React 앱
/app/                 # backend 앱 코드 (Docker Compose 실행 시 working_dir)
/home/juitem/ContainerFolder/  # 호스트 ContainerFolder와 공유
```

---

## 🛑 Dev Container 제어

| 작업 | 명령 |
|------|------|
| 로컬로 복귀 | `Cmd+Shift+P` → "Reopen Folder Locally" |
| 재빌드 | `Cmd+Shift+P` → "Rebuild Container" |
| 완전 재빌드 | `Cmd+Shift+P` → "Rebuild Container (Without Cache)" |
| 이미지 삭제 | 호스트 터미널: `docker compose down --rmi all` |

---

## 🐛 트러블슈팅

### Dev Container 시작 실패

```bash
docker ps    # Docker/OrbStack 실행 확인
# 재시도: Cmd+Shift+P → Rebuild Container
```

### Python 인터프리터 못 찾음

```
Cmd + Shift + P → Python: Select Interpreter → /usr/bin/python3.12
```

### pip 설치 실패

```bash
pip install --break-system-packages package-name
```

### Claude Code 인증 필요

```bash
claude    # 컨테이너 내부 터미널에서 실행, 1회 인증
```

### 포트 충돌

`devcontainer.json`에서 포트 번호 변경 후 Rebuild:
```json
"forwardPorts": [8001]
```

---

## 💡 팁

### 디버깅 설정

`.vscode/launch.json` 생성:
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "FastAPI",
      "type": "python",
      "request": "launch",
      "module": "uvicorn",
      "args": ["app:app", "--reload"],
      "cwd": "/workspace/backend"
    }
  ]
}
```

### 추가 패키지 영구 설치

`.devcontainer/devcontainer.json`에 추가:
```json
"postCreateCommand": "pip install numpy pandas"
```

이후 `Rebuild Container` 실행

---

## 📚 참고

- [Dev Containers 공식 문서](https://containers.dev)
- [Cursor 문서](https://docs.cursor.sh)
- [프로젝트 전체 가이드](../README.md)
- [Cursor/Dev Container 빠른 설정](../CURSOR_SETUP.md)
