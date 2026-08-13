# Nginx Proxy Manager (NPM)

## Overview
Nginx Proxy Manager provides a web-based UI for managing Nginx reverse proxy hosts, SSL certificates (Let's Encrypt), access lists, and custom configurations. It terminates TLS at the edge and forwards traffic to internal services on the docker-server and other VMs/LXCs.

## Access
- **Web UI:** `http://192.168.1.200:81` (or `npm.lab` via self-proxy)
- **HTTP:** Port 80 (redirects to HTTPS)
- **HTTPS:** Port 443 (SSL termination)

## Structure
- **Data:** `/mnt/data/docker/npm/data` → `/data` (SQLite DB, proxy configs, access lists)
- **Let's Encrypt:** `/mnt/data/docker/npm/letsencrypt` → `/etc/letsencrypt` (certificates, keys, account)
- **Docker Compose:** `/mnt/data/docker/npm/docker-compose.yml`

## Prerequisites
- Docker Server with ports 80, 443, 81 available
- Public domain (for Let's Encrypt) or local DNS (for self-signed certs)
- Port 80/443 forwarded on router to docker-server (192.168.1.200) for Let's Encrypt validation

## Deployment
1. Create the compose directory:
   ```bash
   mkdir -p /mnt/data/docker/npm
   cd /mnt/data/docker/npm
   ```
2. Create `docker-compose.yml`:
   ```yaml
   services:
     npm:
       image: jc21/nginx-proxy-manager:latest
       container_name: npm
       restart: unless-stopped
       ports:
         - "80:80"
         - "443:443"
         - "81:81"
       volumes:
         - ./data:/data
         - ./letsencrypt:/etc/letsencrypt
   ```
3. Deploy:
   ```bash
   docker compose up -d
   ```
4. Access `http://192.168.1.200:81` and complete setup:
   - Default login: `admin@example.com` / `changeme`
   - Change email and password immediately.

## Configuration

### Proxy Hosts (Core)
For each service, create a **Proxy Host** in NPM UI:
- **Domain Names:** `service.lab` (or public domain)
- **Scheme:** `http`
- **Forward Hostname/IP:** `192.168.1.200` (or container name if on same network)
- **Forward Port:** Service port (e.g., 8096 for Jellyfin)
- **Block Common Exploits:** Enable
- **WebSocket Support:** Enable (for Jellyfin, Nextcloud Collabora, HA, etc.)
- **SSL Tab:** Request Let's Encrypt certificate (requires public domain + port 80 access)
  - Or use **Custom SSL Certificate** for local domains (see below).

### Custom SSL Certificates (Local Domains)
For `.lab` or internal domains without public DNS:
1. Generate self-signed certificate:
   ```bash
   openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout site.key -out site.crt -subj "/CN=site.lab"
   ```
2. In NPM UI: **SSL Certificates → Add SSL Certificate → Custom**
   - Paste `site.crt` content in **Certificate**
   - Paste `site.key` content in **Key**
   - Save, then select in Proxy Host **SSL** tab.

### Proxmox Web UI Proxy (Advanced)
Add custom configuration in Proxy Host **Advanced** tab for Proxmox (WebSocket + large uploads):
```nginx
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
proxy_buffering off;
client_max_body_size 0;
```

### Access Lists & Security
- **Access Lists:** Restrict admin endpoints (e.g., `/admin`, `/api`) to LAN IPs or Tailscale.
- **Rate Limiting:** Add custom config for login endpoints.
- **Security Headers:** Enable HSTS, CSP via custom config if needed.

## Post-Install
- Create proxy hosts for all services (Jellyfin, Nextcloud, *arr apps, Grafana, HA, etc.).
- Request Let's Encrypt certs for public domains; use self-signed for `.lab`.
- Verify WebSocket support for: Jellyfin (SyncPlay), Nextcloud (Collabora), Home Assistant, Grafana.
- Backup `/mnt/data/docker/npm/data` (SQLite) and `/mnt/data/docker/npm/letsencrypt` regularly.
- Monitor NPM logs: `docker logs -f npm` for connection issues.

## Notes
- NPM runs as root inside container; host volumes mapped with user 1000:1000 (PUID/PGID not configurable in jc21 image).
- Let's Encrypt requires port 80 accessible for HTTP-01 challenge; use DNS-01 challenge for wildcard/internal domains.
- For local `.lab` domains: configure local DNS (Pi-hole, AdGuard, or `/etc/hosts`) to resolve to 192.168.1.200.
- Proxmox UI proxy requires WebSocket headers for noVNC console and SPICE.
- `client_max_body_size 0` disables upload limit (required for Proxmox ISO uploads, Nextcloud large files).
- Updates: `docker compose pull && docker compose up -d` (data persists in volumes).