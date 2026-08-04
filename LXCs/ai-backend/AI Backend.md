
# Hardware
- 4 CPU Cores
- 8GB RAM
- 16GB SSD


# Steps
1. Use the helper script for create a docker LXC
   ```bash
   var_cpu="4" var_ram="8192" var_disk="16" bash -c "$(curl -fsSL https://raw.githubusercontent.com/community-scripts/ProxmoxVE/main/ct/docker.sh)"
   ```
2. Create the directory **~/localai/models** and paste the compose in **localai**
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
   