import 'dart:async';
import 'dart:typed_data';
import 'package:usb_serial/usb_serial.dart';

/// USB Service for communicating with PC via USB Serial
/// 
/// Note: The usb_serial package API may vary by version.
/// If you encounter connection issues, check the package documentation
/// and adjust the connection method accordingly.
class UsbService {
  UsbPort? _port;
  bool _isConnected = false;
  StreamSubscription<String>? _subscription;

  bool get isConnected => _isConnected;

  Future<List<UsbDevice>> getAvailableDevices() async {
    return await UsbSerial.listDevices();
  }

  Future<bool> connect(UsbDevice device) async {
    try {
      // Note: The exact API may vary by usb_serial package version
      // Common patterns:
      // - UsbSerial.createConnection(deviceId)
      // - device.createConnection()
      // - UsbSerial.open(deviceId)
      
      // Try to get connection - adjust based on your usb_serial version
      // For usb_serial ^0.5.0, try:
      dynamic port;
      
      // Attempt connection using dynamic call
      // This handles different API versions
      try {
        // Method 1: Static method on UsbSerial
        var result = await (UsbSerial as dynamic).createConnection(device.deviceId);
        port = result;
      } catch (e) {
        // Method 2: Instance method on device
        try {
          var result = await (device as dynamic).createConnection();
          port = result;
        } catch (e2) {
          print('Could not establish connection. Error: $e2');
          print('Please check usb_serial package documentation for your version.');
          return false;
        }
      }
      
      if (port == null) {
        return false;
      }
      
      _port = port as UsbPort?;
      if (_port == null) {
        return false;
      }

      bool openResult = await _port!.open();
      if (!openResult) {
        return false;
      }

      await _port!.setDTR(true);
      await _port!.setRTS(true);
      await _port!.setPortParameters(
        115200,
        UsbPort.DATABITS_8,
        UsbPort.STOPBITS_1,
        UsbPort.PARITY_NONE,
      );

      _isConnected = true;
      return true;
    } catch (e) {
      print('Error connecting to USB device: $e');
      print('If connection fails, you may need to:');
      print('1. Check USB permissions on your device');
      print('2. Verify usb_serial package version and API');
      print('3. Consider using ADB method instead (see README)');
      return false;
    }
  }

  Future<void> disconnect() async {
    _subscription?.cancel();
    await _port?.close();
    _port = null;
    _isConnected = false;
  }

  Future<bool> sendKey(String key) async {
    if (!_isConnected || _port == null) {
      return false;
    }

    try {
      await _port!.write(Uint8List.fromList(key.codeUnits));
      return true;
    } catch (e) {
      print('Error sending key: $e');
      return false;
    }
  }

  Future<bool> sendBackspace() async {
    return await sendKey('\b');
  }

  Future<bool> sendEnter() async {
    return await sendKey('\n');
  }

  Future<bool> sendText(String text) async {
    if (!_isConnected || _port == null) {
      return false;
    }

    try {
      for (int i = 0; i < text.length; i++) {
        await _port!.write(Uint8List.fromList([text.codeUnitAt(i)]));
        await Future.delayed(const Duration(milliseconds: 10));
      }
      return true;
    } catch (e) {
      print('Error sending text: $e');
      return false;
    }
  }
}
