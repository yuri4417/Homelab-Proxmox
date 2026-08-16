# Home Assistant (HAOS)

## Overview
Home Assistant Operating System (HAOS) is a purpose-built, minimal OS for running Home Assistant. It runs as a VM on Proxmox and provides a complete home automation hub with integrations for thousands of devices, automations, dashboards, and voice control. Managed via the community-supported Proxmox installer script.

## Hardware
- **CPU:** 2 cores
- **RAM:** 2 GB
- **Storage:** 32 GB SSD
- **OS:** Home Assistant OS (HAOS)

## Network
- **IP:** 192.168.1.201 (static or DHCP reservation)
- **Web UI:** `http://192.168.1.201:8123`
- **mDNS:** `http://homeassistant.local:8123` (if enabled)

## Prerequisites
- Proxmox VE with internet access
- Community scripts repository accessible
- VT-x/AMD-V enabled in VM settings (required for HAOS)
- Sufficient storage for backups and add-ons (32 GB minimum recommended)

## Deployment
1. Run the community helper script on the Proxmox node:
   ```bash
   bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/vm/haos-vm.sh)"
   ```
   Or visit: https://community-scripts.org/scripts/haos-vm
2. Follow the interactive prompts (VM ID, name, storage, network, resources).
3. Start the VM and wait for HAOS to boot (first boot takes several minutes).
4. Access the web UI at `http://192.168.1.201:8123`.
5. Complete the onboarding (create admin user, set location, configure integrations).

## Configuration
- Restore from backup: **Settings → System → Backups → Upload backup** (tar file).
- Or start fresh: add integrations (Zigbee, MQTT, Shelly, etc.), create dashboards, set up automations.
- Install add-ons via **Settings → Add-ons → Add-on Store** (File Editor, Terminal, Mosquitto, Zigbee2MQTT, etc.).
- Configure network storage (NFS/SMB) for media/backups if needed.

## Post-Install
- Set up reverse proxy via NPM for `ha.lab` with SSL and WebSocket support.
- Configure trusted proxies in `configuration.yaml`:
  ```yaml
  http:
    use_x_forwarded_for: true
    trusted_proxies:
      - 192.168.1.0/24
  ```
- Enable automatic updates for HAOS and add-ons.
- Schedule regular snapshots (full + partial) to external storage (NFS/NAS).
- Integrate with Proxmox for VM status monitoring (via Prometheus/Grafana).

## Notes
- HAOS is immutable; OS updates are atomic (A/B partition scheme).
- The community script handles VM creation, disk setup, and cloud-init configuration.
- Default VM ID used by script: typically 201 (adjust if conflict).
- For Zigbee/Thread, pass through USB controller (e.g., SkyConnect, Sonoff) in Proxmox VM hardware settings.
- Backup strategy: HAOS snapshots + Proxmox VM backup (different layers).
- Exposing to internet: use Cloudflare Tunnel, Tailscale, or Nginx Proxy Manager with proper auth — never expose 8123 directly.
