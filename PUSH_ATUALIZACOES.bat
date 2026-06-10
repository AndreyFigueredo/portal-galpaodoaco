@echo off
cd /d "%~dp0"
echo.
echo === Publicando atualizacoes no portal ===
echo.
git push
echo.
echo === Pronto! Aguarde ~30s e acesse portal-galpaodoaco.vercel.app ===
echo.
pause
