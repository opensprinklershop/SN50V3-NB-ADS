@echo off
rem Baut die NB-Firmware neu (ohne zu flashen). Danach flash_only.bat [COM-Port] ausfuehren.
rem Toolchain-Pfad steht im Makefile (PREFIX). Benoetigt make (mingw32-make oder msys2 make) im PATH.
setlocal
cd /d "%~dp0"
set MAKE=mingw32-make
where %MAKE% >nul 2>nul
if errorlevel 1 set MAKE=make
where %MAKE% >nul 2>nul
if errorlevel 1 (
  if exist "C:\msys64\usr\bin\make.exe" (set MAKE=C:\msys64\usr\bin\make.exe) else (echo FEHLER: make nicht gefunden. & pause & exit /b 1)
)
set BIN=build\NBSN95.bin
echo === Baue Firmware ===
rem Nur Objektdateien loeschen (make clean wuerde das ganze build-Verzeichnis inkl. Hilfs-Binaries entfernen)
del /q build\*.o >nul 2>nul
"%MAKE%" -j4
if errorlevel 1 (echo. & echo BUILD FEHLGESCHLAGEN - Fehlermeldungen oben pruefen. & pause & exit /b 1)
if not exist "%BIN%" (echo. & echo BUILD FEHLGESCHLAGEN - %BIN% wurde nicht erzeugt. & pause & exit /b 1)
for %%A in ("%BIN%") do echo.& echo Binary: %BIN%  (%%~zA Bytes)
findstr /m /c:"SMT50 mode" "%BIN%" >nul
if errorlevel 1 (echo WARNUNG: AT+SMT50 ist im Binary nicht enthalten.) else (echo OK: AT+SMT50 ist im Binary enthalten.)
echo.
echo FERTIG. Jetzt flash_only.bat COM6 ausfuehren.
pause
