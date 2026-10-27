# Windows RAM Meter

Simple system tray RAM usage meter for Windows. Shows a dial icon with percentage (green <70%, yellow <90%, red otherwise). Updates every 2 seconds. Right-click tray icon to quit.

## Requirements
- Windows
- Python 3.10+ (with PATH enabled during install)

## Quick Install & Run (no console window)

1. Install Python if needed: https://www.python.org/downloads/ (check "Add to PATH")
2. Open Command Prompt in this folder and run:
   ```
   pip install -r requirements.txt
   ```
3. To run without a console window (recommended):
   ```
   pythonw ram_meter.py
   ```
4. To start automatically on login:
   - Press Win+R, type `shell:startup`, Enter
   - Create a shortcut to `pythonw.exe` with argument `full\path\to\ram_meter.py`
   - Or use the `install.bat` below

## install.bat (optional helper)

Run `install.bat` as administrator once. It installs packages and creates a Startup shortcut that launches with `pythonw` (no console).

## Manual run
`python ram_meter.py` (shows console — closing it stops the meter)

Drag the icon out of the tray overflow (^) onto the taskbar to keep it visible.
