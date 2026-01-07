#!/bin/bash

# Simple build status checker
# Checks build every 30 seconds for 15 minutes

REPO="teo53/fansupport"
BRANCH="claude/project-review-IlFoF"
MAX_ATTEMPTS=30  # 15 minutes
ATTEMPT=0

echo "🔍 Monitoring build for $REPO on $BRANCH"
echo "=================================="
echo ""

while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    ATTEMPT=$((ATTEMPT + 1))
    CURRENT_TIME=$(date '+%H:%M:%S')

    echo "[$CURRENT_TIME] Check #$ATTEMPT/$MAX_ATTEMPTS"

    # Try to fetch latest commit status
    COMMIT_SHA=$(git rev-parse HEAD 2>/dev/null)

    if [ $? -eq 0 ]; then
        echo "  Latest commit: ${COMMIT_SHA:0:7}"
        echo "  Status: Check GitHub Actions page"
        echo "  URL: https://github.com/$REPO/actions"
    fi

    echo ""
    echo "  ⏳ Waiting 30 seconds..."
    echo "  📊 Visit: https://github.com/$REPO/actions"
    echo "  ⌨️  Press Ctrl+C to stop monitoring"
    echo ""

    sleep 30
done

echo "✅ Monitoring complete!"
echo "Visit https://github.com/$REPO/actions to see final result"
