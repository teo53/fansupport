#!/bin/bash

# Staging environment runner
echo "🔧 Starting app in STAGING mode..."

flutter run \
  --dart-define=ENV=staging \
  --dart-define=SUPABASE_URL_STAGING="https://your-staging-project.supabase.co" \
  --dart-define=SUPABASE_ANON_KEY_STAGING="your-staging-anon-key" \
  --release \
  "$@"
