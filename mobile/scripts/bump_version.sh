#!/bin/bash

# Version Bump Script
# Usage: ./scripts/bump_version.sh [patch|minor|major] [--tag]
#
# Examples:
#   ./scripts/bump_version.sh patch        # 1.0.0 -> 1.0.1
#   ./scripts/bump_version.sh minor        # 1.0.0 -> 1.1.0
#   ./scripts/bump_version.sh major        # 1.0.0 -> 2.0.0
#   ./scripts/bump_version.sh patch --tag  # Bump and create git tag

set -e

PUBSPEC_FILE="pubspec.yaml"
BUMP_TYPE=${1:-patch}
CREATE_TAG=${2}

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Validate bump type
if [[ ! "$BUMP_TYPE" =~ ^(patch|minor|major)$ ]]; then
  echo -e "${RED}❌ Invalid bump type: $BUMP_TYPE${NC}"
  echo "Usage: ./scripts/bump_version.sh [patch|minor|major] [--tag]"
  exit 1
fi

# Check if pubspec.yaml exists
if [ ! -f "$PUBSPEC_FILE" ]; then
  echo -e "${RED}❌ pubspec.yaml not found!${NC}"
  exit 1
fi

# Extract current version
CURRENT_VERSION=$(grep '^version:' $PUBSPEC_FILE | sed 's/version: //' | sed 's/+.*//')
CURRENT_BUILD=$(grep '^version:' $PUBSPEC_FILE | sed 's/version: //' | sed 's/.*+//')

echo -e "${BLUE}📦 Current version: ${YELLOW}$CURRENT_VERSION+$CURRENT_BUILD${NC}"

# Parse version components
IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=${VERSION_PARTS[2]}

# Bump version based on type
case $BUMP_TYPE in
  patch)
    PATCH=$((PATCH + 1))
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
esac

# Increment build number
NEW_BUILD=$((CURRENT_BUILD + 1))

# Create new version
NEW_VERSION="$MAJOR.$MINOR.$PATCH"
FULL_VERSION="$NEW_VERSION+$NEW_BUILD"

echo -e "${GREEN}✨ New version: ${YELLOW}$FULL_VERSION${NC}"

# Confirm before proceeding
read -p "$(echo -e ${YELLOW}Continue? [y/N]:${NC} )" -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo -e "${RED}❌ Aborted${NC}"
  exit 1
fi

# Update pubspec.yaml
sed -i.bak "s/^version: .*/version: $FULL_VERSION/" $PUBSPEC_FILE
rm -f "${PUBSPEC_FILE}.bak"

echo -e "${GREEN}✅ Updated pubspec.yaml${NC}"

# Create git tag if requested
if [[ "$CREATE_TAG" == "--tag" ]]; then
  if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${YELLOW}⚠️  Not a git repository, skipping tag creation${NC}"
  else
    TAG="v$NEW_VERSION"

    # Check if tag already exists
    if git rev-parse "$TAG" >/dev/null 2>&1; then
      echo -e "${YELLOW}⚠️  Tag $TAG already exists${NC}"
    else
      git tag -a "$TAG" -m "Release $NEW_VERSION (Build $NEW_BUILD)"
      echo -e "${GREEN}✅ Created git tag: $TAG${NC}"
      echo -e "${BLUE}💡 Push tag with: ${YELLOW}git push origin $TAG${NC}"
    fi
  fi
fi

# Show summary
echo ""
echo -e "${GREEN}═══════════════════════════════════${NC}"
echo -e "${GREEN}✨ Version Bump Complete!${NC}"
echo -e "${GREEN}═══════════════════════════════════${NC}"
echo -e "  Old: ${RED}$CURRENT_VERSION+$CURRENT_BUILD${NC}"
echo -e "  New: ${GREEN}$NEW_VERSION+$NEW_BUILD${NC}"
echo -e "${GREEN}═══════════════════════════════════${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo -e "  1. Review changes: ${YELLOW}git diff pubspec.yaml${NC}"
echo -e "  2. Commit changes: ${YELLOW}git add pubspec.yaml && git commit -m 'chore: bump version to $NEW_VERSION'${NC}"
if [[ "$CREATE_TAG" == "--tag" ]]; then
  echo -e "  3. Push tag: ${YELLOW}git push origin v$NEW_VERSION${NC}"
fi
echo ""
