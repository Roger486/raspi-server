
# 🔐 Secure SSH Access to Raspberry Pi via Cloudflare Tunnel + Access

This guide documents how to securely access the Raspberry Pi via SSH using [Cloudflare Tunnel](https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/) and [Cloudflare Access](https://developers.cloudflare.com/cloudflare-one/policies/access/). This allows remote administration **without exposing port 22 to the internet**, and with **Zero Trust authentication**.

---

## ☁️ Cloudflare Tunnel Setup

- Tunnel name: `tunnel-name`
- Custom domain: `ssh.domain-example.com`
- Tunnel config file:

```yaml
tunnel: tunnel-name
credentials-file: /home/pi/.cloudflared/<UUID>.json

ingress:
  - hostname: ssh.domain-example.com
    service: ssh://localhost:22
  - service: http_status:404
```

- DNS configuration:
```bash
cloudflared tunnel route dns tunnel-name ssh.domain-example.com
```

> This creates a proxied CNAME pointing to the tunnel endpoint.

---

## 🚀 Auto-start Tunnel via systemd

File: `/etc/systemd/system/cloudflared-dev.service`

*(See general README for full cloudflared-dev.service systemd config)*

---

## 🖥️ Windows Client Setup (for remote SSH)

1. Install `cloudflared`:
```powershell
winget install --id Cloudflare.cloudflared
```

2. Add this to your `C:\Users\<user>\.ssh\config`:

```ssh
Host raspi-remoto
  HostName ssh.domain-example.com
  User userName
  ProxyCommand cloudflared access ssh --hostname %h
```

3. Connect via:

```powershell
ssh raspi-remoto
```

---

## 🔒 Cloudflare Access Policy

1. Go to Cloudflare Zero Trust → Access → Applications
2. Create new Self-Hosted application:
   - Name: `SSH Raspberry Pi`
   - Subdomain: `ssh.domain-example.com`
3. Add an access policy and apply it to the application:
   - `Action`: Allow
   - `Include`: Emails → `your.email@example.com`

> You must authenticate via browser before SSH is allowed. Cloudflare acts as a secure gateway.

> Make sure the email matches the identity provider used when authenticating (e.g., Gmail, GitHub).

---

## ✅ Security Overview

- Port 22 is **closed to the internet**
- SSH uses **key authentication**
- Cloudflare Access enforces **identity-based pre-authentication**
- Logs and access can be audited via Cloudflare dashboard

---

## 📌 Notes

- Tunnel must be running (`systemctl status cloudflared-dev`)
- Only `cloudflared access ssh`-proxied connections will succeed
- You can extend this pattern to other services (Adminer, Portainer, etc.)

---

## 🧠 Why this matters

This setup emulates a Zero Trust environment using free tools and shows:
- Infrastructure-as-code (tunnel + config.yml)
- Security layering (SSH + Cloudflare)
- Practical DevOps skills using a real-world Raspberry Pi server

> Publicly demonstrating secure remote management on your own server is a strong signal of applied backend + infrastructure knowledge, especially for DAW graduates with DevOps interest.
