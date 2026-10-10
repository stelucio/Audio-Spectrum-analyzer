@echo off
setlocal

:: CONFIGURAZIONE PERCORSI - PERCORSO ASSOLUTO COMPILER (Configurato per il tuo sistema)
set GCC_PATH=C:\riscv-gcc\xpack-riscv-none-elf-gcc-15.2.0-1\bin
set TOOLCHAIN_PREFIX=riscv-none-elf-

:: Comandi con percorso assoluto
set CC="%GCC_PATH%\%TOOLCHAIN_PREFIX%gcc.exe"
set OBJCOPY="%GCC_PATH%\%TOOLCHAIN_PREFIX%objcopy.exe"

echo [1/3] Compilazione C (RISC-V RV32I)...
%CC% -march=rv32i -mabi=ilp32 -T link.ld -nostartfiles -o main.elf crt0.S main.c
if %errorlevel% neq 0 (
    echo [ERRORE] Errore di compilazione! Controlla il codice C o il percorso del compilatore.
    goto :error
)

echo [2/3] Generazione file .mem...
:: Usiamo lo script Python passando il percorso di OBJCOPY
python elf2mem.py main.elf program.mem %OBJCOPY%
if %errorlevel% neq 0 (
    echo [ERRORE] Errore nella generazione del file .mem!
    goto :error
)

echo [3/3] Aggiornamento simulazione Vivado...
:: Cerchiamo la cartella xsim dinamicamente nel progetto
set VIVADO_SIM_DIR=
for /d /r "..\.." %%d in (xsim) do (
    if exist "%%d\elaborate.log" (
        set VIVADO_SIM_DIR=%%d
        goto :found_dir
    )
)

echo [ATTENZIONE] Non ho trovato la cartella di simulazione attiva di Vivado.
echo Assicurati di aver avviato la simulazione almeno una volta in Vivado.
echo Il file program.mem e' stato comunque generato nella cartella corrente.
goto :done

:found_dir
echo Cartella trovata: %VIVADO_SIM_DIR%
copy /Y program.mem "%VIVADO_SIM_DIR%\program.mem" > nul
if %errorlevel% neq 0 (
    echo [ERRORE] Impossibile copiare il file in Vivado. Forse la simulazione e' bloccata?
    goto :error
)
echo [OK] File program.mem aggiornato in Vivado.

:: FORZA RE-ELABORATION IN VIVADO
:: Aggiorniamo la data di modifica del testbench cosi' Vivado lo ricompila
copy /b "..\..\Music-Visualizer\Music-Visualizer.srcs\sim_1\imports\Music-Visualizer\tb_cpu.vhd" +,, > nul
echo [OK] Testbench "toccato" per forzare il ricaricamento.

:done
echo.

echo === FLUSSO COMPLETATO CON SUCCESSO ===
echo Torna su Vivado e clicca su "Relaunch Simulation".
echo.
pause
exit /b 0

:error
echo.

echo !!! IL PROCESSO E' FALLITO !!!
pause
exit /b 1
