@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul
cd /d "%~dp0" || exit /b 1
set "PYTHONUTF8=1"
set "PATH=%CD%\.venv\Scripts;%PATH%"

if not exist ".venv\Scripts\python.exe" (
    echo Before start please run windows_build.cmd for buiding.
    pause
    exit /b 1
)

echo Start Fly Wirehead. Ctrl+C will save brain state and terminate session.
".venv\Scripts\python.exe" -m flywirehead run %*
set "result=%errorlevel%"
if not "%result%"=="0" pause
exit /b %result%
