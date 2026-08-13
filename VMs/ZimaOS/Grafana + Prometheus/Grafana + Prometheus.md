# Grafana + Prometheus Monitoring Stack

## Overview
Complete monitoring stack deployed on ZimaOS (VM ID 202) with Prometheus for metrics collection and Grafana for visualization. Monitors Proxmox host, Docker VM (host + containers), and provides pre-built dashboards for infrastructure and container observability.

## Hardware
- **Host:** ZimaOS VM (192.168.1.202)
- **Resources:** 2 CPU, 4 GB RAM, 48 GB SSD (shared with ZimaOS)

## Access
| Service | Port | URL (local) | URL (via NPM) |
|---------|------|-------------|---------------|
| Grafana | 3003 | `http://192.168.1.202:3003` | `grafana.lab` |
| Prometheus | 9090 | `http://192.168.1.202:9090` | `prometheus.lab` |
| Node Exporter (Proxmox) | 9100 | `http://192.168.1.50:9100` | — |
| Node Exporter (Docker VM) | 9100 | `http://192.168.1.200:9100` | — |
| cAdvisor (Docker VM) | 8082 | `http://192.168.1.200:8082` | — |

## Structure
- **Grafana Data:** `/DATA/AppData/empathetic_kaity/data` → `/var/lib/grafana`
- **Prometheus Data:** `/DATA/AppData/empathetic_kaity/prometheus/data` → `/prometheus`
- **Prometheus Config:** `/DATA/AppData/empathetic_kaity/prometheus/config/prometheus.yml` → `/etc/prometheus/prometheus.yml`
- **ZimaOS App Store:** Custom YAML deployment (see Deployment section)

## Prerequisites
- ZimaOS VM running (192.168.1.202)
- Proxmox node accessible at 192.168.1.50 (Node Exporter target)
- Docker Server accessible at 192.168.1.200 (Node Exporter + cAdvisor targets)
- ZimaOS App Store access for Grafana/Prometheus deployment

## Deployment

### 1. Install Node Exporter on Proxmox Node
Run on Proxmox host (192.168.1.50):
```bash
apt install prometheus-node-exporter -y
systemctl enable --now prometheus-node-exporter
```
Verify at `http://192.168.1.50:9100/metrics`.

### 2. Install cAdvisor + Node Exporter on Docker VM
On docker-server (192.168.1.200):
1. Create compose file at `/mnt/data/docker/monitoring/docker-compose.yml`:
   ```yaml
   services:
     node-exporter:
       image: prom/node-exporter:latest
       container_name: node-exporter
       restart: unless-stopped
       network_mode: host
       pid: host
       volumes:
         - /:/host:ro,rslave
       command:
         - '--path.rootfs=/host'

     cadvisor:
       image: gcr.io/cadvisor/cadvisor:latest
       container_name: cadvisor
       restart: unless-stopped
       ports:
         - 8082:8080
       volumes:
         - /:/rootfs:ro
         - /var/run:/var/run:ro
         - /sys:/sys:ro
         - /var/lib/docker/:/var/lib/docker:ro
         - /dev/disk/:/dev/disk:ro
   ```
2. Deploy:
   ```bash
   cd /mnt/data/docker/monitoring
   docker compose up -d
   ```
3. Verify:
   - Node Exporter: `http://192.168.1.200:9100/metrics`
   - cAdvisor: `http://192.168.1.200:8082/metrics`

