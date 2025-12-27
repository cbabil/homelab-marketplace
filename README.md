# Homelab Marketplace

Curated Docker app definitions for [Homelab Assistant](https://github.com/cbabil/homelab).

## Quick Start

```bash
# Install an app
homelab install pihole

# Add a new app
./scripts/create-app.sh <category> <app-id>
```

## Apps

| App | Category | Description |
|-----|----------|-------------|
| [Authelia](apps/security/authelia) | security | 2FA and SSO authentication server |
| [Grafana](apps/monitoring/grafana) | monitoring | Metrics visualization platform |
| [Heimdall](apps/utility/heimdall) | utility | Application dashboard |
| [Jellyfin](apps/media/jellyfin) | media | Media streaming server |
| [n8n](apps/automation/n8n) | automation | Workflow automation |
| [Netdata](apps/monitoring/netdata) | monitoring | Real-time performance monitoring |
| [Nextcloud](apps/storage/nextcloud) | storage | File sync and collaboration |
| [Pi-hole](apps/networking/pihole) | networking | Network-wide ad blocking |
| [Portainer](apps/utility/portainer) | utility | Docker management UI |
| [Prometheus](apps/monitoring/prometheus) | monitoring | Metrics collection and alerting |
| [Traefik](apps/networking/traefik) | networking | Reverse proxy with auto HTTPS |
| [Uptime Kuma](apps/monitoring/uptime-kuma) | monitoring | Uptime monitoring |

## Documentation

Visit the **[Wiki](https://github.com/cbabil/homelab-marketplace/wiki)** for:

- [App Categories](https://github.com/cbabil/homelab-marketplace/wiki/App-Categories) - Browse all apps
- [App Definition](https://github.com/cbabil/homelab-marketplace/wiki/App-Definition) - YAML format reference
- [Repository Structure](https://github.com/cbabil/homelab-marketplace/wiki/Repository-Structure) - How the repo is organized

## Contributing

Want to add an app? See [CONTRIBUTING.md](CONTRIBUTING.md).

## Links

- [Security Policy](SECURITY.md)
- [Releases](https://github.com/cbabil/homelab-marketplace/releases)
- [License](LICENSE) (MIT)
