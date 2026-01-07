#!/bin/bash

# Production environment runner
echo "🚀 Starting app in PRODUCTION mode..."

flutter run \
  --dart-define=ENV=production \
  --dart-define=SUPABASE_URL="https://your-production-project.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY="your-production-anon-key" \
  --release \
  "$@"
