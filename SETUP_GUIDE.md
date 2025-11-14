# Quick Setup Guide

## Prerequisites

### Phone (Android)
- Android 5.0+ (API 21+)
- USB Debugging enabled
- USB cable that supports data transfer

### PC
- Python 3.6+
- ADB installed (optional, for ADB method)

## Step-by-Step Setup

### 1. Enable USB Debugging on Android

1. Go to **Settings** > **About Phone**
2. Tap **Build Number** 7 times to enable Developer Options
3. Go to **Settings** > **Developer Options**
4. Enable **USB Debugging**
5. Connect phone to PC via USB
6. When prompted, allow USB debugging and check "Always allow from this computer"

### 2. Install Flutter Dependencies

```bash
cd /path/to/bk
flutter pub get
```

### 3. Run Flutter App on Phone

```bash
flutter run
```

Or build and install the APK:
```bash
flutter build apk
# Then install the APK on your phone
```

### 4. Setup PC Receiver

#### Install Python Dependencies

```bash
pip install -r pc_receiver_requirements.txt
```

#### Find Your Serial Port

**Windows:**
- Open Device Manager
- Look under "Ports (COM & LPT)"
- Note the COM port (e.g., COM3, COM4)

**Linux:**
```bash
ls /dev/ttyUSB* /dev/ttyACM*
```

**macOS:**
```bash
ls /dev/cu.usbserial-* /dev/tty.usbserial-*
```

#### Run the Receiver

**Windows:**
```bash
python pc_receiver.py --method serial --port COM3
```

**Linux:**
```bash
python pc_receiver.py --method serial --port /dev/ttyUSB0
```

**macOS:**
```bash
python pc_receiver.py --method serial --port /dev/cu.usbserial-XXXX
```

### 5. Connect and Use

1. **On Phone:**
   - Open the USB Keyboard app
   - Tap "Refresh" to scan for devices
   - Select your PC from the device list
   - Grant USB permissions if prompted

2. **On PC:**
   - The receiver script should show "Waiting for keyboard input from phone..."
   - Keep this window open

3. **Start Typing:**
   - Use the virtual keyboard on your phone
   - Text will appear on your PC in real-time!

## Troubleshooting

### "No USB devices found"
- Ensure USB debugging is enabled
- Try disconnecting and reconnecting USB cable
- Check USB connection mode (should be File Transfer/MTP, not Charging only)

### "Permission denied" (Linux)
```bash
sudo usermod -a -G dialout $USER
# Logout and login again
```

### "Serial port not found"
- Check Device Manager (Windows) or `ls /dev/tty*` (Linux)
- Try different USB ports
- Ensure phone is connected and recognized by PC

### Connection fails in app
- Check if usb_serial package version matches the API
- Verify USB permissions are granted
- Try restarting the app

## Alternative: ADB Method

If USB Serial doesn't work, you can use ADB:

1. Ensure ADB is installed and in your PATH
2. Verify device is connected:
   ```bash
   adb devices
   ```
3. Run receiver with ADB method:
   ```bash
   python pc_receiver.py --method adb
   ```

Note: ADB method requires additional setup for full functionality.

## Need Help?

- Check the main README.md for detailed information
- Verify all dependencies are installed
- Ensure USB debugging is properly enabled
- Try different USB cables/ports

