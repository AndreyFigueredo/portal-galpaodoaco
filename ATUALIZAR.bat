@echo off
setlocal enabledelayedexpansion
title Portal Galvao do Aco - Atualizar Dados

echo ============================================================
echo   ATUALIZACAO DO PORTAL ONLINE - GALPAO DO ACO
echo ============================================================
echo.
echo  Este script:
echo  1. Le os dados mais recentes do CISS (processed.json)
echo  2. Copia as imagens dos produtos em transito e pedidos
echo  3. Faz o deploy automatico no Vercel
echo.

cd /d "%~dp0"

:: ── Verificar Python ─────────────────────────────────────────
set "PYTHON="
where py >nul 2>&1
if not errorlevel 1 ( set "PYTHON=py" & goto :py_ok )
where python >nul 2>&1
if not errorlevel 1 ( set "PYTHON=python" & goto :py_ok )
where python3 >nul 2>&1
if not errorlevel 1 ( set "PYTHON=python3" & goto :py_ok )

echo ERRO: Python nao encontrado!
pause & exit /b 1

:py_ok
echo Python: %PYTHON%

:: ── Gerar portal_data.json via export_portal.py ──────────────
echo.
echo [1/3] Exportando dados mais recentes...

%PYTHON% "%~dp0..\data\export_portal.py" --auto

if errorlevel 1 (
    echo.
    echo ERRO na exportacao. Verifique se o run.bat foi executado antes.
    pause
    exit /b 1
)

echo.
echo [2/3] Verificando Vercel CLI...
where vercel >nul 2>&1
if errorlevel 1 (
    echo Instalando Vercel CLI...
    npm install -g vercel
)

echo.
echo [3/3] Fazendo deploy no Vercel...
vercel --prod --yes

if errorlevel 1 (
    echo ERRO no deploy!
    pause
    exit /b 1
)

echo.
echo ============================================================
echo  PORTAL ATUALIZADO COM SUCESSO!
echo ============================================================
echo.
timeout /t 5 /nobreak >nul
