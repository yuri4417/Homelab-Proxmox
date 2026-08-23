# DashyLife

## Overview

DashyLife is a personal life management application that unifies tasks and game tracking into a single workspace. Built entirely with vibe coding using OpenCode, it serves as both a practical utility tool and a technical experimentation ground for AI-assisted development. Deployed as a Docker stack on docker-server, accessible via port 8081.

**Repository:** [yuri4417/dashylife](https://github.com/yuri4417/dashylife)

## Access

- **Web UI:** `http://192.168.1.200:8081`
- **API:** `http://192.168.1.200:3000` (internal, behind Nginx)

## Structure

- **Data:** `/mnt/data/docker/dashylife/data` → `/app/api/data` (SQLite database, user data)
- **Docker Compose:** `/mnt/data/docker/dashylife/docker-compose.yml`

## Prerequisites

- Docker Server with Docker and docker-compose available
- Port 8081 free on docker-server (192.168.1.200)
- Node.js 18+ and pnpm 9+ (for local development, optional)

## Deployment

1. Create the compose directory:
   
   ```bash
   mkdir -p ~/docker/dashylife/data
   cd ~/docker/dashylife
   ```

2. Clone the repository:
   
   ```bash
   git clone https://github.com/yuri4417/dashylife .
   ```

3. Deploy:
   
   ```bash
   docker compose up -d --build
   ```

4. Access `http://192.168.1.200:8081`.

## Configuration

- **Module Management:** Dynamically toggle individual services (API, Web, Mobile) on/off.
- **API Server:** Runs on port 3000 internally (Nginx proxies to 8081).
- **Database:** SQLite, stored in `./data` directory — back up regularly.
