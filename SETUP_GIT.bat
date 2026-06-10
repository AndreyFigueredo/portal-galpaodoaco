@echo off
cd /d "%~dp0"
echo.
echo === Inicializando git na pasta: %~dp0 ===
echo.

git init -b main
git config user.email "andreyfigueredop@gmail.com"
git config user.name "AndreyFigueredo"

git add index.html vercel.json portal_data.json imagens_drive.json
git commit -m "Portal Galpao do Aco - versao inicial (design marketplace)"

git remote add origin https://github.com/AndreyFigueredo/portal-galpaodoaco.git
git push -u origin main

echo.
echo === Concluido! Verifique se apareceu "main -> main" acima ===
pause
