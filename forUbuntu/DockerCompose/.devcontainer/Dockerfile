# Ubuntu 24.04 기반 Dev Container
FROM ubuntu:24.04

ARG USERNAME=juitem
ARG USER_ID=1000
ARG GROUP_ID=1000

ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    DISPLAY=:0

WORKDIR /workspace

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    ca-certificates \
    curl \
    git \
    wget \
    sudo \
    nano \
    tree \
    mc \
    zip \
    unzip \
    gitk \
    && rm -rf /var/lib/apt/lists/*

# 호스트 UID/GID와 일치하는 사용자 생성
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

# Python 3.12
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

# Backend 패키지 설치
COPY backend/requirements.txt /tmp/requirements.txt
RUN pip install --break-system-packages --no-cache-dir -r /tmp/requirements.txt

# 개발 도구
RUN pip install --break-system-packages --no-cache-dir \
    ipython ipdb pytest pytest-cov black flake8 pylint mypy

# Node.js 22 LTS
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# SSH + X11 + 네트워크 도구
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-client \
    openssh-server \
    x11-apps \
    libx11-dev \
    python3-tk \
    lsof \
    iproute2 \
    && rm -rf /var/lib/apt/lists/*

# Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

RUN mkdir -p /workspace && chown ${USER_ID}:${GROUP_ID} /workspace

USER $USERNAME
WORKDIR /workspace

CMD ["/bin/bash"]
