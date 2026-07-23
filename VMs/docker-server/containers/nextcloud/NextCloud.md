# Structure
- **/mnt/data/cloud:** Data folder
- **/mnt/data/syncthing_shared:** Files synchronized via Syncthing. Added to Nextcloud as external storage.
 
- **Acess:** 192.168.1.200:11000 / cloud.lab
# Steps
1. Deploy the container
2. Log into **vmIP:8090** and deploy the Nextcloud Service
	- NextCloud office by Collabora
	-  Whiteboard and Imaginary installed
3. Enter syncthing: **vmIP:8384** 
	- Add the sync devices
	- Share the folders on **/mnt/data/syncthing_shared**
4. Re-enable "External storage" app and add the syncthing folders: 
	- **/mnt/data/syncthing_shared/codigos** mapped to **/Documentos/Codigos**
	- **/mnt/data/syncthing_shared/obsidian** mapped to **/Documentos/Obsidian**