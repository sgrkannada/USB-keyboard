import 'package:flutter/material.dart';
import '../services/usb_service.dart';

class KeyboardScreen extends StatefulWidget {
  final UsbService usbService;

  const KeyboardScreen({super.key, required this.usbService});

  @override
  State<KeyboardScreen> createState() => _KeyboardScreenState();
}

class _KeyboardScreenState extends State<KeyboardScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _status = 'Ready';
  bool _isConnected = true;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _checkConnection();
  }

  void _checkConnection() {
    setState(() {
      _isConnected = widget.usbService.isConnected;
      _status = _isConnected ? 'Connected' : 'Disconnected';
    });
  }

  Future<void> _sendKeyEvent(String key, {bool isSpecialKey = false}) async {
    if (!widget.usbService.isConnected) {
      setState(() {
        _status = 'Not connected';
      });
      return;
    }

    try {
      bool success = false;
      if (isSpecialKey) {
        switch (key) {
          case 'BACKSPACE':
            success = await widget.usbService.sendBackspace();
            if (success && _textController.text.isNotEmpty) {
              _textController.text = _textController.text.substring(
                0,
                _textController.text.length - 1,
              );
            }
            break;
          case 'ENTER':
            success = await widget.usbService.sendEnter();
            if (success) {
              _textController.text += '\n';
            }
            break;
          case 'SPACE':
            success = await widget.usbService.sendKey(' ');
            if (success) {
              _textController.text += ' ';
            }
            break;
          case 'TAB':
            success = await widget.usbService.sendKey('\t');
            if (success) {
              _textController.text += '\t';
            }
            break;
          default:
            success = await widget.usbService.sendKey(key);
        }
      } else {
        success = await widget.usbService.sendKey(key);
        if (success) {
          _textController.text += key;
        }
      }

      setState(() {
        _status = success ? 'Sent: $key' : 'Failed to send';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }


  void _clearText() {
    _textController.clear();
    setState(() {
      _status = 'Cleared';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Virtual Keyboard'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.usb : Icons.usb_off),
            onPressed: () {
              _checkConnection();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_isConnected
                        ? 'Connected to PC'
                        : 'Disconnected from PC'),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Status bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: _isConnected ? Colors.green.shade100 : Colors.red.shade100,
            child: Row(
              children: [
                Icon(
                  _isConnected ? Icons.check_circle : Icons.error,
                  color: _isConnected ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 8),
                Text(
                  _status,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isConnected ? Colors.green.shade900 : Colors.red.shade900,
                  ),
                ),
              ],
            ),
          ),

          // Text input area
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Text Preview:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(12),
                      child: TextField(
                        controller: _textController,
                        focusNode: _focusNode,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Type here...',
                        ),
                        onChanged: (text) {
                          // Send each character as it's typed
                          if (text.isNotEmpty) {
                            String lastChar = text[text.length - 1];
                            _sendKeyEvent(lastChar);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _clearText,
                          icon: const Icon(Icons.clear),
                          label: const Text('Clear'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey.shade300,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Virtual keyboard
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Number row
                _buildKeyRow([
                  '1', '2', '3', '4', '5', '6', '7', '8', '9', '0',
                ]),
                const SizedBox(height: 4),
                // Top row
                _buildKeyRow([
                  'q', 'w', 'e', 'r', 't', 'y', 'u', 'i', 'o', 'p',
                ]),
                const SizedBox(height: 4),
                // Middle row
                _buildKeyRow([
                  'a', 's', 'd', 'f', 'g', 'h', 'j', 'k', 'l',
                ]),
                const SizedBox(height: 4),
                // Bottom row
                _buildKeyRow([
                  'z', 'x', 'c', 'v', 'b', 'n', 'm',
                ]),
                const SizedBox(height: 8),
                // Special keys row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSpecialKey('SPACE', Icons.space_bar, width: 200),
                    _buildSpecialKey('ENTER', Icons.keyboard_return),
                    _buildSpecialKey('BACKSPACE', Icons.backspace),
                    _buildSpecialKey('TAB', Icons.keyboard_tab),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyRow(List<String> keys) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((key) => _buildKey(key)).toList(),
    );
  }

  Widget _buildKey(String key) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: ElevatedButton(
          onPressed: () => _sendKeyEvent(key),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 2,
          ),
          child: Text(
            key.toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKey(String key, IconData icon, {double? width}) {
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: ElevatedButton.icon(
          onPressed: () => _sendKeyEvent(key, isSpecialKey: true),
          icon: Icon(icon),
          label: Text(key == 'SPACE' ? 'Space' : key),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
            backgroundColor: Colors.blue.shade100,
            foregroundColor: Colors.blue.shade900,
            elevation: 2,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}

