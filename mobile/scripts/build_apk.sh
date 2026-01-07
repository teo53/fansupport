#!/bin/bash

# Build APK for different environments
# Usage: ./scripts/build_apk.sh [dev|staging|prod]

ENV=${1:-prod}

case $ENV in
  dev|development)
    echo "🔨 Building APK for DEVELOPMENT..."
    flutter build apk \
      --dart-define=ENV=development \
      --dart-define=SUPABASE_URL_DEV="https://your-project.supabase.co" \
      --dart-define=SUPABASE_ANON_KEY_DEV="your-dev-anon-key" \
      --debug
    ;;

  staging|stage)
    echo "🔨 Building APK for STAGING..."
    flutter build apk \
      --dart-define=ENV=staging \
      --dart-define=SUPABASE_URL_STAGING="https://your-staging-project.supabase.co" \
      --dart-define=SUPABASE_ANON_KEY_STAGING="your-staging-anon-key" \
      --release
    ;;

  prod|production)
    echo "🔨 Building APK for PRODUCTION..."
    flutter build apk \
      --dart-define=ENV=production \
      --dart-define=SUPABASE_URL="https://your-production-project.supabase.co" \
      --dart-define=SUPABASE_ANON_KEY="your-production-anon-key" \
      --release
    ;;

  *)
    echo "❌ Invalid environment: $ENV"
    echo "Usage: ./scripts/build_apk.sh [dev|staging|prod]"
    exit 1
    ;;
esac

echo "✅ Build complete!"
