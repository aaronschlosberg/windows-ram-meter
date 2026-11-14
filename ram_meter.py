#!/usr/bin/env python3
"""
Simple RAM Meter - System Tray Utility
Shows RAM usage percentage in the system tray with a dial-like icon.
Hover for detailed tooltip. Right-click for menu: quit.
"""

import psutil
import pystray
from PIL import Image, ImageDraw
import threading
import time
import os
import subprocess

# Defaults
REFRESH_INTERVAL = 2.0
THRESHOLDS = (70, 90)  # green <70, yellow <90, red otherwise

def create_image(usage):
    image = Image.new('RGB', (64, 64), color=(30, 30, 30))
    draw = ImageDraw.Draw(image)
    
    draw.ellipse((4, 4, 60, 60), outline=(100, 100, 100), width=2)
    
    color = (0, 255, 0) if usage < THRESHOLDS[0] else (255, 165, 0) if usage < THRESHOLDS[1] else (255, 0, 0)
    angle = int(360 * usage / 100)
    draw.arc((8, 8, 56, 56), start=-90, end=-90 + angle, fill=color, width=6)
    
    text = f"{int(usage)}%"
    draw.text((20, 24), text, fill=(255, 255, 255))
    
    return image

def get_top_processes(n=3):
    procs = []
    for p in psutil.process_iter(['name', 'memory_info']):
        try:
            mem = p.info['memory_info'].rss / (1024 ** 2)  # MB
            procs.append((p.info['name'], mem))
        except (psutil.NoSuchProcess, psutil.AccessDenied):
            continue
    procs.sort(key=lambda x: x[1], reverse=True)
    return procs[:n]

def update_icon(icon):
    global REFRESH_INTERVAL
    while True:
        mem = psutil.virtual_memory()
        swap = psutil.swap_memory()
        usage = mem.percent
        used_gb = mem.used / (1024 ** 3)
        total_gb = mem.total / (1024 ** 3)
        avail_gb = mem.available / (1024 ** 3)
        swap_gb = swap.used / (1024 ** 3)
        
        icon.icon = create_image(usage)
        icon.title = f"RAM: {usage:.1f}% | {used_gb:.1f}/{total_gb:.1f} GB | Avail: {avail_gb:.1f} GB | Swap: {swap_gb:.1f} GB"
        time.sleep(REFRESH_INTERVAL)

def on_quit(icon, item):
    icon.stop()

def on_toggle_refresh(icon, item):
    global REFRESH_INTERVAL
    REFRESH_INTERVAL = 1.0 if REFRESH_INTERVAL > 1.0 else 2.0
    item.text = f"Refresh: {REFRESH_INTERVAL:.1f}s"

def on_open_taskmgr(icon, item):
    subprocess.Popen(['taskmgr.exe'])

def make_menu():
    top = get_top_processes(3)
    top_items = [pystray.MenuItem(f"{name}: {mem:.0f} MB", lambda icon, item: None) for name, mem in top]
    
    return pystray.Menu(
        pystray.MenuItem("Open Task Manager", on_open_taskmgr),
        pystray.Menu.SEPARATOR,
        pystray.MenuItem("Top Processes", pystray.Menu(*top_items)) if top_items else pystray.MenuItem("Top Processes", lambda i, it: None),
        pystray.Menu.SEPARATOR,
        pystray.MenuItem(f"Refresh: {REFRESH_INTERVAL:.1f}s", on_toggle_refresh),
        pystray.Menu.SEPARATOR,
        pystray.MenuItem("Quit", on_quit)
    )

def setup(icon):
    icon.visible = True
    icon.menu = make_menu()
    threading.Thread(target=update_icon, args=(icon,), daemon=True).start()

icon = pystray.Icon("RAM Meter", create_image(0), "RAM Meter", make_menu())
icon.run(setup)
