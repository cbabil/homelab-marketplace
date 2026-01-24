<div align="center">

# Homelab Marketplace

[![Validate Apps](https://github.com/cbabil/homelab-marketplace/actions/workflows/validate.yml/badge.svg)](https://github.com/cbabil/homelab-marketplace/actions/workflows/validate.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub stars](https://img.shields.io/github/stars/cbabil/homelab-marketplace)](https://github.com/cbabil/homelab-marketplace/stargazers)
[![GitHub last commit](https://img.shields.io/github/last-commit/cbabil/homelab-marketplace)](https://github.com/cbabil/homelab-marketplace/commits)
[![GitHub issues](https://img.shields.io/github/issues/cbabil/homelab-marketplace)](https://github.com/cbabil/homelab-marketplace/issues)
[![GitHub pull requests](https://img.shields.io/github/issues-pr/cbabil/homelab-marketplace)](https://github.com/cbabil/homelab-marketplace/pulls)

**Custom Docker app definitions for Homelab infrastructure**

[Quick Start](#quick-start) · [Apps](#apps) · [Documentation](https://github.com/cbabil/homelab-marketplace/wiki) · [Contributing](CONTRIBUTING.md)

</div>

---

## About

This marketplace contains **custom apps not available in CasaOS App Store**. For common self-hosted applications (Jellyfin, Nextcloud, Pi-hole, Portainer, Grafana, etc.), use the [CasaOS App Store](https://github.com/IceWhaleTech/CasaOS-AppStore).

## Quick Start

```bash
# Install an app
homelab install homelab-agent

# Add a new app
./scripts/create-app.sh <category> <app-id>

# Validate an app
./scripts/validate-app.sh <app-id>
```

## Apps

| App | Category | Description |
|-----|----------|-------------|
| [Homelab Agent](apps/utility/homelab-agent) | utility | Agent for remote server management and monitoring |

## Documentation

Visit the **[Wiki](https://github.com/cbabil/homelab-marketplace/wiki)** for:

- [App Categories](https://github.com/cbabil/homelab-marketplace/wiki/App-Categories) - Browse all apps
- [App Definition](https://github.com/cbabil/homelab-marketplace/wiki/App-Definition) - YAML format reference
- [Repository Structure](https://github.com/cbabil/homelab-marketplace/wiki/Repository-Structure) - How the repo is organized

## Contributing

Want to add an app? See [CONTRIBUTING.md](CONTRIBUTING.md).

---

<div align="center">

[Security Policy](SECURITY.md) · [Releases](https://github.com/cbabil/homelab-marketplace/releases) · [License](LICENSE)

</div>
