#!/bin/bash
#
# Strict validation for a single app definition
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

echo "Validating $APP_FILE (strict mode)..."
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

# Validate against JSON Schema
if [ -f "schemas/app.schema.json" ]; then
    SCHEMA_ERRORS=$(python3 << EOF 2>&1 || true
import yaml
import json
from jsonschema import Draft7Validator

with open('schemas/app.schema.json') as f:
    schema = json.load(f)
with open('$APP_FILE') as f:
    data = yaml.safe_load(f)

validator = Draft7Validator(schema)
errors = list(validator.iter_errors(data))
for e in errors:
    path = '.'.join(str(p) for p in e.absolute_path)
    if path:
        print(f'{path}: {e.message}')
    else:
        print(e.message)
EOF
)
    if [ -n "$SCHEMA_ERRORS" ]; then
        echo -e "${RED}✗ Schema validation failed:${NC}"
        echo "$SCHEMA_ERRORS" | while read line; do
            echo -e "  ${RED}• $line${NC}"
            ERRORS=$((ERRORS + 1))
        done
        ERRORS=$((ERRORS + 1))
    else
        echo -e "${GREEN}✓ Schema validation passed${NC}"
    fi
fi

# Check for TODO/FIXME items (strict: these are errors)
TODO_COUNT=$(grep -cE "TODO|FIXME" "$APP_FILE" 2>/dev/null || echo "0")
if [ "$TODO_COUNT" -gt 0 ]; then
    echo -e "${RED}✗ Found $TODO_COUNT TODO/FIXME items - must be resolved${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ No TODO/FIXME items${NC}"
fi

# Check for placeholder text
PLACEHOLDERS="example.com your- changeme placeholder UPDATE"
for placeholder in $PLACEHOLDERS; do
    if grep -qi "$placeholder" "$APP_FILE" 2>/dev/null; then
        echo -e "${RED}✗ Contains placeholder text: $placeholder${NC}"
        ERRORS=$((ERRORS + 1))
    fi
done

# Check Docker image version (strict)
FORBIDDEN_TAGS="latest dev nightly edge unstable master main beta alpha rc"
IMAGE=$(python3 -c "import yaml; print(yaml.safe_load(open('$APP_FILE')).get('docker', {}).get('image', ''))" 2>/dev/null)
if [ -n "$IMAGE" ]; then
    if [[ "$IMAGE" != *":"* ]]; then
        echo -e "${RED}✗ Docker image has no version tag: $IMAGE${NC}"
        ERRORS=$((ERRORS + 1))
    else
        TAG="${IMAGE##*:}"
        for forbidden in $FORBIDDEN_TAGS; do
            if [ "$TAG" = "$forbidden" ]; then
                echo -e "${RED}✗ Forbidden tag ':$TAG' - use specific version${NC}"
                ERRORS=$((ERRORS + 1))
                break
            fi
        done
        # Check semver format
        if [[ ! "$TAG" =~ ^v?[0-9]+(\.[0-9]+)*(-[a-zA-Z0-9._-]+)?$ ]]; then
            echo -e "${YELLOW}⚠ Tag '$TAG' is not semver format${NC}"
            WARNINGS=$((WARNINGS + 1))
        else
            echo -e "${GREEN}✓ Docker image version is valid: $IMAGE${NC}"
        fi
    fi
fi

# Check for secrets (strict)
python3 << EOF
import yaml
import sys

with open('$APP_FILE') as f:
    data = yaml.safe_load(f)

errors = 0
docker = data.get('docker', {})
for env in docker.get('environment', []):
    name = env.get('name', '').lower()
    value = str(env.get('value', ''))
    secret_keywords = ['password', 'secret', 'api_key', 'apikey', 'token', 'private_key', 'credential', 'auth']
    if any(kw in name for kw in secret_keywords):
        if len(value) > 0:
            print(f"ERROR: Secret value must be empty for {env.get('name')}")
            errors += 1

if errors == 0:
    print("OK: No hardcoded secrets")
sys.exit(errors)
EOF
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ No hardcoded secrets${NC}"
else
    echo -e "${RED}✗ Hardcoded secrets detected${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check ID matches directory
DIR_NAME=$(basename "$(dirname "$APP_FILE")")
YAML_ID=$(python3 -c "import yaml; print(yaml.safe_load(open('$APP_FILE')).get('id', ''))" 2>/dev/null)
if [ "$YAML_ID" != "$DIR_NAME" ]; then
    echo -e "${RED}✗ App ID '$YAML_ID' must match directory name '$DIR_NAME'${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ App ID matches directory${NC}"
fi

# Check category matches directory
CATEGORY_DIR=$(basename "$(dirname "$(dirname "$APP_FILE")")")
YAML_CATEGORY=$(python3 -c "import yaml; print(yaml.safe_load(open('$APP_FILE')).get('category', ''))" 2>/dev/null)
if [ "$YAML_CATEGORY" != "$CATEGORY_DIR" ]; then
    echo -e "${RED}✗ Category '$YAML_CATEGORY' must match directory '$CATEGORY_DIR'${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ Category matches directory${NC}"
fi

# Check URLs are HTTPS
for field in icon repository documentation; do
    URL=$(python3 -c "import yaml; print(yaml.safe_load(open('$APP_FILE')).get('$field', ''))" 2>/dev/null)
    if [ -n "$URL" ]; then
        if [[ "$URL" == http://* ]]; then
            echo -e "${RED}✗ $field must use HTTPS: $URL${NC}"
            ERRORS=$((ERRORS + 1))
        else
            echo -e "${GREEN}✓ $field uses HTTPS${NC}"
        fi
    fi
done

# Check description format
DESC=$(python3 -c "import yaml; print(yaml.safe_load(open('$APP_FILE')).get('description', ''))" 2>/dev/null)
DESC_LEN=${#DESC}
if [ $DESC_LEN -lt 20 ]; then
    echo -e "${RED}✗ Description too short ($DESC_LEN chars, min 20)${NC}"
    ERRORS=$((ERRORS + 1))
elif [ $DESC_LEN -gt 200 ]; then
    echo -e "${RED}✗ Description too long ($DESC_LEN chars, max 200)${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ Description length OK ($DESC_LEN chars)${NC}"
fi

# Check description starts with capital, ends with punctuation
if [[ ! "$DESC" =~ ^[A-Z] ]]; then
    echo -e "${RED}✗ Description must start with capital letter${NC}"
    ERRORS=$((ERRORS + 1))
fi
if [[ ! "$DESC" =~ [.!]$ ]]; then
    echo -e "${RED}✗ Description must end with period or exclamation${NC}"
    ERRORS=$((ERRORS + 1))
fi

# Check privileged mode
PRIVILEGED=$(python3 -c "import yaml; print(yaml.safe_load(open('$APP_FILE')).get('docker', {}).get('privileged', False))" 2>/dev/null)
if [ "$PRIVILEGED" = "True" ]; then
    echo -e "${RED}✗ Privileged mode is not allowed${NC}"
    ERRORS=$((ERRORS + 1))
else
    echo -e "${GREEN}✓ No privileged mode${NC}"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
if [ $ERRORS -gt 0 ]; then
    echo -e "${RED}Validation FAILED: $ERRORS error(s), $WARNINGS warning(s)${NC}"
    exit 1
elif [ $WARNINGS -gt 0 ]; then
    echo -e "${YELLOW}Validation passed with $WARNINGS warning(s)${NC}"
    exit 0
else
    echo -e "${GREEN}Validation passed!${NC}"
    exit 0
fi
