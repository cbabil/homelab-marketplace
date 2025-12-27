#!/bin/bash
#
# Validate a single app definition
#
# Usage: ./scripts/validate-app.sh <app-id>
#
# Example: ./scripts/validate-app.sh pihole

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

if [ $# -lt 1 ]; then
    echo -e "${RED}Error: Missing app-id${NC}"
    echo "Usage: $0 <app-id>"
    exit 1
fi

APP_ID="$1"

# Find the app
APP_FILE=$(find apps -name "app.yaml" -path "*/$APP_ID/*" 2>/dev/null | head -1)

if [ -z "$APP_FILE" ]; then
    echo -e "${RED}Error: App '$APP_ID' not found${NC}"
    exit 1
fi

echo "Validating $APP_FILE..."
echo ""

ERRORS=0
WARNINGS=0

# Check YAML syntax
if ! python3 -c "import yaml; yaml.safe_load(open('$APP_FILE'))" 2>/dev/null; then
    echo -e "${RED}✗ Invalid YAML syntax${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ Valid YAML syntax${NC}"
fi

# Check required fields
REQUIRED_FIELDS="id name description version category docker"
for field in $REQUIRED_FIELDS; do
    if ! grep -q "^$field:" "$APP_FILE"; then
        echo -e "${RED}✗ Missing required field: $field${NC}"
        ERRORS=$((ERRORS + 1))
    fi
done

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All required fields present${NC}"
fi

# Check for TODO items
TODO_COUNT=$(grep -c "TODO" "$APP_FILE" 2>/dev/null || echo "0")
if [ "$TODO_COUNT" -gt 0 ]; then
    echo -e "${YELLOW}⚠ Found $TODO_COUNT TODO items - please complete them${NC}"
    WARNINGS=$((WARNINGS + 1))
fi

# Check Docker image version
if grep -q ":latest" "$APP_FILE"; then
    echo -e "${RED}✗ Docker image uses :latest tag - use pinned version${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ Docker image version is pinned${NC}"
fi

# Check for secrets
if grep -qi "password.*:.*['\"][^'\"]\+['\"]" "$APP_FILE" || \
   grep -qi "secret.*:.*['\"][^'\"]\+['\"]" "$APP_FILE" || \
   grep -qi "api_key.*:.*['\"][^'\"]\+['\"]" "$APP_FILE"; then
    echo -e "${RED}✗ Possible hardcoded secret detected${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ No hardcoded secrets detected${NC}"
fi

# Check description length
DESC=$(python3 -c "import yaml; print(yaml.safe_load(open('$APP_FILE')).get('description', ''))" 2>/dev/null)
DESC_LEN=${#DESC}
if [ $DESC_LEN -gt 200 ]; then
    echo -e "${YELLOW}⚠ Description is $DESC_LEN chars (max 200)${NC}"
    WARNINGS=$((WARNINGS + 1))
elif [ $DESC_LEN -lt 10 ]; then
    echo -e "${YELLOW}⚠ Description seems too short ($DESC_LEN chars)${NC}"
    WARNINGS=$((WARNINGS + 1))
else
    echo -e "${GREEN}✓ Description length OK ($DESC_LEN chars)${NC}"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}Validation failed: $ERRORS error(s), $WARNINGS warning(s)${NC}"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}Validation passed with $WARNINGS warning(s)${NC}"
    exit 0
else
    echo -e "${GREEN}Validation passed!${NC}"
    exit 0
fi
