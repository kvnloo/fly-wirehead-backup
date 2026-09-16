@echo off
setlocal EnableExtensions DisableDelayedExpansion
chcp 65001 >nul
cd /d "%~dp0" || exit /b 1
set "PYTHONUTF8=1"
set "FLYWIREHEAD_DATA=%CD%\data"
set "PATH=%CD%\.venv\Scripts;%USERPROFILE%\.local\bin;%LOCALAPPDATA%\Microsoft\WinGet\Links;%PATH%;%ProgramFiles%\nodejs;%LOCALAPPDATA%\Programs\nodejs"

echo [1/5] Checking for uv, FFmpeg и Node.js...
where uv.exe >nul 2>&1
if errorlevel 1 call :install astral-sh.uv --scope user
if errorlevel 1 goto :failed
where uv.exe >nul 2>&1
if errorlevel 1 goto :failed

call :find_ffmpeg
call :check_ffmpeg
if errorlevel 1 call :install Gyan.FFmpeg --scope user
if errorlevel 1 goto :failed
call :find_ffmpeg
call :check_ffmpeg
if errorlevel 1 goto :failed

node.exe -e "process.exit(Number(process.versions.node.split('.')[0]) >= 22 ? 0 : 1)" >nul 2>&1
if errorlevel 1 call :install OpenJS.NodeJS.LTS
if errorlevel 1 goto :failed
node.exe -e "process.exit(Number(process.versions.node.split('.')[0]) >= 22 ? 0 : 1)" >nul 2>&1
if errorlevel 1 goto :failed

echo [2/5] Prepare Python 3.12 and uv.lock dependencies...
uv.exe sync --locked --python 3.12 --extra windows --inexact
if errorlevel 1 goto :failed

echo [3/5] Build neural core...
".venv\Scripts\python.exe" -c "from flywirehead.neural.brain import build; build()"
if errorlevel 1 goto :failed

echo [4/5] Prepare and check prepare model...
".venv\Scripts\python.exe" -m flywirehead prepare
if errorlevel 1 goto :failed

echo [5/5] Download videos feed...
".venv\Scripts\python.exe" scripts\download_videos.py
if errorlevel 1 goto :failed

echo.
echo Done. Run windows_start.cmd for start.
pause
exit /b 0

:install
where winget.exe >nul 2>&1
if errorlevel 1 (
    echo WinGet was not found. Please install uv, FFmpeg and Node.js 22+ manually. See README.md.
    exit /b 1
)
echo Installing %1 via WinGet...
winget.exe install --id %1 --exact --source winget %2 %3
exit /b %errorlevel%

:find_ffmpeg
for /d %%G in ("%LOCALAPPDATA%\Microsoft\WinGet\Packages\Gyan.FFmpeg_*") do for /d %%F in ("%%~fG\ffmpeg-*") do if exist "%%~fF\bin\ffmpeg.exe" set "PATH=%%~fF\bin;%PATH%"
exit /b 0

:check_ffmpeg
ffmpeg.exe -version >nul 2>&1
if errorlevel 1 exit /b 1
ffprobe.exe -version >nul 2>&1
exit /b %errorlevel%

:failed
set "result=%errorlevel%"
echo.
echo Build failed, error code: %result%. Please, try again.
pause
exit /b %result%
