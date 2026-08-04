



# Steps

## 1. Install Node Exporter on Proxmox node
1. Install the node exporter
```bash
apt install prometheus-node-exporter -y 
systemctl enable --now prometheus-node-exporter
```
2. Check if deployed on **proxmoxIP:9100**

## 2. Install cAdvisor + Node Exporter in the docker-VM
1. Create the compose file in **docker/monitoring**
	```yaml
	services:
  node-exporter:
    image: prom/node-exporter:latest
    container_name: node-exporter
    restart: unless-stopped
    network_mode: host
    pid: host
    volumes:
      - /:/host:ro,rslave
    command:
      - '--path.rootfs=/host'

  cadvisor:
    image: gcr.io/cadvisor/cadvisor:latest
    container_name: cadvisor
    restart: unless-stopped
    ports:
      - 8082:8080
    volumes:
      - /:/rootfs:ro
      - /var/run:/var/run:ro
      - /sys:/sys:ro
      - /var/lib/docker/:/var/lib/docker:ro
      - /dev/disk/:/dev/disk:ro
	``` 
2. Check if deployed in **docker-vmIP:9100/metrics** and **docker-vmIP:8082/metrics**

## 3. Setup the frontend in ZimaOS
1. Search for Grafana in the App Store
2. Use the custom yaml:
	```yaml
	services:
  grafana:
    command: null
    container_name: grafana
    deploy:
      resources:
        reservations:
          memory: 64MB
      placement: {}
    entrypoint: null
    image: grafana/grafana:13.0.1-security-01@sha256:135f4b96b7a54f904415dc51e71a1cd945b1f8400772b2feac2df5112b43f4ed
    labels:
      icon: https://cdn.jsdelivr.net/gh/IceWhaleTech/CasaOS-AppStore@gh-pages/apps/org.icewhale.grafana/assets/icon.svg
    network_mode: bridge
    ports:
      - target: 3000
        published: "3003"
        protocol: tcp
    restart: always
    volumes:
      - type: bind
        source: /DATA/AppData/empathetic_kaity/data
        target: /var/lib/grafana
  prometheus:
    command:
      - --config.file=/etc/prometheus/prometheus.yml
      - --storage.tsdb.path=/prometheus
    container_name: prometheus
    deploy:
      resources:
        reservations:
          memory: 64MB
      placement: {}
    entrypoint: null
    image: prom/prometheus:latest
    labels:
      icon: https://cdn.jsdelivr.net/gh/IceWhaleTech/CasaOS-AppStore@gh-pages/apps/org.icewhale.grafana/assets/icon.svg
    network_mode: bridge
    ports:
      - target: 9090
        published: "9090"
        protocol: tcp
    restart: always
    user: root
    volumes:
      - type: bind
        source: /DATA/AppData/empathetic_kaity/prometheus/data
        target: /prometheus
      - type: bind
        source: /DATA/AppData/empathetic_kaity/prometheus/config/prometheus.yml
        target: /etc/prometheus/prometheus.yml
 x-casaos:
  hostname: 192.168.1.202
  icon: https://cdn.jsdelivr.net/gh/IceWhaleTech/CasaOS-AppStore@gh-pages/apps/org.icewhale.grafana/assets/icon.svg
  id: org.icewhale.grafana
  index: /
  is_uncontrolled: false
  main: grafana
  port_map: "3003"
  repo_id: zimaos-appstore
  scheme: http
  store_app_id: empathetic_kaity
  title:
    custom: Grafana & Prometheus
    en_US: Grafana & Prometheus
  version: 13.0.1-security-01

	
	```
3. Create **prometheus.yml** in **prometheus/config**
	```yml
	global:
  scrape_interval: 15s

 scrape_configs:
  - job_name: 'proxmox-host'
    static_configs:
      - targets: ['192.168.1.50:9100']

  - job_name: 'docker-vm-host'
    static_configs:
      - targets: ['192.168.1.200:9100']

  - job_name: 'docker-vm-containers'
    static_configs:
      - targets: ['192.168.1.200:8082']

	``` 
4. Open Grafana Dashboard and add Prometheus in **Connections -> Data sources -> Add new Data Source**
5. Import the pre-build dashboards **1860** (Overall monitoring) and **14282** (container monitoring) in **Dashboard -> New -> Import**