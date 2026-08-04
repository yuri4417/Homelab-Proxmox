Used for quick deploy/frontend services, bringing lightweight services together in one place
# Hardware
- 2 CPU Cores
- 4GB RAM
- 48GB SSD

# Steps

1. Run the custom script in Proxmox node
	```bash
	bash -c "$(wget -qLO - https://raw.githubusercontent.com/R0GGER/proxmox-zimaos/refs/heads/main/zimaos_zimacube_installer-iso.sh)"
	```
2. Boot the VM and install ZimaOS
3. Stop the VM, remove the ISO file and boot again
4. Done