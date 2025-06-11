
# Raspberry Pi - Servidor Personal: Guía General

Este repositorio documenta la configuración y gestión de un servidor basado en Raspberry Pi 5. Aquí encontrarás cómo desplegar proyectos, automatizar servicios, usar Cloudflare Tunnel, configurar Docker, y seguir buenas prácticas de administración.

---

## 🔧 Infraestructura
- Raspberry Pi 5 con 8GB RAM
- OS: Debian 12 Bookworm (Raspberry Pi OS basado en Debian)

## 📁 Organización de proyectos
```
~/projects/front/angular/nombre-proyecto
```
> Se recomienda separar por tipo: `front`, `back`, `mono`...

## 🔐 Seguridad y Red
- SSH con claves y hostname personalizado
- IP estática: `192.168.1.41` por ejemplo ( recomendado vía Ethernet)
- UFW activado (permitiendo solo puerto 22)

---

## 🐳 Docker: Ejemplo con Proyecto Angular
- Dockerfile multietapa: build Angular + servir con Nginx
- Contenedor llamado: `nombre-contenedor`
- Expone el puerto: `8080 -> 80`

### 🔁 Reinicio automático del contenedor
```bash
sudo docker update --restart unless-stopped nombre-contenedor
```
Verificación:
```bash
docker inspect -f '{{ .HostConfig.RestartPolicy.Name }}' nombre-contenedor
```

---

## ☁️ Cloudflare Tunnel
- Túnel creado: `nombre-tunel`
- Dominio personalizado: `proyecto-ejemplo.midominio.xyz` # ej. my-project.developer.xyz

### 📝 Configuración
Archivo: `~/.cloudflared/config.yml`
```yaml
tunnel: dev-tunnel
credentials-file: /home/usuario/.cloudflared/<UUID>.json

ingress:
  - hostname: my-project.developer.xyz
    service: http://localhost:8080
  - service: http_status:404
```

### 🌐 Vinculación DNS
```bash
cloudflared tunnel route dns nombre-tunel my-project.developer.xyz
```

### ▶️ Ejecutar túnel manualmente
```bash
cloudflared tunnel run nombre-tunel
```

---

## 🛠️ Autoejecución del túnel (systemd)
Archivo: `/etc/systemd/system/cloudflared-dev.service`
```ini
[Unit]
Description=Cloudflare Tunnel - dev-tunnel
After=network.target

[Service]
TimeoutStartSec=0
Type=simple
User=username
ExecStart=/usr/bin/cloudflared tunnel run dev-tunnel
Restart=always
RestartSec=5s

[Install]
WantedBy=multi-user.target
```

### 📌 Comandos útiles
```bash
sudo systemctl daemon-reexec     # Reinicia systemd
sudo systemctl daemon-reload     # Recarga servicios
sudo systemctl enable cloudflared-dev  # Habilita en arranque
sudo systemctl start cloudflared-dev   # Arranca el servicio
systemctl status cloudflared-dev       # Ver estado
```

### 🛡️ Recuperación automática
- Reinicio automático si falla.
- Configuración avanzada opcional:
```ini
StartLimitIntervalSec=30
StartLimitBurst=3
```

---

## 🔍 Comprobaciones útiles
- Verificar túnel:
```bash
cloudflared tunnel info nombre-tunel
```
- Ver túneles activos:
```bash
cloudflared tunnel list
```
- Ver contenedores con restart activo:
```bash
docker inspect --format '{{ .Name }} => {{ .HostConfig.RestartPolicy.Name }}' $(docker ps -aq)
```

---

## 📌 Próximos pasos posibles
- Despliegue de API (por ejemplo, Laravel + MySQL)
- Almacenamiento en red (Drive personal)
- Scripts de despliegue automatizado (CI/CD)
- Monitoreo de servicios y contenedores

> Este repositorio está pensado para evolucionar y adaptarse a más proyectos y necesidades conforme se desplieguen nuevos servicios en la Raspberry Pi.
