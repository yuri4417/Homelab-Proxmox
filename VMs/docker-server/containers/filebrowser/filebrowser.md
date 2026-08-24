# FileBrowser

## Overview
FileBrowser provides a web-based file manager for browsing, uploading, downloading, and editing files on the server. It exposes the Docker host's SSD (`/home/user/docker`) and HDD (`/mnt/data`) mounts through a clean UI with user authentication.

## Access
- **Web UI:** `http://192.168.1.200:8080` (or `files.lab` via NPM)
- **Default Login:** `admin` / `admin` (change on first login)

## Structure
- **Config/Data:** `/mnt/data/docker/filebrowser/data` → `/home/filebrowser/data` (SQLite DB, settings)
- **SSD Mount:** `~/docker` (host) → `/ssd` (container) — Docker project files
- **HDD Mount:** `/mnt/data` (host) → `/hdd` (container) — Media, backups, Nextcloud data
- **Docker Compose:** `/mnt/data/docker/filebrowser/docker-compose.yml`

## Prerequisites
- Docker Server running with HDD mounted at `/mnt/data`
- NPM for reverse proxy (optional)

## Deployment
1. Create the compose directory:
   ```bash
   mkdir -p /mnt/data/docker/filebrowser
   cd /mnt/data/docker/filebrowser
   ```
2. Create `docker-compose.yml`:
   ```yaml
   services:
     filebrowser:
       image: gtstef/filebrowser:stable
       container_name: filebrowser_quantum
       ports:
         - "8080:80"
       volumes:
         - ./data:/home/filebrowser/data
         - ~/docker:/ssd
         - /mnt/data:/hdd
       restart: unless-stopped
   ```
3. Deploy:
   ```bash
   docker compose up -d
   ```
4. Access `http://192.168.1.200:8080`, login with `admin`/`admin`, and change password immediately.

## Configuration
- **Users:** Add/manage users in **Settings → Users** (set home directory per user).
- **Branding:** Customize name, logo, theme in **Settings → Branding**.
- **File Permissions:** Toggle read-only, allow upload/download, execute per user.
- **Shares:** Create public share links for files/folders (expiring or permanent).
- **Reverse Proxy:** Add in NPM: `files.lab` → `http://192.168.1.200:8080` with SSL.

## Post-Install
- Set up NPM proxy host for `files.lab` with SSL and HTTP/2.
- Create dedicated users for family/team with restricted home directories.
- Configure automatic database backup (copy `data/filebrowser.db` periodically).
- Enable two-factor authentication (2FA) for admin user if available.

## Notes
- The container runs as root inside; host paths are mapped directly — ensure permissions align.
- `~/docker` expands to the deploying user's home; use absolute path (`/home/username/docker`) if deploying via different user.
- HDD mount (`/mnt/data`) provides access to all container data (Jellyfin media, Nextcloud files, backups).
- For read-only access to sensitive paths, create a separate user with limited scope.
- Resource usage is minimal (~20 MB RAM, negligible CPU).
- Updates: `docker compose pull && docker compose up -d`.