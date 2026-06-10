@echo off
cd /d "%~dp0"
echo.
echo === Pasta atual: %~dp0 ===
echo.
git commit --allow-empty -m "Trigger deploy Vercel"
git push
echo.
echo === Pronto! Verifique se apareceu "main -> main" acima ===
pause
