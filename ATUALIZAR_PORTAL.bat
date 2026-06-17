@echo off
setlocal enabledelayedexpansion
title Portal Galpao do Aco - Atualizacao Completa
color 0A

echo.
echo ============================================================
echo   ATUALIZACAO COMPLETA DO PORTAL - GALPAO DO ACO
echo   1. Exportar dados (pre-notas + imagens)
echo   2. Verificar fornecedores das pre-notas
echo   3. Publicar no Vercel via Git
echo ============================================================
echo.

cd /d "%~dp0"

:: ── Verificar Python ──────────────────────────────────────────
set "PYTHON="
where py     >nul 2>&1 && set "PYTHON=py"     && goto :py_ok
where python >nul 2>&1 && set "PYTHON=python" && goto :py_ok
where python3>nul 2>&1 && set "PYTHON=python3"&& goto :py_ok
echo ERRO: Python nao encontrado!
pause & exit /b 1
:py_ok
echo Python encontrado: %PYTHON%

:: ── PASSO 1: Buscar dados frescos do CISS ─────────────────────
echo.
echo [1/4] Buscando pre-notas atualizadas do CISS (DB2)...
echo --------------------------------------------------------
%PYTHON% "%~dp0..\data\extract.py"
if errorlevel 1 (
    echo.
    echo  AVISO: Erro na extracao do banco. Continuando com dados existentes...
)

echo.
echo [2/4] Processando dados...
echo --------------------------------------------------------
%PYTHON% "%~dp0..\data\process.py"
if errorlevel 1 (
    echo.
    echo  ERRO no processamento!
    pause & exit /b 1
)

:: ── PASSO 2: Exportar portal_data.json + copiar imagens ───────
echo.
echo [3/4] Exportando para o portal (portal_data.json + imagens)...
echo --------------------------------------------------------
%PYTHON% "%~dp0..\data\export_portal.py" --auto
if errorlevel 1 (
    echo.
    echo  ERRO na exportacao!
    pause & exit /b 1
)

:: ── PASSO 3: Verificar fornecedores das pre-notas ─────────────
echo.
echo [verificacao] Fornecedores das pre-notas geradas...
echo --------------------------------------------------------
%PYTHON% -c "
import json, os
portal = os.path.join(os.path.dirname(os.path.abspath('%~f0'.replace('\\\\','/'))), 'portal_data.json')

try:
    with open(portal, 'r', encoding='utf-8') as f:
        data = json.load(f)
except Exception as e:
    print('  AVISO: nao foi possivel ler portal_data.json:', e)
    exit(0)

itens = data.get('prenota_detalhes', [])
if not itens:
    print('  Nenhuma pre-nota encontrada no arquivo.')
    exit(0)

# Agrupar por fornecedor
forn = {}
for it in itens:
    nome = (it.get('nome_fornecedor') or '').strip() or '(SEM NOME)'
    idc  = it.get('idclifor')
    chave = nome
    if chave not in forn:
        forn[chave] = {'idclifor': idc, 'notas': set(), 'itens': 0}
    nf = it.get('num_nf')
    if nf:
        forn[chave]['notas'].add(nf)
    forn[chave]['itens'] += 1

print(f'  Total de itens    : {len(itens)}')
print(f'  Total fornecedores: {len(forn)}')
print()
print('  FORNECEDOR                                    | ID     | NFs | Itens')
print('  ' + '-'*72)
for nome, v in sorted(forn.items()):
    idc  = str(v['idclifor'] or '-')
    nfs  = len(v['notas'])
    its  = v['itens']
    aviso = ' << SEM NOME' if nome == '(SEM NOME)' else ''
    print(f'  {nome[:44]:<44} | {idc:<6} | {nfs:<3} | {its}{aviso}')
" 2>&1

echo.
echo  Se aparecer fornecedores com nome errado, avise para corrigir o alias.

:: ── PASSO 3: Git add + commit + push ──────────────────────────
echo.
echo [publicar] Publicando no Vercel via Git...
echo --------------------------------------------------------

:: Verificar se ha algo para commitar
git status --short > "%TEMP%\_portal_git_status.txt" 2>&1
set /p GIT_STATUS=<"%TEMP%\_portal_git_status.txt"
del "%TEMP%\_portal_git_status.txt" 2>nul

git add -A

:: Contar arquivos staged
for /f %%C in ('git diff --cached --name-only ^| find /c /v ""') do set STAGED=%%C

if "%STAGED%"=="0" (
    echo.
    echo  Nenhuma alteracao detectada. Portal ja esta atualizado!
    goto :fim
)

echo  %STAGED% arquivo(s) para publicar...

:: Data/hora para mensagem do commit
for /f "tokens=1-5 delims=/ " %%a in ('echo %DATE%') do (
    set DIA=%%c
    set MES=%%b
    set ANO=%%d
)
for /f "tokens=1-2 delims=:." %%a in ('echo %TIME%') do (
    set HH=%%a
    set MM=%%b
)
set "MSG=Atualizar portal %DIA%/%MES%/%ANO% %HH%:%MM%"

git commit -m "%MSG%"
if errorlevel 1 (
    echo  ERRO no commit!
    pause & exit /b 1
)

git push
if errorlevel 1 (
    echo.
    echo  ERRO no push! Verifique sua conexao e tente novamente.
    pause & exit /b 1
)

:fim
echo.
echo ============================================================
echo  CONCLUIDO! Aguarde ~1 minuto e acesse:
echo  https://portal-galpaodoaco.vercel.app/
echo ============================================================
echo.
pause
