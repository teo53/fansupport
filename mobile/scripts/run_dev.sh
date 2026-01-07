#!/bin/bash

# Development environment runner
echo "🚀 Starting app in DEVELOPMENT mode..."

flutter run \
  --dart-define=ENV=development \
  --dart-define=SUPABASE_URL_DEV="https://your-project.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY_DEV="your-dev-anon-key" \
  --dart-define=USE_MOCK=true \
  "$@"
