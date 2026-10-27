# Homelab-Proxmox

> A fully documented Proxmox homelab focused on virtualization, automation, and self-hosting.

This repository documents the architecture, configuration, and deployment of my personal Proxmox homelab, including LXC containers, virtual machines, and Docker services.

## Goals

- Document the entire infrastructure
- Simplify LXC deployment, maintenance, and recovery
- Learn more about virtualization, networking, Linux, and automation
- Explore and evaluate open-source alternatives to proprietary services, such as cloud storage, local AI inference, and more

## Hardware

| Component | Specification              |
| --------- | -------------------------- |
| **CPU**   | Intel Core i5-3570         |
| **RAM**   | 16 GB DDR3 (2×8 GB)        |
| **GPU**   | None (Intel HD Graphics)   |
| **OS**    | Proxmox VE 9.2.3           |
| **SSD**   | 240 GB                     |
| **HDD**   | 480 GB                     |

## Infrastructure

### LXC Containers

| ID  | Name       | Type           | IP Address         | Docs                                           |
| --- | ---------- | -------------- | ------------------ | ---------------------------------------------- |
| 100 | mine-server | Minecraft Server | 192.168.1.100:8443 | [Docs](LXCs/mine-server/crafty-controller.md)   |
| 101 | ai-backend  | AI Inference   | 192.168.1.101:8080 | [Docs](LXCs/ai-backend/ai-backend.md)          |

### Virtual Machines

| ID  | Name         | Type            | IP Address          | Docs                                                    |
| --- | ------------ | --------------- | ------------------- | ------------------------------------------------------- |
| 200 | docker-server | Docker Host     | 192.168.1.200       | [Docs](VMs/docker-server/docker-server.md)              |
| 201 | haos          | Home Assistant  | 192.168.1.201:8123  | [Docs](VMs/home-assistant/home-assistant.md)           |
| 202 | zimaos        | ZimaOS          | 192.168.1.202:80    | [Docs](VMs/zimaos/zimaos.md)                            |
| 203 | overleaf-ce   | LaTeX Editor    | 192.168.1.203:80    | [Docs](VMs/overleaf-ce/overleaf-ce.md)                  |

## Docker Containers

Running on **docker-server** (VM 200):

| Container     | Purpose       | Docs                                                          |
| ------------- | ------------- | ------------------------------------------------------------- |
| AdGuard       | DNS Ad-blocker | [Docs](VMs/docker-server/containers/adguard/adguard.md)       |
| Dashboard     | App dashboard | [Docs](VMs/docker-server/containers/dashylife/dashylife.md)   |
| File Browser  | File manager  | [Docs](VMs/docker-server/containers/filebrowser/filebrowser.md) |
| Jellyfin      | Media server  | [Docs](VMs/docker-server/containers/jellyfin/jellyfin.md)     |
| NPM           | Reverse proxy | [Docs](VMs/docker-server/containers/npm/npm.md)               |
| Nextcloud     | Cloud storage | [Docs](VMs/docker-server/containers/nextcloud/nextcloud.md)   |
| OpenClaw      | AI assistant  | [Docs](VMs/docker-server/containers/openclaw/openclaw.md)     |

## Monitoring

Running under **ZimaOS** (VM 202):

| Service          | Purpose      | Docs                                                                  |
| ---------------- | ------------ | --------------------------------------------------------------------- |
| Grafana          | Visualization | [Docs](VMs/zimaos/grafana-prometheus/grafana-prometheus.md) |
| Prometheus       | Metrics      | [Docs](VMs/zimaos/grafana-prometheus/grafana-prometheus.md) |

## Repository Structure

```
Homelab-Proxmox/
├── LXCs/
│   ├── ai-backend/
│   │   └── ai-backend.md
│   └── mine-server/
│       └── crafty-controller.md
├── VMs/
│   ├── home-assistant/
│   │   └── home-assistant.md
│   ├── overleaf-ce/
│   │   ├── overleaf-ce.md
│   │   └── restart-tunnel.sh
│   ├── zimaos/
│   │   ├── grafana-prometheus/
│   │   │   └── grafana-prometheus.md
│   │   └── zimaos.md
│   └── docker-server/
│       ├── docker-server.md
│       └── containers/
│           ├── adguard/
│           ├── dashylife/
│           ├── filebrowser/
│           ├── jellyfin/
│           ├── npm/
│           ├── nextcloud/
│           └── openclaw/
└── README.md
```

## License

This project is licensed under the [LICENSE](LICENSE) file.
