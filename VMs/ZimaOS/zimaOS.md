# ZimaOS

## Overview
ZimaOS is a lightweight, user-friendly operating system for self-hosting, designed to run as a VM on Proxmox. It provides an App Store for one-click deployment of containerized services (Grafana, Prometheus, Nextcloud, etc.) and a clean web dashboard for service management. Used here as a frontend/service aggregator for monitoring and lightweight apps.

## Hardware
- **CPU:** 2 cores
- **RAM:** 4 GB
- **Storage:** 48 GB SSD
- **OS:** ZimaOS (based on openSUSE MicroOS)

## Network
- **IP:** 192.168.1.202 (static or DHCP reservation)
- **Web UI:** `http://192.168.1.202` (port 80/443 via ZimaOS gateway)
- **App Ports:** Managed per-app via ZimaOS App Store (e.g., Grafana on 3003, Prometheus on 9090)

## Prerequisites
- Proxmox VE with internet access
- ISO download capability (script fetches latest ZimaOS ISO)
- VT-x/AMD-V enabled in Proxmox VM settings (for nested virtualization if needed)

## Deployment
1. Run the installer script on the Proxmox node:
   ```bash
   bash -c "$(wget -qLO - https://raw.githubusercontent.com/R0GGER/proxmox-zimaos/refs/heads/main/zimaos_zimacube_installer-iso.sh)"
   ```
2. The script creates a VM, downloads the ZimaOS ISO, and attaches it.
3. Start the VM and complete the ZimaOS installation via console (follow on-screen prompts).
4. Shut down the VM, remove the ISO from the VM hardware settings (CD/DVD drive).
5. Boot the VM again. ZimaOS will start and display its IP on the console.
6. Access the ZimaOS dashboard at `http://192.168.1.202` and complete initial setup (admin user, timezone).

## Post-Install
- Configure static IP or DHCP reservation for 192.168.1.202 in router/Proxmox.
- Install apps via **App Store** (Grafana, Prometheus, FileBrowser, etc.).
- Set up reverse proxy via NPM for custom domains (e.g., `grafana.lab`, `zimaos.lab`).
- Enable automatic updates in ZimaOS settings.
- Configure backup of `/DATA/AppData` (contains all app data/configs).

## Notes
- ZimaOS uses a read-only root filesystem; persistent data lives in `/DATA/AppData/<app-id>/`.
- The installer script is maintained by R0GGER; check GitHub for updates.
- ZimaOS App Store apps run as Podman containers; Docker Compose is not natively supported (use custom YAML in app settings).
- For monitoring stack, see `Grafana + Prometheus.md` in this directory.
- Default credentials after first boot: set via web UI (no default password).