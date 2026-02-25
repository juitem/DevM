# Python + React GUI Docker Application

Ubuntu 24.04 + Python 3.13 + React 기반의 Docker 개발 환경입니다.

## 🚀 빠른 시작

### 자동 설정 및 실행 (권장)

```bash
cd /Users/juitem/Docker/dockerTest
./setup-and-run.sh
```

### 수동 실행

```bash
cd /Users/juitem/Docker/dockerTest
docker compose up -d
```

## 📋 시스템 요구사항

- **OrbStack** 또는 **Docker Desktop** (설치 및 실행 중)
- **Git** (선택)

## 🔗 접속 주소

- **Frontend UI**: http://localhost:3000
- **Backend API**: http://localhost:8000
- **API 상태 확인**: http://localhost:8000/api/status

## 📂 프로젝트 구조

```
dockerTest/
├── backend/
│   ├── Dockerfile          # Python 3.13 + FastAPI
│   ├── requirements.txt    # Python 의존성
│   └── app.py             # FastAPI 애플리케이션
├── frontend/
│   ├── Dockerfile         # Node.js + React
│   ├── package.json       # Node.js 의존성
│   ├── public/
│   │   └── index.html
│   └── src/
│       ├── App.js
│       ├── App.css
│       ├── index.js
│       └── index.css
├── docker-compose.yml     # Docker Compose 설정
├── setup-and-run.sh       # 자동 실행 스크립트
└── README.md
```

## 🛠️ 유용한 명령어

### 로그 확인
```bash
# 모든 서비스 로그
docker compose logs -f

# 특정 서비스 로그만
docker compose logs -f backend
docker compose logs -f frontend
```

### 서비스 상태 확인
```bash
docker compose ps
```

### 컨테이너에 접속
```bash
# Backend (Python)
docker compose exec backend bash

# Frontend (Node.js)
docker compose exec frontend sh
```

### 이미지 크기 확인
```bash
docker images | grep python-gui
```

### 서비스 재시작
```bash
docker compose restart
```

### 모든 것을 새로 빌드
```bash
docker compose up -d --build
```

### 서비스 중지 및 정리
```bash
# 컨테이너만 중지
docker compose stop

# 컨테이너 제거
docker compose down

# 이미지까지 삭제
docker compose down --rmi all
```

## 🔄 개발 워크플로우

### Python 백엔드 수정
1. `backend/app.py` 또는 `backend/requirements.txt` 수정
2. 자동으로 reload됨 (hot reload 활성화)

### React 프론트엔드 수정
1. `frontend/src/` 파일 수정
2. 자동으로 reload됨

### 새로운 Python 패키지 설치
```bash
# 1. requirements.txt에 추가
# 2. 아래 명령어 실행
docker compose up -d --build backend
```

### 새로운 Node.js 패키지 설치
```bash
# 1. frontend 폴더에서
npm install package-name

# 2. package.json 변경 감지 후 자동으로 재빌드됨
```

## 📚 API 예제

### 상태 조회
```bash
curl http://localhost:8000/api/status
```

응답:
```json
{
  "status": "running",
  "python_version": "3.13",
  "platform": "Ubuntu 24.04"
}
```

### 데이터 처리
```bash
curl -X POST http://localhost:8000/api/process \
  -H "Content-Type: application/json" \
  -d '{"data": "test"}'
```

응답:
```json
{
  "result": "Processed: {'data': 'test'}"
}
```

## 🐛 트러블슈팅

### 포트 충돌 (3000, 8000이 이미 사용 중)

`docker-compose.yml`을 수정하여 포트 변경:
```yaml
ports:
  - "3001:3000"  # 프론트엔드 포트 변경
  - "8001:8000"  # 백엔드 포트 변경
```

### 메모리 부족
```bash
# Docker 메모리 증가 (설정에서 조정 권장)
# Docker Desktop → Preferences → Resources
```

### 빌드 실패
```bash
# 이전 이미지 삭제 후 재빌드
docker compose down --rmi all
docker compose up -d --build
```

### npm/pip 설치 실패
```bash
# 캐시 삭제 및 재빌드
docker system prune -a
docker compose up -d --build
```

## 📝 커스터마이징

### Python 버전 변경
`backend/Dockerfile`에서:
```dockerfile
FROM python:3.13-slim  # 또는 다른 버전
```

### React 추가 패키지
`frontend/package.json`에 추가 후:
```bash
docker compose up -d --build frontend
```

### 데이터베이스 추가
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

## 🌍 배포 준비

### 프로덕션 빌드 (React)
```bash
docker compose exec frontend npm run build
```

### Docker 이미지 최적화
`frontend/Dockerfile`에서 멀티 스테이지 빌드 사용:
```dockerfile
FROM node:20-alpine AS builder
...
FROM node:20-alpine
COPY --from=builder /app/build ./build
```

## 📞 지원

문제가 발생하면:
1. 로그 확인: `docker compose logs -f`
2. Docker 상태 확인: `docker compose ps`
3. 시스템 정보 확인: `docker info`

## 📄 라이선스

MIT
