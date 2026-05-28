@echo off
setlocal enabledelayedexpansion
title Portal Galpao do Aco - Atualizar
cd /d "%~dp0"

echo.
echo ============================================================
echo   ATUALIZACAO DO PORTAL - GALPAO DO ACO
echo ============================================================
echo.

:: ── Verificar Python ────────────────────────────────────────
set "PYTHON="
for %%P in (py python python3) do (
    if not defined PYTHON (
        where %%P >nul 2>&1
        if not errorlevel 1 set "PYTHON=%%P"
    )
)
if not defined PYTHON (
    echo ERRO: Python nao encontrado!
    pause & exit /b 1
)

:: ── PASSO 1: Gerar dados e copiar imagens ───────────────────
echo [1/3] Exportando dados e imagens do ERP...
echo.
%PYTHON% "..\data\export_portal.py" --auto
if errorlevel 1 (
    echo.
    echo ERRO na exportacao. Certifique-se de rodar run.bat antes.
    pause & exit /b 1
)

:: ── PASSO 2: Adicionar arquivos ao git ──────────────────────
echo.
echo [2/3] Preparando envio para o GitHub...

:: Dados atualizados
git add portal_data.json imagens_drive.json

:: Imagens: adicionar novas E remover deletadas (git add -A rastreia tudo)
echo   Sincronizando imagens (novas + removidas)...
git add -A imagens\

:: ── PASSO 3: Commit e push (somente se houver mudancas) ──────
echo.
echo [3/3] Publicando no portal...

git diff --cached --quiet
if errorlevel 1 (
    for /f "tokens=2-4 delims=/ " %%a in ('date /t') do set dt=%%c-%%b-%%a
    for /f "tokens=1 delims=: " %%a in ('time /t') do set hr=%%a
    git commit -m "Atualizar portal %dt% %hr%h (%imgcount% img nova(s))"
    git push

    echo.
    echo ============================================================
    echo   PORTAL ATUALIZADO! Deploy iniciado no Vercel.
    echo   Aguarde ~30 segundos e acesse:
    echo   https://portal-galpaodoaco.vercel.app
    echo ============================================================
) else (
    echo.
    echo   Nenhuma mudanca detectada. Portal ja esta atualizado.
)

echo.
pause
