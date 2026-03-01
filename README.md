# devM - Dev Container Templates

A collection of Docker Dev Container templates for Python (FastAPI) + React development environments.

## Folder Structure

```
devM/
├── forMac/
│   ├── DockerCompose/   # Mac + separate containers
│   └── DockerSingle/    # Mac + single container
└── forUbuntu/
    ├── DockerCompose/   # Ubuntu + separate containers
    └── DockerSingle/    # Ubuntu + single container
```

---

## Choosing a Setup

### DockerCompose vs DockerSingle

| | DockerCompose | DockerSingle |
|---|---|---|
| Containers | backend + frontend separately | combined into one |
| Dev Container attach | backend container only | full access |
| frontend terminal access | `docker compose exec frontend sh` from host | available in same terminal |
| Server startup | automatic on container start (uvicorn) | run `bash dev-start.sh` manually |

### forMac vs forUbuntu

| | forMac | forUbuntu |
|---|---|---|
| USER_ID default | 501 | 1000 |
| GROUP_ID default | 20 (staff) | 1000 |
| Docker runtime | OrbStack (recommended) / Docker Desktop | Docker Engine |
| X11 (GUI apps) | XQuartz + `host.docker.internal:0` | `/tmp/.X11-unix` socket mount |
| host access | handled automatically by OrbStack/Docker Desktop | `--add-host=host.docker.internal:host-gateway` |
| open browser | `open` | `xdg-open` |

---

## Usage

### DockerCompose (Mac)

```bash
# Initial setup / full reset
bash forMac/DockerCompose/setup-and-run.sh

# Daily start
bash forMac/DockerCompose/run.sh

# Stop
bash forMac/DockerCompose/docker_down.sh
```

For development with Dev Container, open the `forMac/DockerCompose` folder in Cursor/VS Code and select **Reopen in Container**.

### DockerCompose (Ubuntu)

```bash
bash forUbuntu/DockerCompose/setup-and-run.sh
bash forUbuntu/DockerCompose/run.sh
bash forUbuntu/DockerCompose/docker_down.sh
```

### DockerSingle (Mac / Ubuntu)

No host script needed. Open the folder in Cursor/VS Code, select **Reopen in Container**, then from the terminal inside the container:

```bash
bash ~/ContainerFolder/devM/forMac/DockerSingle/dev-start.sh
# or
bash ~/ContainerFolder/devM/forUbuntu/DockerSingle/dev-start.sh
```

`dev-start.sh` stops any running processes and restarts them.

---

## Access URLs

| Service | URL |
|--------|-----|
| Frontend (React) | http://localhost:3000 |
| Backend (FastAPI) | http://localhost:8000 |
| API status | http://localhost:8000/api/status |

---

## Common Specs

- OS: Ubuntu 24.04
- Python: 3.12
- Node.js: 22 LTS
- Default packages: `nano`, `tree`, `mc`, `zip`, `unzip`, `gitk`, `lsof`, `iproute2`

### Mount List

| Host path (`~/Docker/ContainerFolder/`) | Container path |
|------------------------------------------|---------------|
| `ssh_docker/` | `~/.ssh` |
| `CurSorServer/` | `~/.cursor-server` |
| `CurSor/` | `~/.cursor` |
| `GeMiNi/` | `~/.gemini` |
| `ClauDe/` | `~/.claude` |
| `GitConfig/.gitconfig` | `~/.gitconfig` |
| `NpM/` | `~/.npm` |
| `BashAliases/.bash_aliases` | `~/.bash_aliases` |
| `AntiGravity/` | `~/.antigravity` |
| `CodeGpt/` | `~/.codegpt` |
| `Codex/` | `~/.codex` |
| `ContainerFolder/` (full) | `~/ContainerFolder` |

> `~/.bash_aliases` is automatically sourced by Ubuntu's default `.bashrc`.

**Before first run, prepare the following directories/files on the host:**
```bash
mkdir -p ~/Docker/ContainerFolder/GitConfig
mkdir -p ~/Docker/ContainerFolder/NpM
mkdir -p ~/Docker/ContainerFolder/BashAliases
touch ~/Docker/ContainerFolder/BashAliases/.bash_aliases

# Copy gitconfig (Mac)
cp ~/.gitconfig ~/Docker/ContainerFolder/GitConfig/.gitconfig
```

---

## X11 GUI Apps (gitk, etc.) - Mac only

Setup for `gitk` and other X11 apps in OrbStack + XQuartz environment:

1. **Install XQuartz**: https://www.xquartz.org
2. **Allow network connections**: XQuartz → Preferences → Security tab → check **"Allow connections from network clients"**
3. **Restart XQuartz** (required after changing the setting)
4. Start XQuartz before opening the container

**Authentication is handled automatically:**
- **DockerCompose**: `setup-and-run.sh` generates `xhost +local:` and the X11 auth cookie (`/tmp/.docker.xauth`) automatically
- **DockerSingle**: cookie is generated via `initializeCommand` when Reopen in Container is run in VS Code

> **How it works**: OrbStack containers connect to XQuartz over TCP, so MIT-MAGIC-COOKIE authentication is required.
> The command `xauth nlist :0 | sed 's/^..../ffff/'` generates a FamilyWild cookie, saves it to `/tmp/.docker.xauth`, and mounts it as `.Xauthority` inside the container.

Ubuntu uses `/tmp/.X11-unix` socket mount, so no additional setup is needed.

---

## devcontainer.json Key Settings Comparison

### forMac
```json
"initializeCommand": ["bash", "-c", "touch /tmp/.docker.xauth; xauth nlist :0 | sed 's/^..../ffff/' | xauth -f /tmp/.docker.xauth nmerge -; true"],
"containerEnv": { "DISPLAY": "host.docker.internal:0", "XAUTHORITY": "/home/juitem/.Xauthority" },
"mounts": [ "source=/tmp/.docker.xauth,target=/home/juitem/.Xauthority,type=bind,consistency=cached" ]
```

### forUbuntu
```json
"runArgs": ["--add-host=host.docker.internal:host-gateway"],
"containerEnv": { "DISPLAY": ":0" },
"mounts": [ "source=/tmp/.X11-unix,target=/tmp/.X11-unix,type=bind" ]
```

---

## Rebuild vs Reopen

| Changed file | Required action |
|-----------|------------|
| `Dockerfile` | **Rebuild Container** |
| `devcontainer.json` | Reopen in Container |
| `docker-compose.yml` | Reopen in Container |
| `dev-start.sh` | immediate (re-run the script) |
