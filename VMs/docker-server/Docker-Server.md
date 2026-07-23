# Hardware
- **CPU:** 2 cores
- **RAM:** 8GB
- **OS**: Ubuntu Server
- **Storage:**
	- 32GB SSD (OS)
	- 480GB HDD (Container usage)
# Quick notes
- HDD added after the VM creation, before first start
- Ubuntu server installed with defaults
- OpenSSH installed to facilitate terminal usage


# Container List

| Name        | Type          | Port       | Docs            |
| ----------- | ------------- | ---------- | --------------- |
| AdguardHome | Network       | 8083       | [[adguard]]     |
| FileBrowser | File Explorer | 8080       | [[FileBrowser]] |
| Jellyfin    | Media         | 8096       | [[Jellyfin]]    |
| R-stack     | Media         | Multiple   | [[R-stack]]     |
| Nextcloud   | Cloud Storage | 8091/11000 | [[NextCloud]]   |
| NPM         | Network       | 81         | [[NPM]]         |




# Post-install
1. HDD initialization
	```bash
	sudo parted -s /dev/sdb mklabel gpt mkpart primary ext4 0% 100%
	
	sudo mkfs.ext4 /dev/sdb1
	
	sudo mkdir -p /mnt/data
	
	echo "UUID=$(sudo blkid -s UUID -o value /dev/sdb1) /mnt/data ext4 defaults 0 2" | sudo tee -a /etc/fstab
	
	sudo systemctl daemon-reload
	sudo mount -a
	sudo chown -R $USER:$USER /mnt/data
	```
2. Docker installation
	```bash	
	sudo apt-get install ca-certificates curl -y
	
	sudo install -m 0755 -d /etc/apt/keyrings
	sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
	sudo chmod a+r /etc/apt/keyrings/docker.asc
	
	echo \
	  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
	  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
	  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
	  
	sudo apt-get update
	sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
	
	sudo usermod -aG docker $USER
	```