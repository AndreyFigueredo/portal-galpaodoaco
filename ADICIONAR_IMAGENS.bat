@echo off
cd /d "%~dp0"
echo.
echo === ADICIONANDO IMAGENS AO PORTAL ===
echo.

REM Verifica imagens novas (nao rastreadas pelo git)
echo Verificando imagens que ainda nao estao no portal...
git ls-files --others --exclude-standard imagens\ > "%TEMP%\imgs_novas.txt" 2>nul

REM Conta quantas sao
set count=0
for /f %%A in ('type "%TEMP%\imgs_novas.txt" ^| find /c /v ""') do set count=%%A

if %count%==0 (
    echo.
    echo Nenhuma imagem nova encontrada. Tudo ja esta atualizado!
    echo.
    goto FIM
)

echo.
echo Encontradas %count% imagem(ns) nova(s). Adicionando...
echo.

REM Adiciona so as novas
for /f "usebackq delims=" %%f in ("%TEMP%\imgs_novas.txt") do (
    echo   + %%f
    git add "%%f"
)

git commit -m "Adicionar %count% imagem(ns) nova(s)"
git push

echo.
echo === Pronto! %count% imagem(ns) enviada(s) ao portal ===

:FIM
del "%TEMP%\imgs_novas.txt" 2>nul
pause
