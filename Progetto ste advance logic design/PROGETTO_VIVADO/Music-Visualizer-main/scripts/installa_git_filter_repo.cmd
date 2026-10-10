@echo off
REM === Installa git-filter-repo su Windows usando pip ===

REM 1. Controlla se Python è installato
python --version >nul 2>&1
IF ERRORLEVEL 1 (
    echo Python non trovato. Installalo da https://www.python.org/downloads/ e riprova.
    pause
    exit /b 1
)

REM 2. Aggiorna pip
python -m pip install --upgrade pip

REM 3. Installa git-filter-repo
pip install git-filter-repo

REM 4. Mostra versione installata
echo.
echo Installazione completata. Versione:
git filter-repo --version

pause
