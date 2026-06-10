@echo off
echo Iniciando deploy...
PowerShell -NoProfile -ExecutionPolicy Bypass -File "%~dp0DEPLOY_PS.ps1"
pause
