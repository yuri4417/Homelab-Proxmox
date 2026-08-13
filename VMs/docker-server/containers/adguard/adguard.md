# AdGuard Home

## Overview
AdGuard Home is a network-wide ad blocker and DNS server. It blocks ads, trackers, and malware at the DNS level for all devices on the network. Runs as a Docker container on the docker-server with persistent config and data directories.

## Access
- **Web UI:** `http://192.168.1.200:8083` (or `adguard.lab` via NPM)
- **DNS:** `192.168.1.200` (port 53 TCP/UDP)
- **Initial Setup:** `http://192.168.1.200:3000` (first-run wizard)

## Structure
- **Config:** `/mnt/data/docker/adguard/conf` → `/opt/adguardhome/conf`
- **Data/Work:** `/mnt/data/docker/adguard/work` → `/opt/adguardhome/work`
- **Docker Compose:** `/mnt/data/docker/adguard/docker-compose.yml`

## Prerequisites
- Docker Server running (192.168.1.200)
- Port 53 (TCP/UDP) free on host — disable systemd-resolved stub listener
- NPM configured for reverse proxy (optional, for custom domain)

## Deployment
1. Free port 53 on the Docker host (required for DNS):
   ```bash
   sudo mkdir -p /etc/systemd/resolved.conf.d
   echo -e "[Resolve]\nDNS=1.1.1.1\nDNSStubListener=no" | sudo tee /etc/systemd/resolved.conf.d/adguard.conf
   sudo systemctl restart systemd-resolved
   sudo rm /etc/resolv.conf
   sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
   ```
2. Create the compose directory and file:
   ```bash
   mkdir -p /mnt/data/docker/adguard
   cd /mnt/data/docker/adguard
   # Create docker-compose.yml
   nano docker-compose.yml
   ```
3. Deploy the container:
   ```bash
   docker compose up -d
   ```
4. Access the setup wizard at `http://192.168.1.200:3000` and configure:
   - Admin user/password
   - DNS interface: `0.0.0.0:53`
   - Web interface: `0.0.0.0:80` (mapped to host 8083)

## Configuration
- **Upstream DNS:** Set in UI → **DNS Settings → Upstream DNS** (e.g., Cloudflare `1.1.1.1`, Quad9 `9.9.9.9`, or custom).
- **Blocklists:** Enable default lists; add custom (e.g., OISD, HaGeZi) in **DNS Settings → Blocklists**.
- **Client Configuration:** Point router DHCP to `192.168.1.200` as DNS server, or configure per-device.
- **Rewrites:** Add local domain overrides in **DNS Settings → DNS Rewrites** (e.g., `home.lab → 192.168.1.200`).
- **HTTPS/DoH:** Enable in **Encryption Settings** for DNS-over-HTTPS (requires valid cert via NPM).

## Post-Install
- Add reverse proxy in NPM: `adguard.lab` → `http://192.168.1.200:8083` with SSL.
- Configure router DHCP to advertise `192.168.1.200` as primary DNS.
- Test with `dig @192.168.1.200 example.com` and `nslookup example.com 192.168.1.200`.
- Enable query logging in UI for debugging (disabled by default for privacy).

## Notes
- The systemd-resolved change is persistent across reboots.
- Port 3000 is only used for initial setup; can be removed from compose after configuration.
- AdGuard Home updates: `docker compose pull && docker compose up -d`.
- Backup: `conf` and `work` directories contain all settings and query logs.
- If DNS resolution breaks, check `systemctl status systemd-resolved` and `/etc/resolv.conf` symlink.
- For DoH/DoT, ensure NPM proxy passes `X-Forwarded-Proto` and WebSocket headers.