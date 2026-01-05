#!/bin/bash

echo "🌐 PIPO 웹 테스트 서버 시작"
echo "================================"
echo ""

# Check if Python is installed
if command -v python3 &> /dev/null; then
    PYTHON_CMD=python3
elif command -v python &> /dev/null; then
    PYTHON_CMD=python
else
    echo "❌ Python이 설치되어 있지 않습니다."
    echo "Python을 설치한 후 다시 시도해주세요."
    exit 1
fi

echo "✅ Python 발견: $PYTHON_CMD"
echo ""
echo "📂 웹 디렉토리로 이동 중..."
cd mobile/web

echo "🚀 로컬 서버 시작 중..."
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🎨 랜딩 페이지:"
echo "     http://localhost:8000/landing.html"
echo ""
echo "  📱 Flutter 앱 (빌드 후):"
echo "     http://localhost:8000/index.html"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "💡 브라우저에서 위 주소로 접속하세요!"
echo "⏹️  서버 종료: Ctrl + C"
echo ""

# Start server
$PYTHON_CMD -m http.server 8000
