#!/bin/bash
# Bundle React app into a single HTML file for claude.ai artifacts
# Usage: bash bundle-artifact.sh [output-name]
# Run this from the artifact project directory

set -e

OUTPUT_NAME=${1:-"bundle"}

echo "📦 Bundling artifact..."

# Check if index.html exists
if [ ! -f "index.html" ]; then
  echo "❌ Error: index.html not found in current directory"
  exit 1
fi

# Install bundling dependencies if needed
if ! npm list parcel > /dev/null 2>&1; then
  echo "Installing bundling dependencies..."
  npm install -D parcel @parcel/config-default parcel-resolver-tspaths html-inline
fi

# Create .parcelrc for path alias support
cat > .parcelrc << 'EOF'
{
  "extends": "@parcel/config-default",
  "resolvers": ["parcel-resolver-tspaths", "..."]
}
EOF

# Build with Parcel
echo "Building with Parcel..."
npx parcel build index.html --no-source-maps --dist-dir dist

# Inline all assets into single HTML
echo "Inlining assets..."
npx html-inline -i dist/index.html -o "${OUTPUT_NAME}.html" -b dist

# Cleanup
rm -rf dist .parcel-cache

echo "✅ Bundled to ${OUTPUT_NAME}.html"
echo "📋 Copy this file content to share as a Claude artifact"

# Show file size
ls -lh "${OUTPUT_NAME}.html"
