# Ubuntu 24.04 기반 Python 3.13
FROM ubuntu:24.04

# 환경 변수 설정
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    DEBIAN_FRONTEND=noninteractive

WORKDIR /app

# 시스템 패키지 업데이트 및 필요한 도구 설치
RUN apt-get update && apt-get install -y \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    python3-pip \
    git \
    curl \
    build-essential \
    libssl-dev \
    libffi-dev \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Mac 사용자(juitem) 생성 및 sudo 권한
RUN useradd -m -s /bin/bash juitem && \
    usermod -aG sudo juitem && \
    echo "juitem ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/juitem && \
    chmod 0440 /etc/sudoers.d/juitem

# Python 3.13을 기본 python으로 설정
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

# 의존성 설치
COPY requirements.txt .
RUN pip install --break-system-packages --no-cache-dir -r requirements.txt

# 소스코드 복사
COPY . .

# FastAPI 실행 (포트 8000)
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
