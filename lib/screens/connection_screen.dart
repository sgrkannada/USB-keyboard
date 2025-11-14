import 'package:flutter/material.dart';
import 'package:usb_serial/usb_serial.dart';
import '../services/usb_service.dart';
import '../screens/keyboard_screen.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> {
  final UsbService _usbService = UsbService();
  List<UsbDevice> _devices = [];
  bool _isScanning = false;
  UsbDevice? _selectedDevice;

  @override
  void initState() {
    super.initState();
    _scanDevices();
  }

  Future<void> _scanDevices() async {
    setState(() {
      _isScanning = true;
    });

    try {
      List<UsbDevice> devices = await _usbService.getAvailableDevices();
      setState(() {
        _devices = devices;
        _isScanning = false;
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning devices: $e')),
        );
      }
    }
  }

  Future<void> _connectToDevice(UsbDevice device) async {
    setState(() {
      _selectedDevice = device;
    });

    bool connected = await _usbService.connect(device);
    
    if (mounted) {
      if (connected) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => KeyboardScreen(usbService: _usbService),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to connect to device. Please check USB permissions.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _selectedDevice = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('USB Keyboard - Connect'),
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
                      'Connect via USB',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Connect your phone to PC via USB cable',
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Available Devices',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: _isScanning
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  onPressed: _isScanning ? null : _scanDevices,
                  tooltip: 'Refresh',
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _devices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.devices_other,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _isScanning
                                ? 'Scanning for devices...'
                                : 'No USB devices found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          if (!_isScanning) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Make sure USB debugging is enabled',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: _devices.length,
                      itemBuilder: (context, index) {
                        final device = _devices[index];
                        final isSelected = _selectedDevice?.deviceId == device.deviceId;
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 2,
                          color: isSelected ? Colors.blue.shade50 : null,
                          child: ListTile(
                            leading: Icon(
                              Icons.usb,
                              color: Colors.blue.shade700,
                            ),
                            title: Text(
                              device.productName ?? 'Unknown Device',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              'VID: ${device.vid?.toRadixString(16).toUpperCase() ?? "N/A"}, '
                              'PID: ${device.pid?.toRadixString(16).toUpperCase() ?? "N/A"}',
                            ),
                            trailing: isSelected
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: isSelected
                                ? null
                                : () => _connectToDevice(device),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usbService.disconnect();
    super.dispose();
  }
}


