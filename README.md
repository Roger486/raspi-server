
# Raspberry Pi – Personal Server: General Guide

This repository documents the configuration and management of a server based on a Raspberry Pi 5. Here you will find how to deploy projects, automate services, use Cloudflare Tunnel, set up Docker, and follow best practices for administration.

---

## 🔧 Infrastructure
- Raspberry Pi 5 8GB RAM
- OS: Debian 12 Bookworm (Raspberry Pi OS based on Debian)

## 📁 Project Organization
```
~/projects/front/angular/project-name
```
> It's recommended to separate by type: `front`, `back`, `mono`...

## 🔐 Security & Network
- SSH with key authentication and custom hostname
- Static IP: `192.168.1.41` por ejemplo (recommended via Ethernet)
- UFW enabled (allowing only port 22)

---

## 🐳 Docker: Example with Angular Project
- Multi-stage Dockerfile: build Angular + serve with Nginx
- Container name: `container-name`
- Exposes port: `8080 -> 80`

### 🔁 Automatic container restart
```bash
sudo docker update --restart unless-stopped nombre-contenedor
```
Check status:
```bash
docker inspect -f '{{ .HostConfig.RestartPolicy.Name }}' nombre-contenedor
```

---

## ☁️ Cloudflare Tunnel
- Tunnel created: `tunnel-name`
- Custom domain: `example-project.mydomain.xyz` # ej. my-project.developer.xyz

### 📝 Configuration
File: `~/.cloudflared/config.yml`
```yaml
tunnel: dev-tunnel
credentials-file: /home/user/.cloudflared/<UUID>.json

ingress:
  - hostname: my-project.developer.xyz
    service: http://localhost:8080
  - service: http_status:404
```

### 🌐 DNS Linking
```bash
cloudflared tunnel route dns nombre-tunel my-project.developer.xyz
```

### ▶️ Run tunnel manually
```bash
cloudflared tunnel run tunnel-name
```

---

## 🛠️ Tunnel Auto-Start (systemd)
Archivo: `/etc/systemd/system/cloudflared-dev.service`
```ini
[Unit]
Description=Cloudflare Tunnel - tunnel-name
After=network.target

[Service]
TimeoutStartSec=0
Type=simple
User=username
ExecStart=/usr/bin/cloudflared tunnel run tunnel-name
Restart=always
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

### 📌 Useful Commands
```bash
sudo systemctl daemon-reexec     # Restart systemd
sudo systemctl daemon-reload     # Reload services
sudo systemctl enable cloudflared-dev  # Enable on boot
sudo systemctl start cloudflared-dev   # Start service
systemctl status cloudflared-dev       # Check status
```

### 🛡️ Automatic Recovery
- Auto-restart if the tunnel fails.
- Optional advanced configuration:
```ini
StartLimitIntervalSec=30
StartLimitBurst=3
```

---

## 🔍 Useful Checks
- Verify tunnel:
```bash
cloudflared tunnel info tunnel-name
```
- List active tunnels:
```bash
cloudflared tunnel list
```
- List containers with restart policy:
```bash
docker inspect --format '{{ .Name }} => {{ .HostConfig.RestartPolicy.Name }}' $(docker ps -aq)
```

---

## 👤 Author

**Roger Navarro**  
Junior Web Developer (DAW – Web Application Development)  
🔗 [https://github.com/Roger486](https://github.com/Roger486)

---

## 📌 Possible Next Steps
- API deployment (e.g., Laravel + MySQL)
- Network storage (Personal Drive)
- Automated deployment scripts (CI/CD)
- Monitoring for services and containers

> This repository is designed to evolve and adapt to new projects and needs as more services are deployed on the Raspberry Pi.
