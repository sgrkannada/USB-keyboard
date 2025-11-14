#!/usr/bin/env python3
"""
PC-side receiver for USB Keyboard app.
This script receives keyboard input from the phone via ADB port forwarding
and simulates keyboard input on the PC in real-time.

Requirements:
    pip install pynput

Usage:
    python pc_receiver.py --method adb
"""

import argparse
import sys
import time
import socket
import subprocess
import threading
from pynput import keyboard
from pynput.keyboard import Key, Controller


class KeyboardSimulator:
    def __init__(self):
        self.keyboard_controller = Controller()
        self.special_keys = {
            'BACKSPACE': Key.backspace,
            'ENTER': Key.enter,
            'SPACE': Key.space,
            'TAB': Key.tab,
            '\b': Key.backspace,
            '\n': Key.enter,
            '\t': Key.tab,
            ' ': Key.space,
        }

    def send_key(self, key_char):
        """Send a single key press to the system."""
        try:
            if key_char in self.special_keys:
                self.keyboard_controller.press(self.special_keys[key_char])
                self.keyboard_controller.release(self.special_keys[key_char])
            else:
                self.keyboard_controller.type(key_char)
            return True
        except Exception as e:
            print(f"Error sending key '{key_char}': {e}")
            return False


class AdbReceiver:
    def __init__(self):
        self.adb_path = self._find_adb()
        self.forward_port = 12345  # Fixed port for all connections
        self.server_socket = None
        self.client_socket = None

    def _find_adb(self):
        """Find ADB executable."""
        import shutil
        import os
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

    def check_connection(self):
        """Check if device is connected via ADB."""
        try:
            result = subprocess.run(
                [self.adb_path, 'devices'],
                capture_output=True,
                text=True,
                timeout=5
            )
            lines = result.stdout.strip().split('\n')[1:]  # Skip header
            devices = [line for line in lines if line.strip() and 'device' in line]
            return len(devices) > 0
        except FileNotFoundError:
            print(f"Error: ADB not found at '{self.adb_path}'")
            print("\nPlease install ADB:")
            print("  1. Download Android Platform Tools from:")
            print("     https://developer.android.com/studio/releases/platform-tools")
            print("  2. Add to PATH or place adb.exe in the same folder")
            return False
        except Exception as e:
            print(f"Error checking ADB connection: {e}")
            return False

    def setup_port_forwarding(self):
        """Setup ADB reverse port forwarding for real-time communication.
        
        ADB reverse forwards device ports to PC ports, which is what we need
        for the phone app to connect to the PC server.
        """
        try:
            # Remove existing reverse forwarding for the fixed port
            subprocess.run(
                [self.adb_path, 'reverse', '--remove', f'tcp:{self.forward_port}'],
                capture_output=True,
                timeout=2
            )
            
            # Set up reverse forwarding: device port -> PC port
            # This allows the phone to connect to localhost:port and reach PC's port
            result = subprocess.run(
                [self.adb_path, 'reverse', f'tcp:{self.forward_port}', f'tcp:{self.forward_port}'],
                capture_output=True,
                text=True,
                timeout=5
            )
            
            if result.returncode == 0:
                print(f"[OK] ADB reverse port forwarding set up: device tcp:{self.forward_port} -> PC tcp:{self.forward_port}")
                return True
            else:
                print(f"Error setting up reverse port forwarding: {result.stderr}")
                return False
        except Exception as e:
            print(f"Error setting up reverse port forwarding: {e}")
            return False

    def start_server(self):
        """Start TCP server on PC to receive data from phone."""
        try:
            # Create socket server on 127.0.0.1 (more reliable than localhost on Windows)
            self.server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.server_socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            
            # Try to bind to 127.0.0.1 on fixed port
            self.server_socket.bind(('127.0.0.1', self.forward_port))
            
            self.server_socket.listen(1)
            self.server_socket.settimeout(1.0)  # Non-blocking with timeout
            print(f"[OK] TCP server listening on 127.0.0.1:{self.forward_port}")
            return True
        except Exception as e:
            print(f"Error starting server: {e}")
            print("\nTroubleshooting:")
            print("1. Check if another program is using the port")
            print("2. Try running as Administrator")
            print("3. Check Windows Firewall settings")
            return False

    def accept_connection(self):
        """Accept connection from phone."""
        try:
            if self.server_socket:
                self.client_socket, addr = self.server_socket.accept()
                self.client_socket.settimeout(0.1)  # Short timeout for responsiveness
                print(f"[OK] Phone connected from {addr}")
                return True
        except socket.timeout:
            pass
        except Exception as e:
            print(f"Error accepting connection: {e}")
        return False

    def read_data(self):
        """Read data from connected phone in real-time."""
        if not self.client_socket:
            return None
        
        try:
            data = self.client_socket.recv(1)  # Read one byte at a time for real-time
            if data:
                return data.decode('utf-8', errors='ignore')
        except socket.timeout:
            pass
        except Exception as e:
            print(f"Connection error: {e}")
            self.client_socket = None
        return None

    def cleanup(self):
        """Clean up connections."""
        if self.client_socket:
            self.client_socket.close()
            self.client_socket = None
        if self.server_socket:
            self.server_socket.close()
            self.server_socket = None
        # Remove port forwarding
        try:
            subprocess.run(
                [self.adb_path, 'reverse', '--remove', f'tcp:{self.forward_port}'],
                capture_output=True,
                timeout=2
            )
        except:
            pass


