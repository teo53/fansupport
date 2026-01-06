#!/bin/bash

# GitHub Actions APK Build Monitor
# Usage: ./monitor-build.sh

REPO="teo53/fansupport"
BRANCH="claude/project-review-IlFoF"
WORKFLOW="build-apk.yml"

echo "🔍 GitHub Actions APK Build Monitor"
echo "=================================="
echo "Repository: $REPO"
echo "Branch: $BRANCH"
echo "Workflow: $WORKFLOW"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo -e "${YELLOW}⚠️  GitHub CLI (gh) is not installed.${NC}"
    echo ""
    echo "Please visit GitHub Actions page manually:"
    echo -e "${BLUE}https://github.com/$REPO/actions/workflows/$WORKFLOW${NC}"
    echo ""
    echo "Or install gh CLI:"
    echo "  - macOS: brew install gh"
    echo "  - Linux: https://github.com/cli/cli#installation"
    echo ""
    exit 1
fi

echo "⏳ Fetching latest workflow runs..."
echo ""

# Get latest run
RUN_JSON=$(gh run list \
    --repo "$REPO" \
    --workflow "$WORKFLOW" \
    --branch "$BRANCH" \
    --limit 1 \
    --json databaseId,status,conclusion,displayTitle,createdAt,updatedAt,url \
    2>/dev/null)

if [ -z "$RUN_JSON" ] || [ "$RUN_JSON" = "[]" ]; then
    echo -e "${YELLOW}❌ No workflow runs found for branch: $BRANCH${NC}"
    echo ""
    echo "Possible reasons:"
    echo "  1. Workflow hasn't been triggered yet"
    echo "  2. Branch name is incorrect"
    echo "  3. Authentication issue with gh CLI"
    echo ""
    echo "Try visiting:"
    echo -e "${BLUE}https://github.com/$REPO/actions${NC}"
    exit 1
fi

# Parse JSON (using jq if available, otherwise basic parsing)
if command -v jq &> /dev/null; then
    RUN_ID=$(echo "$RUN_JSON" | jq -r '.[0].databaseId')
    STATUS=$(echo "$RUN_JSON" | jq -r '.[0].status')
    CONCLUSION=$(echo "$RUN_JSON" | jq -r '.[0].conclusion')
    TITLE=$(echo "$RUN_JSON" | jq -r '.[0].displayTitle')
    CREATED_AT=$(echo "$RUN_JSON" | jq -r '.[0].createdAt')
    UPDATED_AT=$(echo "$RUN_JSON" | jq -r '.[0].updatedAt')
    RUN_URL=$(echo "$RUN_JSON" | jq -r '.[0].url')
else
    echo -e "${YELLOW}⚠️  jq is not installed. Install it for better output.${NC}"
    echo "$RUN_JSON"
    exit 1
fi

echo "📋 Latest Workflow Run:"
echo "  ID: $RUN_ID"
echo "  Title: $TITLE"
echo "  Status: $STATUS"
echo "  Conclusion: $CONCLUSION"
echo "  Created: $CREATED_AT"
echo "  Updated: $UPDATED_AT"
echo "  URL: $RUN_URL"
echo ""

# Status-based output
if [ "$STATUS" = "completed" ]; then
    if [ "$CONCLUSION" = "success" ]; then
        echo -e "${GREEN}✅ Build completed successfully!${NC}"
        echo ""
        echo "📦 Downloading APK artifact..."
        gh run download "$RUN_ID" --repo "$REPO" --dir "./apk-output" 2>/dev/null

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ APK downloaded to: ./apk-output/${NC}"
            ls -lh ./apk-output/
        else
            echo -e "${YELLOW}⚠️  Could not download artifact. Download manually from:${NC}"
            echo -e "${BLUE}$RUN_URL${NC}"
        fi
    elif [ "$CONCLUSION" = "failure" ]; then
        echo -e "${RED}❌ Build failed!${NC}"
        echo ""
        echo "📝 Showing error logs..."
        gh run view "$RUN_ID" --repo "$REPO" --log-failed
    else
        echo -e "${YELLOW}⚠️  Build completed with status: $CONCLUSION${NC}"
    fi
elif [ "$STATUS" = "in_progress" ] || [ "$STATUS" = "queued" ] || [ "$STATUS" = "waiting" ]; then
    echo -e "${YELLOW}⏳ Build is currently: $STATUS${NC}"
    echo ""
    echo "🔄 Watching build progress..."
    echo "   (Press Ctrl+C to exit)"
    echo ""

    # Watch the run
    gh run watch "$RUN_ID" --repo "$REPO"

    # After completion, check result
    FINAL_STATUS=$(gh run view "$RUN_ID" --repo "$REPO" --json conclusion -q '.conclusion')

    if [ "$FINAL_STATUS" = "success" ]; then
        echo ""
        echo -e "${GREEN}✅ Build completed successfully!${NC}"
        echo ""
        echo "📦 Downloading APK artifact..."
        gh run download "$RUN_ID" --repo "$REPO" --dir "./apk-output"

        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✅ APK downloaded to: ./apk-output/${NC}"
            ls -lh ./apk-output/
        fi
    else
        echo ""
        echo -e "${RED}❌ Build failed!${NC}"
        echo ""
        echo "📝 Showing error logs..."
        gh run view "$RUN_ID" --repo "$REPO" --log-failed
    fi
else
    echo -e "${YELLOW}⚠️  Unknown status: $STATUS${NC}"
fi

echo ""
echo "For more details, visit:"
echo -e "${BLUE}$RUN_URL${NC}"
