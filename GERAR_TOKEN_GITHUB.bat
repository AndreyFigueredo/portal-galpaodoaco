@echo off
echo.
echo ============================================================
echo   CONFIGURAR TOKEN GITHUB - PORTAL GALVAO DO ACO
echo ============================================================
echo.
echo Vou abrir o navegador na pagina de criacao do token.
echo.
echo Siga os passos:
echo  1. Clique em "Generate new token (classic)"
echo  2. Em "Note" escreva: Portal Galpao do Aco
echo  3. Expiration: "No expiration"
echo  4. Selecione APENAS: [x] public_repo
echo  5. Clique "Generate token" no final da pagina
echo  6. COPIE o token (comeca com ghp_...)
echo  7. Cole no portal quando solicitado
echo.
echo Abrindo navegador...
start "" "https://github.com/settings/tokens/new?scopes=public_repo&description=Portal+Galpao+do+Aco"
echo.
echo Apos gerar o token, abra o portal e clique em:
echo "Assistencias" -> "Configurar Token"
echo.
pause