### 3. Deploy Grafana + Prometheus on ZimaOS
1. Open ZimaOS App Store, search for **Grafana**.
2. Use **Custom YAML** deployment with the following configuration:
   ```yaml
   services:
     grafana:
       command: null
       container_name: grafana
       deploy:
         resources:
           reservations:
             memory: 64MB
         placement: {}
       entrypoint: null
       image: grafana/grafana:13.0.1-security-01@sha256:135f4b96b7a54f904415dc51e71a1cd945b1f8400772b2feac2df5112b43f4ed
       labels:
         icon: https://cdn.jsdelivr.net/gh/IceWhaleTech/CasaOS-AppStore@gh-pages/apps/org.icewhale.grafana/assets/icon.svg
       network_mode: bridge
       ports:
         - target: 3000
           published: "3003"
           protocol: tcp
       restart: always
       volumes:
         - type: bind
           source: /DATA/AppData/empathetic_kaity/data
           target: /var/lib/grafana
     prometheus:
       command:
         - --config.file=/etc/prometheus/prometheus.yml
         - --storage.tsdb.path=/prometheus
       container_name: prometheus
       deploy:
         resources:
           reservations:
             memory: 64MB
         placement: {}
       entrypoint: null
       image: prom/prometheus:latest
       labels:
         icon: https://cdn.jsdelivr.net/gh/IceWhaleTech/CasaOS-AppStore@gh-pages/apps/org.icewhale.grafana/assets/icon.svg
       network_mode: bridge
       ports:
         - target: 9090
           published: "9090"
           protocol: tcp
       restart: always
       user: root
       volumes:
         - type: bind
           source: /DATA/AppData/empathetic_kaity/prometheus/data
           target: /prometheus
         - type: bind
           source: /DATA/AppData/empathetic_kaity/prometheus/config/prometheus.yml
           target: /etc/prometheus/prometheus.yml
   x-casaos:
     hostname: 192.168.1.202
     icon: https://cdn.jsdelivr.net/gh/IceWhaleTech/CasaOS-AppStore@gh-pages/apps/org.icewhale.grafana/assets/icon.svg
     id: org.icewhale.grafana
     index: /
     is_uncontrolled: false
     main: grafana
     port_map: "3003"
     repo_id: zimaos-appstore
     scheme: http
     store_app_id: empathetic_kaity
     title:
       custom: Grafana & Prometheus
       en_US: Grafana & Prometheus
     version: 13.0.1-security-01
   ```

### 4. Configure Prometheus Scrape Targets
Create `/DATA/AppData/empathetic_kaity/prometheus/config/prometheus.yml`:
```yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'proxmox-host'
    static_configs:
      - targets: ['192.168.1.50:9100']

  - job_name: 'docker-vm-host'
    static_configs:
      - targets: ['192.168.1.200:9100']

  - job_name: 'docker-vm-containers'
    static_configs:
      - targets: ['192.168.1.200:8082']
```

### 5. Configure Grafana
1. Access Grafana at `http://192.168.1.202:3003` (default: `admin`/`admin`).
2. **Connections → Data sources → Add new Data Source → Prometheus**
   - URL: `http://prometheus:9090` (internal Docker DNS) or `http://192.168.1.202:9090`
   - Save & Test.
3. **Dashboard → New → Import** — add pre-built dashboards:
   - **1860** — Node Exporter Full (overall host monitoring)
   - **14282** — Docker Container Monitoring (cAdvisor-based)

## Configuration
- **Scrape Interval:** 15s (adjust in `prometheus.yml` for granularity vs storage).
- **Retention:** Default 15 days; configure `--storage.tsdb.retention.time` in Prometheus command if needed.
- **Alerting:** Add Alertmanager (optional) for notifications (email, Discord, Telegram).
- **Custom Dashboards:** Import additional dashboards for Jellyfin, Nextcloud, HA, etc.

## Post-Install
- Add NPM proxy hosts for `grafana.lab` (port 3003) and `prometheus.lab` (port 9090) with SSL.
- Configure Grafana **Organizations/Users** for team access.
- Set up **Provisioning** (dashboards/datasources as code) for GitOps.
- Monitor Prometheus storage growth; add retention policy if disk fills.
- Verify all targets **UP** in Prometheus → Status → Targets.

## Notes
- ZimaOS App Store deployment uses bind mounts under `/DATA/AppData/` — survives app updates.
- `x-casaos` section is ZimaOS-specific metadata; required for App Store integration.
- Prometheus runs as `user: root` for `/prometheus` write access (bind mount permission).
- cAdvisor provides container-level metrics (CPU, memory, network, disk I/O per container).
- Node Exporter on Proxmox host requires `prometheus-node-exporter` package (Debian/Ubuntu repo).
- For HAOS monitoring: add `192.168.1.201:9100` target if Node Exporter installed there.
- Dashboard 1860 requires `node-exporter` job; 14282 requires `cadvisor` job — both configured above.
- Updates: ZimaOS App Store handles Grafana/Prometheus; Node Exporter/cAdvisor via `docker compose pull && docker compose up -d`.