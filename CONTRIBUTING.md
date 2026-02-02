# Contributing to Tomo Marketplace

Thank you for your interest in contributing to the Tomo Marketplace! This guide will help you submit apps that meet our quality standards.

## Quick Start

The fastest way to add a new app:

```bash
# Clone the repo
git clone https://github.com/cbabil/tomo-marketplace.git
cd tomo-marketplace

# Create app scaffold
./scripts/create-app.sh myapp media

# Edit the generated app.yaml
vim apps/media/myapp/app.yaml

# Validate locally
./scripts/validate-app.sh myapp

# Submit PR
git checkout -b add-myapp
git add apps/media/myapp
git commit -m "feat: add myapp"
git push origin add-myapp
```

## Detailed Guide

### Step 1: Fork and Clone

```bash
# Fork on GitHub, then clone your fork
git clone https://github.com/YOUR_USERNAME/tomo-marketplace.git
cd tomo-marketplace
```

### Step 2: Create App Scaffold

Use our generator script to create the app structure:

```bash
./scripts/create-app.sh <app-id> <category>
```

**Arguments:**
- `app-id`: Lowercase identifier (e.g., `sonarr`, `grafana`, `pi-hole`)
- `category`: One of the valid categories (see below)

**Example:**
```bash
./scripts/create-app.sh grafana monitoring
# Creates: apps/monitoring/grafana/app.yaml
```

### Step 3: Edit app.yaml

Fill in the generated template with your app's details:

```yaml
id: grafana
name: Grafana
description: Open-source analytics and monitoring platform for metrics visualization
version: "1.0.0"
category: monitoring
tags:
  - metrics
  - visualization
  - dashboards

icon: https://grafana.com/static/img/grafana_icon.svg
repository: https://github.com/grafana/grafana
documentation: https://grafana.com/docs/

docker:
  image: grafana/grafana:10.2.3  # Pin to specific version!
  ports:
    - container: 3000
      host: 3000
      protocol: tcp
      description: Web UI
  volumes:
    - container: /var/lib/grafana
      host: ./data
      mode: rw
      description: Grafana data storage
  environment:
    - name: GF_SECURITY_ADMIN_USER
      value: ""  # Leave empty for user to set
      required: true
      description: Admin username
    - name: GF_SECURITY_ADMIN_PASSWORD
      value: ""  # Leave empty for user to set
      required: true
      description: Admin password
    - name: TZ
      value: UTC
      required: false
      description: Timezone

requirements:
  memory: "256MB"
  cpu: "0.5"
  storage: "1GB"

featured: false
```

### Step 4: Validate Locally

Run the validation script to catch issues before submitting:

```bash
./scripts/validate-app.sh grafana
```

This checks:
- YAML syntax
- Required fields
- Docker image version (no `:latest`)
- Hardcoded secrets
- Description length
- TODO items

### Step 5: Update Manifest

Add your app to `manifest.json`:

```json
{
  "apps": [
    // ... existing apps ...
    {
      "id": "grafana",
      "name": "Grafana",
      "version": "1.0.0",
      "category": "monitoring",
      "description": "Open-source analytics and monitoring platform",
      "path": "apps/monitoring/grafana"
    }
  ]
}
```

### Step 6: Submit Pull Request

```bash
git checkout -b add-grafana
git add apps/monitoring/grafana manifest.json
git commit -m "feat: add grafana app"
git push origin add-grafana
```

Then open a Pull Request on GitHub. Our automation will:
- Auto-label your PR by category
- Run validation checks
- Comment with a summary

## App Categories

| Category | Description | Examples |
|----------|-------------|----------|
| `automation` | Workflow automation, scheduling | n8n, Home Assistant |
| `media` | Media servers, streaming | Jellyfin, Plex, Sonarr |
| `monitoring` | Metrics, logging, alerting | Grafana, Prometheus |
| `networking` | DNS, VPN, reverse proxies | Pi-hole, WireGuard |
| `security` | Authentication, scanning | Authelia, CrowdSec |
| `storage` | Backup, file sharing | Nextcloud, Syncthing |
| `utility` | Tools, management | Portainer, Heimdall |

## Schema Requirements

Your `app.yaml` is validated against our [JSON Schema](schemas/app.schema.json).

### Required Fields

| Field | Type | Description |
|-------|------|-------------|
| `id` | string | Unique lowercase ID (`^[a-z][a-z0-9-]*$`) |
| `name` | string | Display name (1-50 chars) |
| `description` | string | Brief description (10-200 chars) |
| `version` | string | Semantic version (`X.Y.Z`) |
| `category` | string | One of the valid categories |
| `docker` | object | Docker configuration |
| `docker.image` | string | Image with pinned version |
| `requirements` | object | Resource requirements |

### Docker Configuration

```yaml
docker:
  image: org/image:tag  # Required, must have version tag
  ports:                # Optional
    - container: 8080   # Container port (1-65535)
      host: 8080        # Host port (1-65535)
      protocol: tcp     # tcp or udp
      description: Web UI
  volumes:              # Optional
    - container: /data  # Must start with /
      host: ./data      # Host path
      mode: rw          # rw or ro
      description: Data storage
  environment:          # Optional
    - name: VAR_NAME    # UPPER_SNAKE_CASE
      value: ""         # Default value
      required: false   # Is this required?
      description: Variable description
```

### Requirements

```yaml
requirements:
  memory: "512MB"   # Minimum RAM (MB or GB)
  cpu: "1"          # Minimum CPU cores
  storage: "10GB"   # Minimum storage (MB, GB, or TB)
```

## Security Guidelines

### Do NOT include:
- Hardcoded passwords or secrets
- API keys or tokens
- Private registry credentials

### Do:
- Use empty values for secrets (`value: ""`)
- Mark secrets as `required: true`
- Document what each secret is for
- Use pinned Docker image versions

### Example - Handling Secrets:

```yaml
# Good - user must provide
environment:
  - name: DB_PASSWORD
    value: ""
    required: true
    description: Database password (user must set)

# Bad - hardcoded secret
environment:
  - name: DB_PASSWORD
    value: "mysecretpassword123"  # NEVER do this!
```

## Quality Checklist

Before submitting, verify:

- [ ] App ID is unique and follows naming convention
- [ ] Docker image is from a trusted source (Docker Hub, ghcr.io, etc.)
- [ ] Docker image has a pinned version (no `:latest`)
- [ ] No hardcoded credentials or secrets
- [ ] All TODO items are resolved
- [ ] Description is clear and under 200 characters
- [ ] Category is appropriate for the app
- [ ] Resource requirements are realistic
- [ ] All required fields are filled
- [ ] Local validation passes (`./scripts/validate-app.sh`)
- [ ] Manifest is updated

## CI Checks

Pull requests are automatically validated:

| Check | Description |
|-------|-------------|
| Schema Validation | app.yaml matches JSON schema |
| Docker Image Check | Image has pinned version |
| Secret Detection | No hardcoded secrets |
| Manifest Sync | manifest.json matches filesystem |

All checks must pass before merging.

## Getting Help

- **Questions**: Open a [Discussion](https://github.com/cbabil/tomo-marketplace/discussions)
- **Bugs**: Open an [Issue](https://github.com/cbabil/tomo-marketplace/issues)
- **Chat**: Join our community discussions

## Code of Conduct

- Be respectful and constructive
- Focus on technical merits
- Help others improve their submissions
- Follow the schema and guidelines
