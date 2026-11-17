@echo off
rem Flasht die bereits gebaute Firmware (build\NBSN95.bin) ohne Neubau auf den SN50V3-NB (STM32L072).
rem Aufruf: flash_only.bat [COM-Port]   (Standard: COM6)
rem Adresse 0x08007800 = Applikation hinter dem Dragino-Bootloader (NICHT 0x08000000!)
setlocal
cd /d "%~dp0"
set PORT=%1
if "%PORT%"=="" set PORT=COM6
set CLI=%LOCALAPPDATA%\stm32cube\bundles\programmer\2.20.0\bin\STM32_Programmer_CLI.exe
set BIN=build\NBSN95.bin
if not exist "%CLI%" (echo FEHLER: STM32_Programmer_CLI nicht gefunden: %CLI% & pause & exit /b 1)
if not exist "%BIN%" (echo FEHLER: %BIN% nicht gefunden. & pause & exit /b 1)
echo.
echo  1. SW1 auf dem Board auf ISP schieben
echo  2. USB-Kabel abziehen und wieder einstecken (Reset allein reicht nicht)
echo  3. Alle Programme schliessen, die %PORT% benutzen (Putty, Dragino Utility, ...)
echo.
pause
"%CLI%" -c port=%PORT% br=115200 parity=EVEN -d "%BIN%" 0x08007800 -v
if errorlevel 1 (echo. & echo FLASHEN FEHLGESCHLAGEN - ISP-Schalter, USB neu stecken und %PORT% pruefen.) else (echo. & echo FERTIG. SW1 zurueck auf Normal schieben, USB neu stecken.)
pause
