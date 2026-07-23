# Homelab-Proxmox

A fully documented Proxmox homelab focused on virtualization, automation, and self-hosting.
This repository documents the architecture, configuration, and deployment of my personal Proxmox homelab.
## Goals

- Document the entire infrastructure
- Simplify LXC deployment, maintenance, and recovery
- Learn more about virtualization, networking, Linux, and automation
- Explore and evaluate open-source alternatives to proprietary services, such as cloud storage, local AI inference, and more

## Hardware
- **CPU:** Intel Core i5-3570
- **RAM:** 16 GB DDR3 (2×8 GB)
- **GPU:** None (integrated Intel HD Graphics)
- **OS:** Proxmox VE 9.2.3
- **Storage:**
  - 240 GB SSD
  - 480 GB HDD
# Actual configuration
| ID  | Name          | Type              | IP                 |
| --- | ------------- | ----------------- | ------------------ |
| 100 | mine-server   | Minecraft Server  | 192.168.1.100:8443 |
| 200 | docker-server | Docker containers | 192.168.1.200      |
| 201 | haos          | Home Assistant VM | 192.168.1.201:8123 |