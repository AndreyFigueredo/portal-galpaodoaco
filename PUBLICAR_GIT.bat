@echo off
title Publicar Portal - Git Push
color 0B
cd /d "%~dp0"

echo.
echo ============================================================
echo   PUBLICAR portal_data.json no GitHub / Vercel
echo ============================================================
echo.

:: Restaurar imagens deletadas acidentalmente
git checkout -- imagens/ 2>nul

:: Adicionar arquivos de dados
echo Adicionando portal_data.json...
git add portal_data.json
if errorlevel 1 (
    echo ERRO ao adicionar portal_data.json!
    pause & exit /b 1
)

git add imagens_drive.json 2>nul

:: Adicionar imagens novas (sem deletar as existentes)
git add --ignore-removal imagens/ 2>nul

:: Mostrar o que vai ser commitado
echo.
echo Arquivos staged:
git diff --cached --name-only

:: Commit
echo.
echo Fazendo commit...
git commit -m "Atualizar dados portal %DATE% %TIME%"
if errorlevel 1 (
    echo.
    echo  Nada novo para commitar - portal ja esta atualizado.
    pause & exit /b 0
)

:: Push
echo.
echo Enviando para GitHub / Vercel...
git push
if errorlevel 1 (
    echo.
    echo  ERRO no push! Verifique sua conexao com a internet.
    pause & exit /b 1
)

echo.
echo ============================================================
echo  PUBLICADO! Aguarde ~1 minuto e acesse:
echo  https://portal-galpaodoaco.vercel.app/
echo ============================================================
echo.
pause
