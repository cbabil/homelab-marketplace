# Security Policy

## Supported Versions

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |

## Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability in this repository, please report it responsibly.

### How to Report

1. **Do NOT** create a public GitHub issue for security vulnerabilities
2. Email security concerns to the repository owner
3. Include as much detail as possible:
   - Description of the vulnerability
   - Steps to reproduce
   - Potential impact
   - Suggested fix (if any)

### What to Expect

- Acknowledgment within 48 hours
- Regular updates on the progress
- Credit in the security advisory (if desired)

## Security Controls

### Automated Scanning

All pull requests are automatically scanned for:

| Check | Description |
|-------|-------------|
| **Trusted Registries** | Images must be from Docker Hub, ghcr.io, lscr.io, quay.io, gcr.io, or mcr.microsoft.com |
| **Vulnerability Scan** | Trivy scans for CRITICAL and HIGH CVEs |
| **Malicious Patterns** | Detection of cryptominers, backdoors, reverse shells |
| **Dangerous Mounts** | Blocks access to /, /etc, /root, /home, /proc, /sys |
| **Docker Socket** | Warns on Docker socket mounts, blocks read-write |
| **Privileged Mode** | Blocked - no app may run privileged |
| **Secret Detection** | Scans for API keys, tokens, credentials |
| **URL Verification** | Checks that icon/repo/docs URLs are reachable |

### Required Code Review

All changes require maintainer approval via CODEOWNERS:
- All app definitions (`apps/`)
- Schema changes (`schemas/`)
- Workflows (`.github/workflows/`)
- Scripts (`scripts/`)
- Manifest (`manifest.json`)

### Blocked Configurations

The following are **automatically rejected**:

```yaml
# BLOCKED - Privileged mode
docker:
  privileged: true

# BLOCKED - Dangerous mounts
volumes:
  - container: /anything
    host: /etc
    mode: rw

# BLOCKED - Forbidden tags
docker:
  image: anything:latest  # Also: dev, nightly, edge, unstable

# BLOCKED - Malicious patterns
description: Contains cryptominer...  # Flagged immediately
```

### Warned Configurations

The following trigger **warnings** that require manual review:

```yaml
# WARNING - Docker socket (required for some apps like Portainer)
volumes:
  - container: /var/run/docker.sock
    host: /var/run/docker.sock
    mode: ro  # Must be read-only

# WARNING - Dangerous capabilities
capabilities:
  - NET_ADMIN  # Requires justification
  - SYS_ADMIN  # Requires strong justification

# WARNING - Host network
network_mode: host  # Requires justification
```

## App Submission Security Requirements

All submitted apps **MUST**:

1. **Use trusted registries only**
   - Docker Hub (official or verified)
   - ghcr.io (GitHub Container Registry)
   - lscr.io (LinuxServer.io)
   - quay.io (Red Hat)
   - gcr.io (Google)
   - mcr.microsoft.com (Microsoft)

2. **Pin image versions**
   - Use specific version tags (e.g., `10.9.11`)
   - Never use `latest`, `dev`, `nightly`, `edge`, `master`, `main`

3. **No hardcoded secrets**
   - All passwords, tokens, API keys must be empty strings
   - Mark sensitive variables as `required: true`

4. **Minimal privileges**
   - No `privileged: true`
   - No unnecessary capabilities
   - Mount volumes read-only where possible

5. **Verified source**
   - Repository URL must match the image source
   - Documentation must be official

6. **HTTPS everywhere**
   - All URLs (icon, repository, documentation) must use HTTPS

## Trusted Image Sources

| Registry | URL | Notes |
|----------|-----|-------|
| Docker Hub | docker.io | Official and verified publishers preferred |
| GitHub | ghcr.io | Must match repository owner |
| LinuxServer | lscr.io | Community-maintained, well-trusted |
| Quay | quay.io | Red Hat's registry |
| Google | gcr.io | Google Cloud images |
| Microsoft | mcr.microsoft.com | Microsoft images |

## What We Block

### Malicious Patterns

- Cryptocurrency miners (xmrig, monero, coinhive)
- Botnets
- Backdoors
- Reverse shells
- Remote access trojans

### Dangerous Access

- Root filesystem mount (`/`)
- System directories (`/etc`, `/usr`, `/bin`, `/sbin`)
- User directories (`/root`, `/home`)
- Kernel interfaces (`/proc`, `/sys`, `/dev`)
- Boot files (`/boot`)

### Credential Patterns

- GitHub tokens (`ghp_*`, `gho_*`)
- AWS keys (`AKIA*`)
- OpenAI keys (`sk-*`)
- Slack tokens (`xox*-*`)
- JWT tokens
- Base64-encoded secrets

## Security Best Practices for Contributors

1. **Never commit secrets** - Use empty strings, let users provide values
2. **Pin image versions** - Always use specific version tags
3. **Minimize privileges** - Request only what the app needs
4. **Verify image sources** - Check the official documentation
5. **Use read-only mounts** - Only use `rw` when necessary
6. **Document permissions** - Explain why capabilities are needed

## Incident Response

If a malicious app is discovered:

1. Immediately remove from manifest and apps/
2. Create security advisory
3. Notify users who may have deployed it
4. Review how it passed automated checks
5. Update detection rules

## Questions?

Open a [Discussion](https://github.com/cbabil/tomo-marketplace/discussions) for security-related questions.
