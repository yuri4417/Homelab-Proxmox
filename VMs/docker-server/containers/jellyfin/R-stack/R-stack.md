# Structure
- **/docker/r-stack/config/** Folder with configs for each service 

- qbit port: 8090
- S port: 8989
- R port: 7878
- P port: 8191
- B port: 6767

# Steps
1. Deploy containers
2. **qBit config**
	- Set a password: **Tools -> Options -> WebUI**
	- Update save paths: **Tools -> Options -> Downloads -> Saving Management**
3. **P config**
	- Add indexers
	- Link S and R with API Keys (Settings -> Apps) with http://app:port server
	- Test, save and done
4. **S and R config**
	- Connect Download Client: **Settings -> Download Clients** and add qbit
	- Optimize media management: **Settings -> Media Management**, show advanced and mark "Use Hardlinks instead of Copy"
	- Yet on Media management, set the folders where the media will be saved
	- Check indexers on **Settings -> Indexers**
5. **B config**
	- Connect to S and R: **Settings ->** and add the host, ports, and API Key for both
	- Add providers: **Settings -> Providers**
	- Add language profile: **Settings -> Languages**