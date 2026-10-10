@echo off
echo =========================================
echo  Reset simulazione Vivado - Music-Visualizer
echo =========================================

taskkill /F /IM xsim.exe   >nul 2>&1
taskkill /F /IM xelab.exe  >nul 2>&1
taskkill /F /IM xvlog.exe  >nul 2>&1

:: Utilizziamo il percorso relativo al progetto corrente
set SIM_DIR="C:\FPGA\Music-Visualizer\Music-Visualizer\Music-Visualizer.sim\sim_1\behav\xsim"
echo %SIM_DIR%
if exist "%SIM_DIR%" (
    rmdir /S /Q "%SIM_DIR%"
    echo Cartella eliminata.
) else (
    echo Nessuna cartella da eliminare.
)

echo Reset completato.
pause
