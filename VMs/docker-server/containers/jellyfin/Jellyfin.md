# Jellyfin

## Overview
Jellyfin is a free, open-source media server for streaming movies, TV shows, music, and photos to any device. Runs as a Docker container on the docker-server with hardware transcoding support via Intel Quick Sync (iGPU passthrough). Managed via NPM for secure remote access.

## Access
- **Web UI:** `http://192.168.1.200:8096` (or `jellyfin.lab` via NPM)
- **DLNA/UPnP:** Enabled by default for local device discovery
- **API:** `http://192.168.1.200:8096/jellyfin/api` (for clients/apps)

## Structure
- **Config:** `/mnt/data/docker/jellyfin/config` → `/config` (metadata, users, settings)
- **Media Root:** `/mnt/data` → `/mnt/data` (read-only access to HDD)
- **Media Libraries:** Expected under `/mnt/data/media/` (movies, series, music, etc.)
- **Docker Compose:** `/mnt/data/docker/jellyfin/docker-compose.yml`

## Prerequisites
- Docker Server with HDD mounted at `/mnt/data`
- Intel iGPU passthrough configured in Proxmox VM (`/dev/dri` → `/dev/dri`)
- NPM for reverse proxy and SSL (optional but recommended)

## Deployment
1. Create the compose directory:
   ```bash
   mkdir -p /mnt/data/docker/jellyfin
   cd /mnt/data/docker/jellyfin
   ```
2. Create `docker-compose.yml`:
   ```yaml
   services:
     jellyfin:
       image: lscr.io/linuxserver/jellyfin:latest
       container_name: jellyfin
       environment:
         - PUID=1000
         - PGID=1000
         - TZ=America/Sao_Paulo
       volumes:
         - ./config:/config
         - /mnt/data:/mnt/data
       ports:
         - 8096:8096
       devices:
         - /dev/dri:/dev/dri
       restart: unless-stopped
   ```
3. Deploy:
   ```bash
   docker compose up -d
   ```
4. Access `http://192.168.1.200:8096` and complete the startup wizard (admin user, language).

## Configuration
- **Libraries:** Dashboard → **Libraries → Add Media Library**
  - Name: `Movies` / `Series` / `Music` / `Photos`
  - Type: Match content type
  - Folders: `/mnt/data/media/movies`, `/mnt/data/media/series`, etc.
  - Enable **Real-time monitoring** for automatic library updates.
- **Hardware Acceleration:** Dashboard → **Playback → Hardware Acceleration**
  - Enable **Intel Quick Sync (QSV)** for transcoding (requires `/dev/dri` passthrough).
  - Set **Transcoding temporary directory** to `/config/transcodes` (in RAM if tmpfs mounted).
- **Networking:** Dashboard → **Networking**
  - Set **Public HTTPS URL** for remote access (e.g., `https://jellyfin.lab`).
  - Enable **Allow remote connections**.
- **Users:** Create individual accounts; set library access and bandwidth limits.
- **Metadata:** Configure agents (TheMovieDB, TheTVDB, MusicBrainz) per library.

## Post-Install
- Add NPM proxy host: `jellyfin.lab` → `http://192.168.1.200:8096` with SSL, WebSocket support.
- Configure **Intel GPU passthrough** in Proxmox VM Hardware → Add → PCI Device → Select iGPU (non-exclusive).
- Test transcoding: play a 4K HEVC file on a client forcing transcode (check Dashboard → **Playback** for "QSV" indicator).
- Set up scheduled library scans (Dashboard → **Libraries → Scheduled Tasks**).
- Configure backup of `/config` (metadata, watched status, users) via rsync or Proxmox backup.

## Notes
- `PUID=1000`/`PGID=1000` matches the docker-server user; adjust if different.
- `/mnt/data` is mounted read-write; Jellyfin only reads media but can write metadata if configured.
- Intel Quick Sync requires `i915` driver on host (Proxmox) and `video` group access in container (handled by linuxserver image).
- For AMD/NVIDIA GPUs, change `devices` and use appropriate image tags.
- Remote access via NPM: ensure `proxy_set_header Upgrade $http_upgrade;` and `Connection "upgrade"` for WebSocket (SyncPlay, Live TV).
- Updates: `docker compose pull && docker compose up -d` (linuxserver images auto-rebuild weekly).