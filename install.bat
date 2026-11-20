@echo off
setlocal enabledelayedexpansion

echo ========================================
echo   Windows RAM Meter - Installer
echo ========================================
echo.

REM --- Find Python ---
set "PYTHON="
set "PYTHONW="

REM Try PATH first
where python >nul 2>&1 && set "PYTHON=python" && set "PYTHONW=pythonw"
if defined PYTHON goto :found

REM Common install locations
for %%P in (
    "%LocalAppData%\Programs\Python\Python313\python.exe"
    "%LocalAppData%\Programs\Python\Python312\python.exe"
    "%LocalAppData%\Programs\Python\Python311\python.exe"
    "%LocalAppData%\Programs\Python\Python310\python.exe"
    "%ProgramFiles%\Python313\python.exe"
    "%ProgramFiles%\Python312\python.exe"
    "%ProgramFiles%\Python311\python.exe"
    "%ProgramFiles%\Python310\python.exe"
    "%ProgramFiles(x86)%\Python313\python.exe"
    "%ProgramFiles(x86)%\Python312\python.exe"
) do (
    if exist %%P (
        set "PYTHON=%%P"
        set "PYTHONW=%%~dpPpythonw.exe"
        goto :found
    )
)

echo Python was not found in PATH or common install locations.
echo.
echo Please install Python 3.10+ from:
echo https://www.python.org/downloads/
echo.
echo IMPORTANT: Check the box "Add python.exe to PATH" during install.
echo Then close this window, reopen it, and run install.bat again.
echo.
pause
exit /b 1

:found
echo Found Python: !PYTHON!
echo.

echo Installing dependencies (psutil, pystray, pillow)...
"!PYTHON!" -m pip install --upgrade pip
"!PYTHON!" -m pip install -r requirements.txt
if errorlevel 1 (
    echo.
    echo Failed to install packages.
    pause
    exit /b 1
)

echo.
echo Creating Startup shortcut (no console window)...
set "SCRIPT_DIR=%~dp0"
set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

powershell -NoProfile -Command ^
  "$ws = New-Object -ComObject WScript.Shell; " ^
  "$s = $ws.CreateShortcut([Environment]::GetFolderPath('Startup') + '\RAM Meter.lnk'); " ^
  "$s.TargetPath = '!PYTHONW!'; " ^
  "$s.Arguments = '\"%SCRIPT_DIR%\ram_meter.py\"'; " ^
  "$s.WorkingDirectory = '%SCRIPT_DIR%'; " ^
  "$s.Save()"

echo.
echo ========================================
echo   Done.
echo ========================================
echo The RAM Meter will start automatically on next login.
echo You can also run it now with:
echo   "!PYTHONW!" "%SCRIPT_DIR%\ram_meter.py"
echo.
pause
