# devM - Dev Container 템플릿

Python (FastAPI) + React 개발 환경을 위한 Docker Dev Container 템플릿 모음.

## 폴더 구조

```
devM/
├── forMac/
│   ├── DockerCompose/   # Mac + 컨테이너 분리 방식
│   └── DockerSingle/    # Mac + 단일 컨테이너 방식
└── forUbuntu/
    ├── DockerCompose/   # Ubuntu + 컨테이너 분리 방식
    └── DockerSingle/    # Ubuntu + 단일 컨테이너 방식
```

---

## 방식 선택

### DockerCompose vs DockerSingle

| | DockerCompose | DockerSingle |
|---|---|---|
| 컨테이너 수 | backend + frontend 각각 | 하나로 통합 |
| Dev Container 진입 | backend 컨테이너에만 attach | 전체 접근 가능 |
| frontend 터미널 접근 | 호스트에서 `docker compose exec frontend sh` | 동일 터미널에서 가능 |
| 서버 시작 | 컨테이너 기동 시 자동 (uvicorn) | `bash dev-start.sh` 수동 실행 |

### forMac vs forUbuntu

| | forMac | forUbuntu |
|---|---|---|
| USER_ID 기본값 | 501 | 1000 |
| GROUP_ID 기본값 | 20 (staff) | 1000 |
| Docker 런타임 | OrbStack (권장) / Docker Desktop | Docker Engine |
| X11 (GUI 앱) | XQuartz + `host.docker.internal:0` | `/tmp/.X11-unix` 소켓 마운트 |
| host 접근 | OrbStack/Docker Desktop 자동 처리 | `--add-host=host.docker.internal:host-gateway` |
| 브라우저 자동 열기 | `open` | `xdg-open` |

---

## 사용법

### DockerCompose (Mac)

```bash
# 최초 설치 / 전체 초기화
bash forMac/DockerCompose/setup-and-run.sh

# 일상적인 시작
bash forMac/DockerCompose/run.sh

# 중지
bash forMac/DockerCompose/docker_down.sh
```

Dev Container로 개발할 때는 Cursor/VS Code에서 `forMac/DockerCompose` 폴더를 열고
**Reopen in Container** 선택.

### DockerCompose (Ubuntu)

```bash
bash forUbuntu/DockerCompose/setup-and-run.sh
bash forUbuntu/DockerCompose/run.sh
bash forUbuntu/DockerCompose/docker_down.sh
```

### DockerSingle (Mac / Ubuntu)

호스트에서 별도 스크립트 없음. Cursor/VS Code에서 해당 폴더를 열고
**Reopen in Container** → 컨테이너 진입 후 터미널에서:

```bash
bash ~/ContainerFolder/devM/forMac/DockerSingle/dev-start.sh
# 또는
bash ~/ContainerFolder/devM/forUbuntu/DockerSingle/dev-start.sh
```

`dev-start.sh`는 기존에 실행 중인 프로세스를 종료하고 재시작함.

---

## 접속 정보

| 서비스 | URL |
|--------|-----|
| Frontend (React) | http://localhost:3000 |
| Backend (FastAPI) | http://localhost:8000 |
| API 상태 확인 | http://localhost:8000/api/status |

---

## 공통 스펙

- OS: Ubuntu 24.04
- Python: 3.12
- Node.js: 22 LTS
- 기본 설치 패키지: `nano`, `tree`, `mc`, `zip`, `unzip`, `lsof`, `iproute2`
- 마운트: `~/.ssh`, `~/.cursor`, `~/.claude`, `~/.gemini`, `ContainerFolder` 전체

---

## devcontainer.json 주요 설정 비교

### forMac
```json
"containerEnv": { "DISPLAY": "host.docker.internal:0" }
```

### forUbuntu
```json
"runArgs": ["--add-host=host.docker.internal:host-gateway"],
"containerEnv": { "DISPLAY": ":0" },
"mounts": [ "source=/tmp/.X11-unix,target=/tmp/.X11-unix,type=bind" ]
```

---

## Rebuild vs Reopen

| 변경 파일 | 필요한 작업 |
|-----------|------------|
| `Dockerfile` | **Rebuild Container** |
| `devcontainer.json` | Reopen in Container |
| `docker-compose.yml` | Reopen in Container |
| `dev-start.sh` | 즉시 반영 (스크립트 재실행) |
