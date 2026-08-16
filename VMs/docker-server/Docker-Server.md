# Docker Server

## Overview
Primary Docker host for self-hosted services. Runs Ubuntu Server with a secondary HDD mounted at `/mnt/data` for persistent container storage. All services deployed via Docker Compose and managed through Nginx Proxy Manager for reverse proxy and SSL termination.

## Hardware
- **CPU:** 2 cores
- **RAM:** 2 GB
- **OS:** Ubuntu Server (LTS)
- **Storage:**
  - 32 GB SSD (OS disk)
  - 480 GB HDD (container data, mounted at `/mnt/data`)

## Network
- **IP:** 192.168.1.200 (static)
- **SSH:** Port 22
- **Service Ports:** Managed via NPM (port 81 for UI, 80/443 for proxy)

## Prerequisites
- Proxmox VE with internet access
- Secondary HDD passed through to VM (added before first boot)
- Ubuntu Server ISO for installation

## Container List

| Name        | Type          | Port(s)                      | Documentation    |
| ----------- | ------------- | ---------------------------- | ---------------- |
| AdGuardHome | Network/DNS   | 8083 (UI), 53                | [`adguard.md`](containers/adguard/adguard.md)     |
| FileBrowser | File Explorer | 8080                         | [`FileBrowser.md`](containers/filebrowser/FileBrowser.md) |
| Jellyfin    | Media         | 8096                         | [`Jellyfin.md`](containers/jellyfin/Jellyfin.md)    |
| Nextcloud   | Cloud Storage | 8091, 11000                  | [`NextCloud.md`](containers/nextcloud/NextCloud.md)   |
| NPM         | Reverse Proxy | 81 (UI), 80/443              | [`NPM.md`](containers/NPM/NPM.md)         |
| OpenClaw    | AI Agent      | 12789 (UI),                  | [`OpenClaw.md`](containers/openclaw/OpenClaw.md)         |
## Deployment

### 1. HDD Initialization
Run after first boot (HDD must be attached in Proxmox VM settings):
```bash
sudo parted -s /dev/sdb mklabel gpt mkpart primary ext4 0% 100%

sudo mkfs.ext4 /dev/sdb1

sudo mkdir -p /mnt/data

echo "UUID=$(sudo blkid -s UUID -o value /dev/sdb1) /mnt/data ext4 defaults 0 2" | sudo tee -a /etc/fstab

sudo systemctl daemon-reload
sudo mount -a
sudo chown -R $USER:$USER /mnt/data
```

### 2. Docker Installation
```bash
sudo apt-get install ca-certificates curl -y

sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

sudo usermod -aG docker $USER
```
Log out and back in for group changes to take effect.

## Post-Install
- Create `/mnt/data/docker` for compose projects: `mkdir -p /mnt/data/docker`
- Deploy each service using its respective `docker-compose.yml` in `/mnt/data/docker/<service>/`
- Configure NPM first (port 81), then add proxy hosts for each service
- Set up automated backups of `/mnt/data` (rsync, borg, or Proxmox VM backup)

## Notes
- HDD must be added in Proxmox **before** first VM boot for `/dev/sdb` detection.
- Ubuntu installed with defaults; OpenSSH enabled during install for remote access.
- All container data persists on HDD (`/mnt/data`) — survives OS reinstall.
- Resource constraints: 2 GB RAM limits concurrent heavy containers (Jellyfin transcoding, Nextcloud). Monitor with `htop`/`docker stats`.
- Consider upgrading RAM to 4–8 GB for better headroom.
- Firewall: only expose 80/443 (NPM) and 22 (SSH) externally; service ports (8080, 8096, etc.) remain internal.
