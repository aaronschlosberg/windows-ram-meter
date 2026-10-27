@echo off
echo Installing Windows RAM Meter dependencies...
pip install -r requirements.txt
if errorlevel 1 (
    echo Failed to install packages. Make sure Python is in PATH.
    pause
    exit /b 1
)

echo.
echo Creating Startup shortcut (runs with pythonw, no console)...
set SCRIPT_DIR=%~dp0
set PYW=%SystemRoot%\pyw.exe
if not exist "%PYW%" set PYW=pythonw.exe

powershell -Command "$s=(New-Object -COM WScript.Shell).CreateShortcut('%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup\RAM Meter.lnk'); $s.TargetPath='%PYW%'; $s.Arguments='\"%SCRIPT_DIR%ram_meter.py\"'; $s.WorkingDirectory='%SCRIPT_DIR%'; $s.Save()"

echo.
echo Done. The meter will start automatically on next login.
echo You can also run it now with: pythonw ram_meter.py
pause
