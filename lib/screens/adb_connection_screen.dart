import 'package:flutter/material.dart';
import '../services/adb_service.dart';
import 'keyboard_screen_adb.dart';

class AdbConnectionScreen extends StatefulWidget {
  const AdbConnectionScreen({super.key});

  @override
  State<AdbConnectionScreen> createState() => _AdbConnectionScreenState();
}

class _AdbConnectionScreenState extends State<AdbConnectionScreen> {
  final AdbService _adbService = AdbService();
  bool _isChecking = false;
  bool _isConnected = false;
  String _statusMessage = 'Checking ADB connection...';

  @override
  void initState() {
    super.initState();
    _checkConnection();
  }

  Future<void> _checkConnection() async {
    setState(() {
      _isChecking = true;
      _statusMessage = 'Connecting to PC via ADB...';
    });

    // Try to connect to PC via ADB port forwarding
    // The PC receiver sets up the forwarding, we just connect
    // Retry a few times in case PC receiver is still starting
    bool connected = false;
    for (int attempt = 1; attempt <= 5; attempt++) {
      setState(() {
        _statusMessage = 'Connecting to PC via ADB... (attempt $attempt/5)';
      });
      
      await _adbService.initialize();
      connected = _adbService.isConnected;
      
      if (connected) {
        break;
      }
      
      // Wait a bit before retrying
      await Future.delayed(const Duration(seconds: 1));
    }
    
    if (connected) {
      setState(() {
        _isChecking = false;
        _isConnected = true;
        _statusMessage = 'Connected! Ready to type.\n'
            'Your keystrokes will appear on PC in real-time.';
      });
    } else {
      setState(() {
        _isChecking = false;
        _isConnected = false;
        _statusMessage = 'Cannot connect to PC.\n'
            'Make sure:\n'
            '1. PC receiver is running: python pc_receiver.py\n'
            '2. USB debugging is enabled\n'
            '3. Phone is connected via USB\n'
            '4. Wait a few seconds and tap "Retry Connection"';
      });
    }
  }

  void _connect() {
    if (_isConnected) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => KeyboardScreenAdb(adbService: _adbService),
        ),
      );
    } else {
      _checkConnection();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('USB Keyboard - ADB Connection'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.usb,
                      size: 64,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Connect via ADB',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Connect your phone to PC via USB cable\nwith USB Debugging enabled',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              color: _isConnected ? Colors.green.shade50 : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isConnected ? Icons.check_circle : Icons.error,
                          color: _isConnected ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Connection Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _isConnected ? Colors.green.shade900 : Colors.red.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_isChecking)
                      const Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text('Checking connection...'),
                          ),
                        ],
                      )
                    else
                      Text(
                        _statusMessage,
                        style: TextStyle(
                          color: _isConnected ? Colors.green.shade900 : Colors.red.shade900,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _isChecking ? null : _connect,
              icon: Icon(_isConnected ? Icons.keyboard : Icons.refresh),
              label: Text(_isConnected ? 'Open Keyboard' : 'Retry Connection'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: _isConnected ? Colors.green : Colors.blue,
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _checkConnection,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh Connection'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const Spacer(),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Setup Instructions',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. Enable USB Debugging on your phone\n'
                      '2. Connect phone to PC via USB\n'
                      '3. Authorize computer when prompted\n'
                      '4. Run PC receiver: python pc_receiver.py --method adb',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

