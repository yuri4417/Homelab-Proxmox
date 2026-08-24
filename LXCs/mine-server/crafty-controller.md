# CraftyController (Minecraft Server)

## Overview
CraftyController is a web-based management panel for Minecraft servers. It provides a user-friendly interface to manage server instances, backups, scheduled tasks, and console access. This LXC runs a dedicated Minecraft server managed through CraftyController.

## Hardware
- **CPU:** 4 cores
- **RAM:** 8 GB
- **Storage:** 32 GB SSD
- **OS:** Debian/Ubuntu (via community script)

## Network
- **IP:** 192.168.1.100
- **Web UI Port:** 8443 (HTTPS)
- **Minecraft Port:** 25565 (TCP/UDP, configured in CraftyController)

## Prerequisites
- Proxmox VE host with internet access
- Community scripts repository accessible

## Deployment
1. Run the helper script on the Proxmox node shell:
   ```bash
   bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/crafty-controller.sh)"
   ```
   Or use the direct URL: https://community-scripts.org/scripts/crafty-controller
2. Follow the interactive prompts to configure the LXC (ID, hostname, network, resources).
3. Start the LXC and access the web UI at `https://192.168.1.100:8443`.
4. Complete the initial CraftyController setup (admin user, license agreement).
5. Create a new Minecraft server instance through the panel.

## Configuration
- Configure server properties (version, memory, JVM args) in CraftyController UI.
- Set up scheduled backups and restarts under **Schedules**.
- Open port 25565 on the firewall/router for external player access if needed.

## Post-Install
- Set up reverse proxy via NPM for custom domain (e.g., `minecraft.lab`) with SSL.
- Configure automatic updates for CraftyController and Minecraft server versions.
- Test backup/restore procedure.

## Notes
- The community script handles Docker installation and CraftyController deployment automatically.
- Backups are stored inside the LXC at `/var/opt/crafty/backups/` — consider mounting external storage for persistence.