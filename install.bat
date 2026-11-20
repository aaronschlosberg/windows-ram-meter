@echo off
setlocal enabledelayedexpansion

echo ========================================
echo   Windows RAM Meter - Installer
echo ========================================
echo.

REM --- Find real Python (skip Microsoft Store stub) ---
set "PYTHON="
set "PYTHONW="

REM Check common real install locations first
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
    if exist "%%~P" (
        set "PYTHON=%%~P"
        set "PYTHONW=%%~dpPpythonw.exe"
        goto :found
    )
)

REM Fallback: try py launcher (often works even when python doesn't)
where py >nul 2>&1
if not errorlevel 1 (
    for /f "delims=" %%V in ('py -3 -c "import sys; print(sys.executable)" 2^>nul') do (
        set "PYTHON=%%V"
        set "PYTHONW=%%~dpVpythonw.exe"
        goto :found
    )
)

echo Real Python was not found.
echo.
echo The error you saw is usually the Microsoft Store alias.
echo.
echo Fix options:
echo 1. Install Python from https://www.python.org/downloads/
echo    (check "Add python.exe to PATH" during install)
echo.
echo 2. Or disable the Store aliases:
echo    Settings ^> Apps ^> Advanced app settings ^> App execution aliases
echo    Turn OFF "python.exe" and "python3.exe"
echo.
pause
exit /b 1

:found
echo Found Python: !PYTHON!
echo.

echo Installing dependencies...
"!PYTHON!" -m pip install --upgrade pip -q
"!PYTHON!" -m pip install -r requirements.txt
if errorlevel 1 (
    echo.
    echo Failed to install packages.
    pause
    exit /b 1
)

echo.
echo Creating Startup shortcut...
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
echo RAM Meter will start on next login.
echo Run now with:
echo   "!PYTHONW!" "%SCRIPT_DIR%\ram_meter.py"
echo.
pause