def main():
    parser = argparse.ArgumentParser(
        description='PC Receiver for USB Keyboard App - Real-time via ADB',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
This receiver uses ADB port forwarding for real-time keyboard input.
The phone app connects to the PC via TCP socket through ADB.

Make sure:
  1. USB debugging is enabled on your phone
  2. Phone is connected via USB
  3. ADB is installed and device is authorized
        """
    )

    args = parser.parse_args()

    print("=" * 60)
    print("USB Keyboard - PC Receiver (Real-time via ADB)")
    print("=" * 60)
    print("\nPress Ctrl+C to stop\n")

    keyboard_sim = KeyboardSimulator()
    receiver = AdbReceiver()

    # Check ADB connection
    if not receiver.check_connection():
        print("Error: No Android device connected via ADB")
        print("\nMake sure:")
        print("  1. USB debugging is enabled on your phone")
        print("     (Settings > Developer Options > USB Debugging)")
        print("  2. Device is connected via USB")
        print("  3. You've authorized the computer on your phone")
        print("  4. ADB is installed and in your PATH")
        print("\nTo verify ADB connection, run:")
        print(f"  {receiver.adb_path} devices")
        sys.exit(1)

    print("[OK] ADB device detected!")

    # Setup port forwarding
    print("Setting up ADB port forwarding...")
    if not receiver.setup_port_forwarding():
        print("Failed to setup ADB port forwarding")
        sys.exit(1)
    
    # Verify reverse forwarding was set up
    result = subprocess.run(
        [receiver.adb_path, 'reverse', '--list'],
        capture_output=True,
        text=True,
        timeout=2
    )
    if result.stdout:
        print(f"Active reverse port forwards:\n{result.stdout}")
    else:
        print("Warning: No active reverse port forwards found")

    # Start TCP server
    if not receiver.start_server():
        print("Failed to start TCP server")
        sys.exit(1)

    print("\nWaiting for phone to connect...")
    print("(Make sure the Flutter app is running and connected)\n")

    try:
        # Wait for phone to connect
        connected = False
        attempts = 0
        max_attempts = 60  # Wait up to 30 seconds (60 * 0.5)
        while not connected and attempts < max_attempts:
            connected = receiver.accept_connection()
            if not connected:
                time.sleep(0.5)
                attempts += 1
                if attempts % 10 == 0:  # Print every 5 seconds
                    print(f"\nStill waiting... ({attempts * 0.5:.0f}s)")
                else:
                    print(".", end="", flush=True)
        
        if not connected:
            print("\n\nTimeout: Phone did not connect.")
            print("\nTroubleshooting:")
            print("1. Make sure Flutter app is running")
            print("2. Check that app shows 'Connecting to PC via ADB...'")
            print("3. Verify ADB reverse forwarding: adb reverse --list")
            print("4. Try restarting both PC receiver and Flutter app")
            sys.exit(1)

        print("\n[OK] Phone connected! Start typing on your phone...")
        print("(Running silently - keystrokes are being sent to PC)\n")

        # Real-time keyboard input loop
        while True:
            char = receiver.read_data()
            if char:
                # Send key silently without printing
                keyboard_sim.send_key(char)
            time.sleep(0.001)  # Very short delay for maximum responsiveness

    except KeyboardInterrupt:
        print("\n\nStopping...")
    finally:
        receiver.cleanup()
        print("Cleaned up connections")


if __name__ == '__main__':
    main()
