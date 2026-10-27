#!/usr/bin/env python3
"""
Simple RAM Meter - System Tray Utility
Shows RAM usage percentage in the system tray with a dial-like icon.
Right-click for menu: refresh, quit.
"""

import psutil
import pystray
from PIL import Image, ImageDraw
import threading
import time

def create_image(usage):
    # Create a 64x64 image with a simple dial/arc for RAM usage
    image = Image.new('RGB', (64, 64), color=(30, 30, 30))
    draw = ImageDraw.Draw(image)
    
    # Background circle
    draw.ellipse((4, 4, 60, 60), outline=(100, 100, 100), width=2)
    
    # Usage arc (green to red)
    color = (0, 255, 0) if usage < 70 else (255, 165, 0) if usage < 90 else (255, 0, 0)
    # Draw arc based on usage (0-360 degrees, starting from top)
    angle = int(360 * usage / 100)
    draw.arc((8, 8, 56, 56), start=-90, end=-90 + angle, fill=color, width=6)
    
    # Percentage text
    text = f"{int(usage)}%"
    # Approximate text position
    draw.text((20, 24), text, fill=(255, 255, 255))
    
    return image

def update_icon(icon):
    while True:
        usage = psutil.virtual_memory().percent
        icon.icon = create_image(usage)
        icon.title = f"RAM: {usage:.1f}%"
        time.sleep(2)

def on_quit(icon, item):
    icon.stop()

def setup(icon):
    icon.visible = True
    threading.Thread(target=update_icon, args=(icon,), daemon=True).start()

menu = pystray.Menu(
    pystray.MenuItem("Quit", on_quit)
)

icon = pystray.Icon("RAM Meter", create_image(0), "RAM Meter", menu)
icon.run(setup)
