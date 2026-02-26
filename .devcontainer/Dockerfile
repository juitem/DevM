# Ubuntu 24.04 기반 Dev Container
FROM ubuntu:24.04

# 환경 변수 설정
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8

WORKDIR /workspace

# 기본 패키지 업데이트
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    wget \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Mac 사용자(juitem) 생성 및 sudo 권한
RUN useradd -m -s /bin/bash juitem && \
    usermod -aG sudo juitem && \
    echo "juitem ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/juitem && \
    chmod 0440 /etc/sudoers.d/juitem

# Python 3.12 설치
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Python 3.13을 기본 python으로 설정
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

# Backend 패키지 설치 (Docker Compose 실행 시에도 동일 환경)
COPY backend/requirements.txt /tmp/requirements.txt
RUN pip install --break-system-packages --no-cache-dir -r /tmp/requirements.txt

# 개발 도구 설치
RUN pip install --break-system-packages --no-cache-dir \
    ipython \
    ipdb \
    pytest \
    pytest-cov \
    black \
    flake8 \
    pylint \
    mypy

# Node.js 20 LTS 설치 (React 개발용, NodeSource)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# VS Code 서버를 위한 필수 도구
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-client \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

# 작업 디렉토리 설정
WORKDIR /workspace

# 기본 명령어
CMD ["/bin/bash"]
