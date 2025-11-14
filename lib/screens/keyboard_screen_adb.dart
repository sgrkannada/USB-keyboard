import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/adb_service.dart';

class KeyboardScreenAdb extends StatefulWidget {
  final AdbService adbService;

  const KeyboardScreenAdb({super.key, required this.adbService});

  @override
  State<KeyboardScreenAdb> createState() => _KeyboardScreenAdbState();
}

class _KeyboardScreenAdbState extends State<KeyboardScreenAdb> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String _status = 'Ready';
  bool _isConnected = true;
  String _lastSentText = '';

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _checkConnection();
    
    // Listen to text changes and send new content
    _textController.addListener(_onTextChanged);
  }

  void _checkConnection() {
    widget.adbService.checkDeviceConnected().then((connected) {
      setState(() {
        _isConnected = connected;
        _status = connected ? 'Connected' : 'Disconnected';
      });
    });
  }

  void _onTextChanged() {
    if (!widget.adbService.isConnected) {
      _checkConnection();
      return;
    }

    String currentText = _textController.text;
    
    // Calculate what was added (handles typing, pasting, etc.)
    if (currentText.length > _lastSentText.length) {
      // New text was added
      String newText = currentText.substring(_lastSentText.length);
      _sendText(newText);
      _lastSentText = currentText;
    } else if (currentText.length < _lastSentText.length) {
      // Text was deleted (backspace)
      int deletedCount = _lastSentText.length - currentText.length;
      for (int i = 0; i < deletedCount; i++) {
        _sendKey('\b');
      }
      _lastSentText = currentText;
    } else if (currentText != _lastSentText) {
      // Text was modified (e.g., replaced)
      // Send the entire new text
      _sendText(currentText);
      _lastSentText = currentText;
    }
  }

  Future<void> _sendKey(String key) async {
    if (!widget.adbService.isConnected) {
      setState(() {
        _status = 'Not connected';
      });
      _checkConnection();
      return;
    }

    try {
      bool success = await widget.adbService.sendKey(key);
      setState(() {
        _status = success ? 'Sent' : 'Failed to send';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  Future<void> _sendText(String text) async {
    if (!widget.adbService.isConnected) {
      setState(() {
        _status = 'Not connected';
      });
      _checkConnection();
      return;
    }

    try {
      bool success = await widget.adbService.sendText(text);
      setState(() {
        _status = success ? 'Text sent' : 'Failed to send text';
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
      });
    }
  }

  void _clearText() {
    _textController.clear();
    _lastSentText = '';
    setState(() {
      _status = 'Cleared';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Keyboard to PC'),
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
                        ? 'Connected to PC via ADB'
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            color: _isConnected ? Colors.green.shade100 : Colors.red.shade100,
            child: Row(
              children: [
                Icon(
                  _isConnected ? Icons.check_circle : Icons.error,
                  color: _isConnected ? Colors.green : Colors.red,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _status,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _isConnected ? Colors.green.shade900 : Colors.red.shade900,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
          ),

          // Instructions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Icon(Icons.info, color: Colors.blue.shade700, size: 18),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'How to use:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Flexible(
                  child: Text(
                    '• Type using your phone\'s keyboard\n'
                    '• Paste text (Ctrl+V or long press)\n'
                    '• All input is sent to PC in real-time',
                    style: TextStyle(
                      color: Colors.blue.shade900,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Text input area - uses phone's system keyboard
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Type here (uses your phone\'s keyboard):',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300, width: 2),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.white,
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
                          hintText: 'Start typing... Your phone keyboard will appear.\n\nYou can also paste text here!',
                          hintStyle: TextStyle(fontSize: 13),
                        ),
                        style: const TextStyle(fontSize: 15),
                        // Enable paste
                        enableInteractiveSelection: true,
                        // Capture all input including paste
                        onChanged: (text) {
                          // Handled by listener
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
                          icon: const Icon(Icons.clear, size: 18),
                          label: const Text('Clear', style: TextStyle(fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            backgroundColor: Colors.grey.shade300,
                            foregroundColor: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            _focusNode.requestFocus();
                            // Show keyboard
                            SystemChannels.textInput.invokeMethod('TextInput.show');
                          },
                          icon: const Icon(Icons.keyboard, size: 18),
                          label: const Text('Keyboard', style: TextStyle(fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            backgroundColor: Colors.blue.shade300,
                            foregroundColor: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
