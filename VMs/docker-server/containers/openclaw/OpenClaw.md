# OpenClaw

## Overview
OpenClaw is an open-source personal AI assistant that runs locally on your machine. It connects to chat apps (Telegram, WhatsApp, Discord, etc.) and executes tasks via extensible skills — organizing email, managing calendars, checking flights, controlling smart home devices, automating GOG.com, and more. This deployment runs in **gateway mode** on docker-server (192.168.1.200), exposing a web UI + API on port 18789, with Telegram as the primary chat interface.

## Hardware
- **Host:** docker-server VM (192.168.1.200)
- **Resources:** Shared with other containers (minimal: ~100 MB RAM, negligible CPU when idle)

## Access
| Interface | Port | URL (local) | URL (remote via Tailscale) |
|-----------|------|-------------|----------------------------|
| Gateway Web UI | 18789 | `http://192.168.1.200:18789` | `https://<tailscale-device>.ts.net` |
| Gateway API | 18789 | `http://192.168.1.200:18789/api` | `https://<tailscale-device>.ts.net/api` |
| Telegram Bot | — | Via Telegram app | Via Telegram app (anywhere) |
| Companion App | — | macOS/Windows native | — |

## Structure
- **Config & Data:** `~/.openclaw/` (gateway token, allowed origins, database, memory, skills)
- **CLI Binary:** `openclaw` (in PATH via installer)
- **Gateway Process:** Managed by systemd (`openclaw.service`)
- **Docker Compose:** Not used (native Node.js process)
- **Skills:** Installed under `~/.openclaw/skills/` (e.g., `gog`)

## Prerequisites
- docker-server (Ubuntu) with Node.js 18+ and npm/pnpm (installed by installer)
- Telegram Bot Token (from @BotFather)
- Port 18789 available on docker-server
- Tailscale installed and authenticated (for remote HTTPS access)
- Systemd for gateway daemon management

## Deployment

### 1. Run Official Installer
```bash
curl -fsSL https://openclaw.ai/install.sh | bash
```
Installs Node.js (if missing), `openclaw` CLI globally, and creates `~/.openclaw/`.

### 2. Interactive Onboarding
```bash
openclaw onboard
```
Prompts for:
- **Persona** (name, personality, instructions)
- **Telegram Bot Token** (paste from @BotFather)
- **Gateway port** (default: 18789)
- **Database** (SQLite default, stored in `~/.openclaw/`)

Generates `~/.openclaw/config.json` with gateway token for first login.

### 3. Install gog Skill
```bash
openclaw skill install gog
```
Or via ClawHub: `https://clawhub.ai/steipete/skills/gog` (installs GOG.com automation skill).

### 4. Start Gateway (Web UI + API)
```bash
openclaw gateway
```
Runs in foreground on port 18789. For production, use systemd (see Configuration).

## Configuration

### Systemd Service (Daemon Mode)
The installer creates `openclaw.service`. Enable and start:
```bash
sudo systemctl enable --now openclaw
```
Check status: `sudo systemctl status openclaw`
Logs: `journalctl -u openclaw -f`

Gateway runs as your user, serving UI at `http://192.168.1.200:18789`.

### Tailscale Serve (Remote HTTPS Access)
Expose gateway securely via Tailscale (valid certs, no port forwarding):
```bash
# Expose gateway port via Tailscale
sudo tailscale serve --bg localhost:18789
sudo tailscale serve status
```
Access at `https://<your-device>.ts.net` (HTTPS with valid cert).

**Update allowed origins** for the Control Panel URL:
```bash
openclaw config set --batch-json '[{"path":"gateway.controlUi.allowedOrigins","value":["https://<tailscale-URL>"]}]'

# Restart gateway to apply
sudo systemctl restart openclaw
```

### Telegram Bot
Bot token stored in `~/.openclaw/config.json`. Test in Telegram:
- `/start` — shows gateway token (first run) or welcome
- `@claw <task>` — mention to trigger skills
- `/help` — lists available commands/skills

## Post-Install
- **Test gateway UI** at `http://192.168.1.200:18789` (or Tailscale URL) — login with gateway token from `~/.openclaw/config.json`.
- **Verify Telegram** — send `@claw hello` or `@claw check gog free games`.
- **Enable systemd** — `sudo systemctl enable openclaw` for auto-start on boot.
- **Add more skills** from https://clawhub.ai/ (GitHub, Gmail, Calendar, Obsidian, etc.).

## Notes
- **Data locality:** All config, memory, skills, and SQLite DB live in `~/.openclaw/` — nothing leaves your machine unless a skill explicitly calls external APIs.
- **Extensibility:** Skills are TypeScript/Node packages; install from ClawHub or build custom (`openclaw skill create`).
- **Memory:** Persistent across sessions; assistant remembers context, preferences, conversation history.
- **Updates:** `openclaw update` (stable) or `openclaw update --channel dev` (bleeding edge).
- **Gateway vs CLI:** `openclaw gateway` serves web UI + API; `openclaw chat` runs CLI-only chat (no web UI).
- **Port 18789:** Only expose via Tailscale; keep closed to LAN/WAN. Firewall: `ufw deny 18789` (allow Tailscale interface only).
- **gog skill:** Requires GOG account credentials (stored encrypted in skill config). First run prompts for login.
- **Multi-device:** One gateway can serve multiple Telegram users (each with own persona/memory) via gateway token.