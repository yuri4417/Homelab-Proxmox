# Structure
- **docker/npm/data:** External data folder (useful for backups)
- **docker/npm/certs:** Self-signed certificates
- **docker/npm/letsencrypt:**
- Web UI running on port **81**

**No additional setup was required after deploying the container.**


# Criar certificados autoassinados
## Comando genérico (site.lab)
```bash
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout site.key -out site.crt -subj "/CN=site.lab"
```


# Extra settings
## Proxmox Web UI
```npm
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header X-Forwarded-Proto $scheme;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
proxy_buffering off;
client_max_body_size 0;
```

