#!/usr/bin/env python3
"""
Helper script to list available COM ports on Windows.
Run this to find the correct port for your USB device.
"""

import sys

try:
    import serial.tools.list_ports
    print("Available COM Ports:")
    print("=" * 50)
    ports = serial.tools.list_ports.comports()
    
    if not ports:
        print("No COM ports found.")
        print("\nNote: Android phones don't create COM ports by default.")
        print("For Android devices, use ADB method instead:")
        print("  python pc_receiver.py --method adb")
    else:
        for port in ports:
            print(f"Port: {port.device}")
            print(f"  Description: {port.description}")
            print(f"  Hardware ID: {port.hwid}")
            print()
except ImportError:
    print("Error: pyserial not installed.")
    print("Install with: pip install pyserial")
    sys.exit(1)

