## 📬 Custom Domain & Email Forwarding

This system uses a custom domain registered via a third-party registrar and managed through Cloudflare DNS. Free email forwarding aliases are set up to organize communication by purpose.

### ✉️ Configured email aliases

| Alias address        | Forwards to         | Purpose                         |
|----------------------|---------------------|----------------------------------|
| contact@domain.tld   | [internal address]  | Public contact / portfolio       |
| contacto@domain.tld  | [internal address]  | Spanish version of contact       |
| services@domain.tld  | [internal address]  | Service registrations / tools    |

> These are forward-only addresses (no inbox). All DNS records are managed externally via DNS provider.

---

### 🛠️ DNS Configuration (via DNS provider)

#### Manually added records:

```text
Type: MX   | Name: @ | Content: [mail forward host 1] | Priority: 10
Type: MX   | Name: @ | Content: [mail forward host 2] | Priority: 20
Type: TXT  | Name: @ | Content: v=spf1 include:[provider SPF] ~all
```

> Proxy is disabled (DNS Only).  
> DMARC and DKIM are not configured yet. Recommended if sending mail from the domain.

---