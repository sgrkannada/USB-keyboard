#!/usr/bin/env python3
"""
Helper script to check ADB connection and device status.
"""

import subprocess
import sys
import shutil
import os

def find_adb():
    """Find ADB executable."""
    adb = shutil.which('adb')
    if adb:
        return adb
    # Common ADB locations
    possible_paths = [
        os.path.join(os.environ.get('ANDROID_HOME', ''), 'platform-tools', 'adb.exe' if sys.platform == 'win32' else 'adb'),
        os.path.join(os.environ.get('ANDROID_SDK_ROOT', ''), 'platform-tools', 'adb.exe' if sys.platform == 'win32' else 'adb'),
        'adb.exe' if sys.platform == 'win32' else 'adb',
    ]
    for path in possible_paths:
        if os.path.exists(path):
            return path
    return 'adb.exe' if sys.platform == 'win32' else 'adb'

def main():
    print("ADB Connection Checker")
    print("=" * 50)
    
    adb_path = find_adb()
    print(f"ADB Path: {adb_path}")
    
    # Check if ADB exists
    if not shutil.which(adb_path) and not os.path.exists(adb_path):
        print("\n[ERROR] ADB not found!")
        print("\nPlease install ADB:")
        print("  1. Download Android Platform Tools:")
        print("     https://developer.android.com/studio/releases/platform-tools")
        print("  2. Extract and add to PATH")
        print("  3. Or place adb.exe in this folder")
        return
    
    print("[OK] ADB found")
    
    # Check devices
    try:
        result = subprocess.run(
            [adb_path, 'devices'],
            capture_output=True,
            text=True,
            timeout=5
        )
        
        print("\nConnected Devices:")
        print("-" * 50)
        lines = result.stdout.strip().split('\n')
        if len(lines) <= 1:
            print("[ERROR] No devices connected")
            print("\nMake sure:")
            print("  1. USB debugging is enabled on your phone")
            print("  2. Phone is connected via USB")
            print("  3. You've authorized the computer")
        else:
            for line in lines[1:]:
                if line.strip():
                    parts = line.split('\t')
                    device_id = parts[0] if len(parts) > 0 else line
                    status = parts[1] if len(parts) > 1 else 'unknown'
                    if 'device' in status:
                        print(f"[OK] {device_id} - {status}")
                    else:
                        print(f"[WARN] {device_id} - {status}")
        
        print("\n" + "=" * 50)
        print("If device is connected, you can use:")
        print("  python pc_receiver.py --method adb")
        
    except Exception as e:
        print(f"\n[ERROR] Error checking devices: {e}")

if __name__ == '__main__':
    main()

