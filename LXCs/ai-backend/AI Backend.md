# AI Backend (LocalAI)

## Overview
LocalAI is an OpenAI-compatible API for running LLMs locally on CPU. This LXC provides a self-hosted inference endpoint for chat, embeddings, and image generation without requiring GPU acceleration. It serves as the AI backbone for local applications and integrations.

## Hardware
- **CPU:** 4 cores
- **RAM:** 8 GB
- **Storage:** 16 GB SSD
- **OS:** Ubuntu/Debian (Docker LXC via community script)

## Network
- **IP:** Assigned via DHCP (Proxmox default)
- **API Port:** 8080 (HTTP)
- **Access:** `http://<LXC-IP>:8080`

## Prerequisites
- Proxmox VE host with internet access
- Community scripts repository accessible
- Sufficient RAM for model loading (8 GB minimum for small models)

## Deployment
1. Create the Docker LXC using the community helper script:
   ```bash
   var_cpu="4" var_ram="8192" var_disk="16" bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/docker.sh)"
   ```
2. Enter the LXC shell and create the model directory:
   ```bash
   mkdir -p ~/localai/models
   cd ~/localai
   ```
3. Create `docker-compose.yml` with the LocalAI service:
   ```yaml
   services:
     localai:
       image: localai/localai:latest-cpu
       container_name: localai
       ports:
         - "8080:8080"
       volumes:
         - "./models:/models:z"
       environment:
         - MODELS_PATH=/models
       restart: unless-stopped
   ```
4. Deploy the container:
   ```bash
   docker compose up -d
   ```
5. Verify the API is accessible at `http://<LXC-IP>:8080`.

## Configuration
- Download models into `~/localai/models/` (e.g., `ggml-gpt4all-j.bin`, `llama-2-7b-chat.gguf`).
- Models are auto-detected at startup; restart container after adding new models.
- Adjust `MODELS_PATH` if using a different directory structure.
- For GPU support, use `localai/localai:latest` image and add NVIDIA runtime (requires GPU passthrough).

## Post-Install
- Test the OpenAI-compatible endpoints: `/v1/chat/completions`, `/v1/embeddings`, `/v1/models`.
- Configure reverse proxy via NPM for custom domain (e.g., `ai.lab`) with SSL.
- Set up model aliases in `models.yaml` for friendly names.
- Monitor resource usage; consider model quantization (Q4_K_M) for lower RAM footprint.

## Notes
- CPU-only inference is slower than GPU; expect 2–10 tokens/sec depending on model size.
- The `:z` volume flag ensures proper SELinux labeling (harmless on non-SELinux systems).
- Community script installs Docker, Docker Compose, and basic hardening automatically.
- API is unauthenticated by default; restrict via firewall or add auth proxy if exposed.