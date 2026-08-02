
# Steps
1. Use the official script:
	```bash
	curl -fsSL https://openclaw.ai/install.sh | bash
	```
2. Execute the setup configuration
3. Catch the gateway token in openclaw.json and log in
4. Use tailscale serve if necessary
	```shell
	sudo tailscale serve --bg localhost:18789
	sudo tailscale serve status
	openclaw config set --batch-json '[{"path":"gateway.controlUi.allowedOrigins","value":["https://URL"]}]'
	
	docker compose -f /home/yreis188/docker/openclaw/docker-compose.yml restart openclaw-gateway
	```
5. Restart openclaw gateway
	```bash
	sudo systemctl restart openclaw
	```


