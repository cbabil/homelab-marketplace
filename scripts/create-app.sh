#!/bin/bash
#
# Create a new app scaffold for the Homelab Marketplace
#
# Usage: ./scripts/create-app.sh <app-id> <category>
#
# Example: ./scripts/create-app.sh sonarr media
#
# Categories: automation, media, monitoring, networking, security, storage, utility

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Valid categories
VALID_CATEGORIES="automation media monitoring networking security storage utility"

# Check arguments
if [ $# -lt 2 ]; then
    echo -e "${RED}Error: Missing arguments${NC}"
    echo ""
    echo "Usage: $0 <app-id> <category>"
    echo ""
    echo "Arguments:"
    echo "  app-id    Lowercase app identifier (e.g., sonarr, grafana)"
    echo "  category  One of: $VALID_CATEGORIES"
    echo ""
    echo "Example:"
    echo "  $0 sonarr media"
    echo "  $0 grafana monitoring"
    exit 1
fi

APP_ID="$1"
CATEGORY="$2"

# Validate app-id format (lowercase, hyphens allowed)
if ! [[ "$APP_ID" =~ ^[a-z][a-z0-9-]*$ ]]; then
    echo -e "${RED}Error: Invalid app-id '$APP_ID'${NC}"
    echo "App ID must be lowercase, start with a letter, and contain only letters, numbers, and hyphens."
    exit 1
fi

# Validate category
if ! echo "$VALID_CATEGORIES" | grep -qw "$CATEGORY"; then
    echo -e "${RED}Error: Invalid category '$CATEGORY'${NC}"
    echo "Valid categories: $VALID_CATEGORIES"
    exit 1
fi

# Check if app already exists
APP_DIR="apps/$CATEGORY/$APP_ID"
if [ -d "$APP_DIR" ]; then
    echo -e "${RED}Error: App '$APP_ID' already exists at $APP_DIR${NC}"
    exit 1
fi

# Create app directory
mkdir -p "$APP_DIR"

# Generate app.yaml template
cat > "$APP_DIR/app.yaml" << EOF
id: $APP_ID
name: $APP_ID  # TODO: Update with display name
description: TODO - Add a brief description (max 200 chars)
version: "1.0.0"
category: $CATEGORY
tags:
  - TODO
  - add-relevant-tags

icon: https://example.com/icon.svg  # TODO: Update with app icon URL
repository: https://github.com/org/repo  # TODO: Update with source repo
documentation: https://docs.example.com  # TODO: Update with docs URL

docker:
  image: org/image:tag  # TODO: Use pinned version (not :latest)
  ports:
    - container: 8080
      host: 8080
      protocol: tcp
      description: Web UI
  volumes:
    - container: /config
      host: ./config
      mode: rw
      description: Configuration files
  environment:
    - name: TZ
      value: UTC
      required: false
      description: Timezone
    # TODO: Add other environment variables

requirements:
  memory: "512MB"  # TODO: Adjust based on app needs
  cpu: "1"
  storage: "1GB"

featured: false
EOF

echo -e "${GREEN}✓ Created app scaffold at $APP_DIR/app.yaml${NC}"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "1. Edit $APP_DIR/app.yaml and replace all TODO items"
echo "2. Update the name, description, and icon"
echo "3. Set the correct Docker image with a pinned version"
echo "4. Configure ports, volumes, and environment variables"
echo "5. Adjust resource requirements"
echo "6. Run validation: ./scripts/validate-app.sh $APP_ID"
echo "7. Update manifest.json to include the new app"
echo "8. Create a PR with your changes"
echo ""
echo -e "${GREEN}Documentation: https://github.com/cbabil/homelab-marketplace/blob/master/CONTRIBUTING.md${NC}"
