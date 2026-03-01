# Ubuntu 24.04 based Dev Container
FROM ubuntu:24.04

# Inject host UID/GID at build time (for file permission alignment)
ARG USERNAME=juitem
ARG USER_ID=501
ARG GROUP_ID=20

# Environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    DEBIAN_FRONTEND=noninteractive \
    LANG=C.UTF-8 \
    LC_ALL=C.UTF-8 \
    DISPLAY=host.docker.internal:0

WORKDIR /workspace

# Install base packages
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

# Create user matching host UID/GID (prevents UID/GID conflicts)
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

# Install Python 3.12
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3.12 \
    python3.12-venv \
    python3.12-dev \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Set Python 3.12 as default
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.12 1 && \
    update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.12 1

# Install backend packages (same environment as in Docker Compose)
COPY backend/requirements.txt /tmp/requirements.txt
RUN pip install --break-system-packages --no-cache-dir -r /tmp/requirements.txt

# Install dev tools
RUN pip install --break-system-packages --no-cache-dir \
    ipython \
    ipdb \
    pytest \
    pytest-cov \
    black \
    flake8 \
    pylint \
    mypy

# Install Node.js 22 LTS (for React development, via NodeSource)
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/*

# VS Code server and SSH tools
RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-client \
    openssh-server \
    && rm -rf /var/lib/apt/lists/*

# X11 support (requires XQuartz on Mac)
RUN apt-get update && apt-get install -y --no-install-recommends \
    x11-apps \
    libx11-dev \
    python3-tk \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code CLI
RUN npm install -g @anthropic-ai/claude-code

# Switch to non-root user
USER $USERNAME

# Working directory
WORKDIR /home/juitem

# Default command
CMD ["/bin/bash"]
