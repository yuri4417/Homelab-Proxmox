# Nextcloud (AIO) + Syncthing

## Overview
Nextcloud All-in-One (AIO) provides a complete self-hosted cloud platform with office suite (Collabora), file sync, calendar, contacts, and more. Paired with Syncthing for peer-to-peer folder synchronization across devices, with Syncthing folders exposed as Nextcloud external storage.

## Access
| Service | Port | URL (local) | URL (via NPM) |
|---------|------|-------------|---------------|
| Nextcloud AIO Mastercontainer | 8090 | `http://192.168.1.200:8090` | `aio.lab` (setup only) |
| Nextcloud (Apache) | 11000 | `http://192.168.1.200:11000` | `cloud.lab` |
| Syncthing Web UI | 8384 | `http://192.168.1.200:8384` | `syncthing.lab` |

## Structure
- **Nextcloud Data:** `/mnt/data/cloud` → `/mnt/data/cloud` (AIO datadir)
- **Syncthing Config:** `/mnt/data/docker/nextcloud/syncthing_config` → `/config`
- **Syncthing Shared:** `/mnt/data/syncthing_shared` → `/mnt/data/syncthing_shared` (bidirectional sync)
- **AIO Config:** Docker volume `nextcloud_aio_mastercontainer` → `/mnt/docker-aio-config`
- **Certificates:** `/opt/nextcloud/certs` → `/mnt/trusted_certs` (for trusted CAs)
- **Docker Compose:** `/mnt/data/docker/nextcloud/docker-compose.yml`

## Prerequisites
- Docker Server with HDD mounted at `/mnt/data`
- Docker socket access (`/var/run/docker.sock`) for AIO container management
- NPM for reverse proxy (required for Collabora/WebDAV to work properly)
- Domain/subdomain for `cloud.lab` with valid SSL (Let's Encrypt via NPM)

## Deployment
1. Create directories:
   ```bash
   mkdir -p /mnt/data/cloud /mnt/data/syncthing_shared
   mkdir -p /mnt/data/docker/nextcloud
   cd /mnt/data/docker/nextcloud
   ```
2. Create `docker-compose.yml` (see repository file).
3. Deploy:
   ```bash
   docker compose up -d
   ```
4. Access **Nextcloud AIO Mastercontainer** at `http://192.168.1.200:8090`.
5. Complete AIO setup:
   - Set domain: `cloud.lab` (must resolve to docker-server IP)
   - Enable **Nextcloud Office (Collabora Online)**
   - Select add-ons: **Whiteboard**, **Imaginary** (image optimization)
   - Start Nextcloud — AIO pulls and configures all containers automatically.
6. Access **Nextcloud** at `https://cloud.lab` (via NPM) or `http://192.168.1.200:11000`.
7. Access **Syncthing** at `http://192.168.1.200:8384` — set GUI password in **Settings → GUI**.

## Configuration

### Nextcloud AIO
- **Trusted Domains:** AIO manages automatically via `SKIP_DOMAIN_VALIDATION=true`.
- **Collabora Office:** Enabled during setup; runs in separate AIO-managed container.
- **Apps:** Install via **Apps** menu: Forms, Deck, Calendar, Contacts, etc.
- **Backups:** AIO includes built-in backup/restore (Settings → Backup).

### Syncthing
1. **Devices:** Add remote device IDs (phones, laptops, other servers).
2. **Folders:** Share `/mnt/data/syncthing_shared` subfolders:
   - `codigos` → **Folder ID:** `codigos` → **Path:** `/mnt/data/syncthing_shared/codigos`
   - `obsidian` → **Folder ID:** `obsidian` → **Path:** `/mnt/data/syncthing_shared/obsidian`
3. **Ignore Patterns:** Add `.stfolder`, `*.tmp`, `~*` in folder settings.

### Nextcloud External Storage (Syncthing Folders)
1. Enable **External storage support** app: **Apps → Disabled → External storage support → Enable**.
2. **Settings → Administration → External storages:**
   - **Folder name:** `Documentos/Codigos` → **External storage:** Local → **Configuration:** `/mnt/data/syncthing_shared/codigos` → **Available for:** User(s)/Group(s)
   - **Folder name:** `Documentos/Obsidian` → **External storage:** Local → **Configuration:** `/mnt/data/syncthing_shared/obsidian` → **Available for:** User(s)/Group(s)
3. Test access in **Files** app — folders appear under configured mount points.

## Post-Install
- Add NPM proxy hosts:
  - `cloud.lab` → `http://192.168.1.200:11000` (SSL, HSTS, WebSocket for Collabora)
  - `syncthing.lab` → `http://192.168.1.200:8384` (SSL)
  - `aio.lab` → `http://192.168.1.200:8090` (internal/admin only)
- Configure **Collabora** for NPM: ensure `proxy_set_header Host $host;` and WebSocket headers.
- Set up **Nextcloud Cron** (AIO handles via `nextcloud-aio-cron` container).
- Configure **Trashbin retention** and **Versions retention** in Settings → Administration.
- Schedule backups: AIO backup + `/mnt/data/cloud` + `/mnt/data/syncthing_shared` to offsite.

## Notes
- Nextcloud AIO manages its own container stack (Redis, DB, Collabora, etc.) — do not manually edit those containers.
- `APACHE_PORT=11000` binds Nextcloud Apache to port 11000; AIO mastercontainer on 8090 is for management only.
- Syncthing uses port 22000 (TCP/UDP) for sync traffic — open on firewall if syncing over internet.
- External storage "Local" type requires `open_basedir` in PHP to include `/mnt/data/syncthing_shared` (AIO handles this).
- For OAuth2/OIDC: configure in Nextcloud Settings → **SSO & SAML** after NPM proxy is active.
- Updates: AIO handles via mastercontainer UI; Syncthing: `docker compose pull && docker compose up -d syncthing`.
- `NEXTCLOUD_MOUNT=/mnt/data/syncthing_shared` makes the folder available inside AIO containers for external storage.