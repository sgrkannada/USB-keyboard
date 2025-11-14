# USB Keyboard - Phone to PC Keyboard Converter

A Flutter application that converts your phone's keyboard into a PC external keyboard via USB cable connection.

## Features

- 📱 Virtual keyboard interface on your phone
- 🔌 USB connection between phone and PC
- ⌨️ Real-time keyboard input simulation on PC
- 🎨 Modern, user-friendly UI
- 🔄 Connection status monitoring

## Project Structure

```
bk/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── screens/
│   │   ├── connection_screen.dart # USB device connection screen
│   │   └── keyboard_screen.dart  # Virtual keyboard interface
│   └── services/
│       └── usb_service.dart       # USB communication service
├── android/                      # Android-specific configuration
├── pc_receiver.py                # PC-side Python receiver script
└── pc_receiver_requirements.txt  # Python dependencies

```

## Setup Instructions

### Phone Side (Flutter App)

1. **Prerequisites:**
   - Flutter SDK installed
   - Android device with USB debugging enabled
   - USB cable to connect phone to PC

2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Enable USB Debugging on Android:**
   - Go to Settings > About Phone
   - Tap "Build Number" 7 times to enable Developer Options
   - Go to Settings > Developer Options
   - Enable "USB Debugging"

4. **Run the App:**
   ```bash
   flutter run
   ```

### PC Side (Python Receiver)

1. **Install Python Dependencies:**
   ```bash
   pip install -r pc_receiver_requirements.txt
   ```

2. **Find Your Serial Port:**
   - **Windows:** Usually `COM3`, `COM4`, etc. (Check Device Manager)
   - **Linux:** Usually `/dev/ttyUSB0` or `/dev/ttyACM0`
   - **macOS:** Usually `/dev/cu.usbserial-*` or `/dev/tty.usbserial-*`

3. **Run the Receiver:**
   ```bash
   # For USB Serial method (recommended)
   python pc_receiver.py --method serial --port COM3  # Windows
   python pc_receiver.py --method serial --port /dev/ttyUSB0  # Linux
   
   # For ADB method (alternative)
   python pc_receiver.py --method adb
   ```

## Usage

1. **Connect Phone to PC:**
   - Connect your phone to PC via USB cable
   - On your phone, select "File Transfer" or "MTP" mode when prompted

2. **Start PC Receiver:**
   - Run the Python script on your PC
   - Wait for "Waiting for keyboard input from phone..." message

3. **Launch Phone App:**
   - Open the Flutter app on your phone
   - The app will scan for USB devices
   - Select your PC from the device list
   - Grant USB permissions if prompted

4. **Start Typing:**
   - Use the virtual keyboard on your phone
   - Text will appear on your PC in real-time
   - The text preview shows what you're typing

## Troubleshooting

### Phone App Issues

- **No USB devices found:**
  - Ensure USB debugging is enabled
  - Try disconnecting and reconnecting the USB cable
  - Check if USB permissions are granted

- **Connection fails:**
  - Verify USB cable supports data transfer (not just charging)
  - Try a different USB port on your PC
  - Restart the app

### PC Receiver Issues

- **Serial port not found:**
  - Check Device Manager (Windows) or `ls /dev/tty*` (Linux)
  - Ensure phone is connected and recognized
  - Try different port numbers

- **Permission denied (Linux):**
  ```bash
   sudo usermod -a -G dialout $USER
   # Then logout and login again
   ```

- **Import errors:**
  ```bash
   pip install --upgrade pynput pyserial
   ```

## Technical Details

### Communication Protocol

The app uses USB Serial communication to send keyboard events:
- Baudrate: 115200
- Data bits: 8
- Stop bits: 1
- Parity: None

### Keyboard Events

The app supports:
- Alphanumeric characters (a-z, 0-9)
- Special keys: Space, Enter, Backspace, Tab
- Real-time character transmission

## Requirements

### Phone
- Android 5.0 (API 21) or higher
- USB Host support
- USB debugging enabled

### PC
- Python 3.6 or higher
- pynput library (for keyboard simulation)
- pyserial library (for USB serial communication)
- ADB (optional, for ADB method)

## Limitations

- Currently supports basic keyboard input
- Special keys like Ctrl, Alt, Shift combinations require additional implementation
- USB Serial method requires proper drivers on PC
- ADB method is simplified and may need custom implementation for full functionality

## Future Enhancements

- [ ] Support for modifier keys (Ctrl, Alt, Shift)
- [ ] Function keys (F1-F12)
- [ ] Arrow keys and navigation
- [ ] Mouse control
- [ ] Wireless connection option
- [ ] Custom key mappings
- [ ] Multi-language keyboard support

## License

This project is provided as-is for educational and personal use.

## Contributing

Feel free to submit issues and enhancement requests!
