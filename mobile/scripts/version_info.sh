#!/bin/bash

# Display current version information
# Usage: ./scripts/version_info.sh

PUBSPEC_FILE="pubspec.yaml"

# Colors
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

if [ ! -f "$PUBSPEC_FILE" ]; then
  echo "❌ pubspec.yaml not found!"
  exit 1
fi

# Extract version
CURRENT_VERSION=$(grep '^version:' $PUBSPEC_FILE | sed 's/version: //' | sed 's/+.*//')
CURRENT_BUILD=$(grep '^version:' $PUBSPEC_FILE | sed 's/version: //' | sed 's/.*+//')

# Parse version components
IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}

# Calculate next versions
NEXT_PATCH="$MAJOR.$MINOR.$((PATCH + 1))"
NEXT_MINOR="$MAJOR.$((MINOR + 1)).0"
NEXT_MAJOR="$((MAJOR + 1)).0.0"
NEXT_BUILD=$((CURRENT_BUILD + 1))

echo -e "${BLUE}═══════════════════════════════════${NC}"
echo -e "${GREEN}📦 PIPO Version Information${NC}"
echo -e "${BLUE}═══════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Current Version:${NC}"
echo -e "  Full: ${GREEN}$CURRENT_VERSION+$CURRENT_BUILD${NC}"
echo -e "  Version: ${GREEN}$CURRENT_VERSION${NC}"
echo -e "  Build: ${GREEN}$CURRENT_BUILD${NC}"
echo ""
echo -e "${YELLOW}Version Components:${NC}"
echo -e "  Major: $MAJOR"
echo -e "  Minor: $MINOR"
echo -e "  Patch: $PATCH"
echo ""
echo -e "${YELLOW}Next Versions:${NC}"
echo -e "  Patch: ${GREEN}$NEXT_PATCH+$NEXT_BUILD${NC} (bug fixes)"
echo -e "  Minor: ${GREEN}$NEXT_MINOR+$NEXT_BUILD${NC} (new features)"
echo -e "  Major: ${GREEN}$NEXT_MAJOR+$NEXT_BUILD${NC} (breaking changes)"
echo ""
echo -e "${BLUE}═══════════════════════════════════${NC}"
echo ""
echo -e "${YELLOW}Commands:${NC}"
echo -e "  ./scripts/bump_version.sh patch        # Bump to $NEXT_PATCH"
echo -e "  ./scripts/bump_version.sh minor        # Bump to $NEXT_MINOR"
echo -e "  ./scripts/bump_version.sh major        # Bump to $NEXT_MAJOR"
echo -e "  ./scripts/bump_version.sh patch --tag  # Bump and create git tag"
echo ""
