@echo off
chcp 65001 >nul
cls

echo 🌐 PIPO 웹 테스트 서버 시작
echo ================================
echo.

cd mobile\web

echo ✅ Python 서버 시작 중...
echo.
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo   🎨 랜딩 페이지:
echo      http://localhost:8000/landing.html
echo.
echo   📱 Flutter 앱 (빌드 후):
echo      http://localhost:8000/index.html
echo ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
echo.
echo 💡 브라우저에서 위 주소로 접속하세요!
echo ⏹️  서버 종료: Ctrl + C
echo.

python -m http.server 8000

pause
