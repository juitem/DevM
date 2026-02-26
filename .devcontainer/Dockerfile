# Ubuntu 24.04 기반 Dev Container
FROM ubuntu:24.04

# 호스트 PC의 UID/GID를 빌드 시 주입 (파일 권한 일치)
ARG USERNAME=juitem
ARG USER_ID=501
ARG GROUP_ID=20

# 환경 변수 설정
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    DISPLAY=host.docker.internal:0

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

# 호스트 UID/GID와 일치하는 사용자 생성 (기존 UID/GID 충돌 방지)
RUN if ! getent group $GROUP_ID > /dev/null; then \
        groupadd -g $GROUP_ID $USERNAME; \
    fi && \
    if ! getent passwd $USER_ID > /dev/null; then \
        useradd -m -u $USER_ID -g $GROUP_ID -s /bin/bash $USERNAME; \
    else \
        existing_user=$(getent passwd $USER_ID | cut -d: -f1); \
        if [ "$existing_user" != "$USERNAME" ]; then \
            usermod -l $USERNAME $existing_user; \
        fi; \
    fi && \
    usermod -aG sudo $USERNAME && \
    echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers.d/$USERNAME && \
    chmod 0440 /etc/sudoers.d/$USERNAME

# Python 3.12 설치
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Python 3.12를 기본 python으로 설정
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

# Node.js 22 LTS 설치 (React 개발용, NodeSource)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# VS Code 서버 및 SSH 도구
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-client \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

# X11 지원 (GUI 앱 개발용 - XQuartz 필요)
RUN apt-get update && apt-get install -y --no-install-recommends \
    x11-apps \
    libx11-dev \
    python3-tk \
    && rm -rf /var/lib/apt/lists/*

# Claude Code CLI 설치 (컨테이너 전용 context 사용)
RUN npm install -g @anthropic-ai/claude-code

# /workspace 소유권을 사용자에게 부여
RUN mkdir -p /workspace && chown ${USER_ID}:${GROUP_ID} /workspace

# 비루트 사용자로 전환
USER $USERNAME

# 작업 디렉토리
WORKDIR /workspace

# 기본 명령어
CMD ["/bin/bash"]
