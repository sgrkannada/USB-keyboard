# Quick Start Guide - Real-time USB Keyboard

## Setup Steps

### 1. Start PC Receiver First

Open a terminal/PowerShell in the project directory and run:

```bash
python pc_receiver.py
```

You should see:
```
============================================================
USB Keyboard - PC Receiver (Real-time via ADB)
============================================================

[OK] ADB device detected!
[OK] ADB port forwarding set up: tcp:12345 -> tcp:12345
[OK] TCP server listening on localhost:12345

Waiting for phone to connect...
```

**Keep this terminal window open!**

### 2. Run Flutter App on Phone

In another terminal, run:

```bash
flutter run
```

Or if you already have it running, the app should automatically connect.

### 3. Connect in the App

1. The app will show "Connecting to PC via ADB..."
2. Once connected, you'll see "Connected! Ready to type."
3. Tap "Open Keyboard" to start typing

### 4. Start Typing!

- Type on the virtual keyboard on your phone
- Keystrokes appear on your PC **instantly** (real-time, no files!)
- Works just like a physical keyboard

## Troubleshooting

### "Cannot connect to PC"
- Make sure PC receiver is running first
- Check that USB debugging is enabled
- Verify phone is connected via USB
- Run `adb devices` to check connection

### "ADB not found" (PC side)
- Install Android Platform Tools
- Or ensure ADB is in your PATH
- Run `python check_adb.py` to verify

### Connection Issues
1. Stop both PC receiver and Flutter app
2. Restart PC receiver first
3. Then restart Flutter app
4. Wait a few seconds for connection

## File Locations

- **PC Receiver**: `pc_receiver.py` (run this first!)
- **Flutter App**: `lib/main.dart` (entry point)
- **ADB Service**: `lib/services/adb_service.dart` (handles real-time communication)
- **Connection Screen**: `lib/screens/adb_connection_screen.dart`
- **Keyboard Screen**: `lib/screens/keyboard_screen_adb.dart`

## How It Works

1. **PC Receiver** sets up ADB port forwarding (tcp:12345)
2. **PC Receiver** starts a TCP server on localhost:12345
3. **Phone App** connects to localhost:12345 (forwarded via ADB)
4. **Keystrokes** are sent instantly over the TCP socket
5. **PC Receiver** receives and simulates keyboard input in real-time

**No files are written - everything is real-time socket communication!**

