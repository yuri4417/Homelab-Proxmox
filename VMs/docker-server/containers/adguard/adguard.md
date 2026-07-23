# Structure
- **docker/adguard/work and docker/adguard/conf:** External config folder
- Running on port 8083

# Steps
1. Allow port 53 to be used
	```bash
	sudo mkdir -p /etc/systemd/resolved.conf.d
	echo -e "[Resolve]\nDNS=1.1.1.1\nDNSStubListener=no" | sudo tee /etc/systemd/resolved.conf.d/adguard.conf
	sudo systemctl restart systemd-resolved
	sudo rm /etc/resolv.conf
	sudo ln -s /run/systemd/resolve/resolv.conf /etc/resolv.conf
	```
2. Deploy the container
3. Done