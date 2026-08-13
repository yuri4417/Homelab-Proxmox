# R-Stack (Radarr, Sonarr, Prowlarr, qBittorrent, Bazarr, FlareSolverr)

## Overview
The *R-Stack* is a complete automated media acquisition pipeline:
- **qBittorrent** — Torrent client (downloads)
- **Prowlarr** — Indexer manager/proxy (search aggregation)
- **Radarr** — Movie collection manager (automation)
- **Sonarr** — TV series collection manager (automation)
- **Bazarr** — Subtitle downloader (automation)
- **FlareSolverr** — Cloudflare challenge solver (for protected indexers)

All services run as Docker containers on the docker-server, sharing `/mnt/data/media` for hardlink-based instant moves.

## Access
| Service | Port | URL (local) | URL (via NPM) |
|---------|------|-------------|---------------|
| qBittorrent | 8090 | `http://192.168.1.200:8090` | `qbit.lab` |
| Prowlarr | 9696 | `http://192.168.1.200:9696` | `prowlarr.lab` |
| Radarr | 7878 | `http://192.168.1.200:7878` | `radarr.lab` |
| Sonarr | 8989 | `http://192.168.1.200:8989` | `sonarr.lab` |
| Bazarr | 6767 | `http://192.168.1.200:6767` | `bazarr.lab` |
| FlareSolverr | 8191 | `http://192.168.1.200:8191` | Internal only |

## Structure
- **Config Root:** `/mnt/data/docker/r-stack/config/`
  - `qbittorrent/`, `radarr/`, `sonarr/`, `prowlarr/`, `bazarr/`
- **Media Root:** `/mnt/data/media/` (shared, hardlink-enabled)
  - `movies/`, `series/`, `music/` — managed by Radarr/Sonarr
- **Downloads:** `/mnt/data/media/downloads/` (qBittorrent save path)
- **Docker Compose:** `/mnt/data/docker/r-stack/docker-compose.yml`

## Prerequisites
- Docker Server with HDD mounted at `/mnt/data`
- Media folder structure created: `/mnt/data/media/{movies,series,downloads}`
- NPM for reverse proxy (optional but recommended for all *arr apps)
- VPN for qBittorrent (recommended; not configured here)

## Deployment
1. Create the compose directory and config structure:
   ```bash
   mkdir -p /mnt/data/docker/r-stack/config/{qbittorrent,radarr,sonarr,prowlarr,bazarr}
   mkdir -p /mnt/data/media/{movies,series,downloads}
   cd /mnt/data/docker/r-stack
   ```
2. Create `docker-compose.yml` (see full file in repository).
3. Deploy all services:
   ```bash
   docker compose up -d
   ```
4. Access each web UI and complete initial setup (admin user, timezone).

## Configuration

### qBittorrent (Port 8090)
1. **WebUI:** Set username/password in **Tools → Options → WebUI**.
2. **Downloads:** **Tools → Options → Downloads → Saving Management**
   - Default save path: `/mnt/data/media/downloads`
   - Enable "Create subfolder for each torrent"
3. **Connection:** Optional — configure VPN interface if used.
4. **Categories:** Add `radarr` and `sonarr` categories (used by *arr apps).

### Prowlarr (Port 9696)
1. **Indexers:** **Indexers → Add Indexer** — add public/private trackers (1337x, RARBG mirrors, etc.).
2. **Apps:** **Settings → Apps → Add** — connect Radarr and Sonarr:
   - Name: `radarr` / `sonarr`
   - URL: `http://radarr:7878` / `http://sonarr:8989` (Docker DNS)
   - API Key: Copy from Radarr/Sonarr **Settings → General → Security**
   - Sync categories: Enable
3. **FlareSolverr:** **Settings → Indexers → FlareSolverr** — add `http://flaresolverr:8191`.

### Radarr (Port 7878) & Sonarr (Port 8989)
1. **Download Clients:** **Settings → Download Clients → Add → qBittorrent**
   - Host: `qbittorrent` (Docker DNS) / Port: `8090`
   - Username/Password: From qBittorrent WebUI
   - Category: `radarr` / `sonarr`
2. **Media Management:** **Settings → Media Management**
   - Enable **Use Hardlinks instead of Copy** (instant, space-efficient)
   - Set **Root Folders**: `/mnt/data/media/movies` (Radarr), `/mnt/data/media/series` (Sonarr)
3. **Indexers:** Verify Prowlarr sync under **Settings → Indexers**.
4. **Quality Profiles:** Configure preferred qualities (1080p, 4K, etc.).
5. **Import Lists:** Optional — connect Trakt, IMDb, or custom lists.

### Bazarr (Port 6767)
1. **Sonarr/Radarr:** **Settings → Sonarr/Radarr → Add**
   - Host: `sonarr` / `radarr` (Docker DNS)
   - Port: `8989` / `7878`
   - API Key: From respective app
2. **Providers:** **Settings → Providers** — enable OpenSubtitles, Subscene, etc. (add API keys if needed).
3. **Languages:** **Settings → Languages** — add desired languages (Portuguese, English, etc.).
4. **Profile:** Create download profile matching preferred languages/sources.

### FlareSolverr (Port 8191)
- No configuration needed; works out of the box.
- Used automatically by Prowlarr for Cloudflare-protected indexers.

## Post-Install
- Add NPM proxy hosts for each *arr app with SSL and WebSocket support.
- Test end-to-end: add a movie in Radarr → verify search (Prowlarr) → download (qBittorrent) → import (Radarr) → subtitle (Bazarr).
- Configure **Recycle Bin** in qBittorrent for failed downloads cleanup.
- Set up **Health Checks** in Radarr/Sonarr (Dashboard → System → Health) — resolve warnings.
- Backup: `/mnt/data/docker/r-stack/config/` contains all app configs and databases.

## Notes
- All *arr apps use Docker DNS (`radarr`, `sonarr`, `qbittorrent`, etc.) for inter-container communication — no host IPs needed.
- Hardlinks require same filesystem: `/mnt/data/media` and `/mnt/data/media/downloads` must be on same mount (they are).
- Prowlarr `develop` tag used for latest features; switch to `latest` for stability.
- FlareSolverr consumes ~200 MB RAM; monitor if running many indexers.
- For VPN: add `network_mode: "service:gluetun"` (requires Gluetun container) to qBittorrent and *arr apps.
- Updates: `docker compose pull && docker compose up -d` (linuxserver images rebuild weekly).