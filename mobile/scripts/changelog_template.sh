#!/bin/bash

# Generate changelog template for current version
# Usage: ./scripts/changelog_template.sh

PUBSPEC_FILE="pubspec.yaml"
CHANGELOG_FILE="CHANGELOG.md"

if [ ! -f "$PUBSPEC_FILE" ]; then
  echo "❌ pubspec.yaml not found!"
  exit 1
fi

# Extract version
VERSION=$(grep '^version:' $PUBSPEC_FILE | sed 's/version: //' | sed 's/+.*//')
BUILD=$(grep '^version:' $PUBSPEC_FILE | sed 's/version: //' | sed 's/.*+//')
DATE=$(date +"%Y-%m-%d")

# Create CHANGELOG.md if it doesn't exist
if [ ! -f "$CHANGELOG_FILE" ]; then
  cat > "$CHANGELOG_FILE" << 'EOF'
# Changelog

All notable changes to PIPO (Underground Idol & Maid Cafe Fan Support Platform) will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

EOF
fi

# Prepare changelog entry
ENTRY="## [$VERSION] - $DATE

### Added
-

### Changed
-

### Fixed
-

### Removed
-

"

# Check if version already exists
if grep -q "\[$VERSION\]" "$CHANGELOG_FILE"; then
  echo "⚠️  Version $VERSION already exists in CHANGELOG.md"
  echo "Please update the existing entry manually."
  exit 0
fi

# Insert entry after the header
sed -i.bak "/^# Changelog/,/^$/a\\
$ENTRY" "$CHANGELOG_FILE"
rm -f "${CHANGELOG_FILE}.bak"

echo "✅ Added changelog template for version $VERSION"
echo "📝 Please edit $CHANGELOG_FILE to add your changes"
echo ""
echo "Opening $CHANGELOG_FILE..."
if command -v code &> /dev/null; then
  code "$CHANGELOG_FILE"
elif command -v nano &> /dev/null; then
  nano "$CHANGELOG_FILE"
else
  echo "Please open $CHANGELOG_FILE manually to edit"
fi
