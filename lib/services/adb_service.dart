import 'dart:io';
import 'dart:async';

/// ADB Service for real-time keyboard input via ADB
/// Uses TCP socket communication through ADB port forwarding
class AdbService {
  Socket? _socket;
  bool _isConnected = false;
  static const int _port = 12345;  // Fixed port for all connections

  bool get isConnected => _isConnected;

  /// Connect to PC via ADB port forwarding
  /// The PC receiver sets up ADB forward, and we connect to localhost
  Future<bool> checkDeviceConnected() async {
    try {
      final socket = await Socket.connect('127.0.0.1', _port, timeout: const Duration(seconds: 1));
      await socket.close();
      _isConnected = true;
      return true;
    } catch (e) {
      _isConnected = false;
      return false;
    }
  }

  /// Initialize connection - connect to the fixed forwarded port
  Future<void> initialize() async {
    try {
      print('Attempting to connect to 127.0.0.1:$_port...');
      _socket = await Socket.connect('127.0.0.1', _port, timeout: const Duration(seconds: 3));
      _isConnected = true;
      print('✓ Connected to PC via ADB port forwarding on port $_port');
    } catch (e) {
      print('✗ Could not connect to PC on port $_port: $e');
      print('\nTroubleshooting:');
      print('1. Verify PC receiver is running: python pc_receiver.py');
      print('2. Check ADB connection: adb devices');
      print('3. Verify reverse port forwarding: adb reverse --list');
      print('4. Make sure ADB reverse is set up (PC receiver should do this)');
      _isConnected = false;
    }
  }

  /// Send a key in real-time via socket
  Future<bool> sendKey(String key) async {
    if (!_isConnected || _socket == null) {
      // Try to reconnect
      await initialize();
      if (!_isConnected || _socket == null) {
        return false;
      }
    }

    try {
      // Send the key character directly
      _socket!.add(key.codeUnits);
      await _socket!.flush();
      return true;
    } catch (e) {
      print('Error sending key: $e');
      _isConnected = false;
      _socket = null;
      return false;
    }
  }

  /// Send text character by character
  Future<bool> sendText(String text) async {
    try {
      for (int i = 0; i < text.length; i++) {
        await sendKey(text[i]);
        await Future.delayed(const Duration(milliseconds: 5));
      }
      return true;
    } catch (e) {
      print('Error sending text: $e');
      return false;
    }
  }

  Future<bool> sendBackspace() async {
    return await sendKey('\b');
  }

  Future<bool> sendEnter() async {
    return await sendKey('\n');
  }

  Future<void> disconnect() async {
    await _socket?.close();
    _socket = null;
    _isConnected = false;
  }

  /// Check if ADB is available (placeholder - actual check is on PC)
  Future<bool> checkAdbAvailable() async {
    return await checkDeviceConnected();
  }
}
