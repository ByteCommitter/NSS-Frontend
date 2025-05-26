import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/services/socket_notification_service.dart';

class SocketTestPage extends StatefulWidget {
  const SocketTestPage({super.key});

  @override
  State<SocketTestPage> createState() => _SocketTestPageState();
}

class _SocketTestPageState extends State<SocketTestPage> {
  late SocketNotificationService _socketService;
  bool _serviceAvailable = false;
  final List<String> _logs = [];
  final ScrollController _scrollController = ScrollController();
  
  @override
  void initState() {
    super.initState();
    try {
      _socketService = Get.find<SocketNotificationService>();
      _serviceAvailable = true;
      _addLog('Socket service found');
      
      // Listen for notifications
      _socketService.notificationStream.listen((notification) {
        _addLog('📩 NOTIFICATION RECEIVED: ${notification['title']} - ${notification['message']}');
        _scrollToBottom();
      });
      
      // Initialize connection if needed
      if (!_socketService.isConnected.value) {
        _socketService.reconnect();
        _addLog('Requested socket reconnection');
      }
    } catch (e) {
      _serviceAvailable = false;
      _addLog('Socket service not available: $e');
    }
  }
  
  void _addLog(String message) {
    setState(() {
      final timestamp = DateTime.now().toString().substring(11, 19);
      _logs.add('[$timestamp] $message');
    });
    _scrollToBottom();
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Socket.IO Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear_all),
            onPressed: () {
              setState(() {
                _logs.clear();
              });
            },
            tooltip: 'Clear logs',
          ),
        ],
      ),
      body: Column(
        children: [
          // Connection status
          if (_serviceAvailable)
            Obx(() => Container(
              padding: const EdgeInsets.all(16),
              color: _socketService.isConnected.value
                  ? Colors.green.shade50
                  : Colors.red.shade50,
              child: Row(
                children: [
                  Icon(
                    _socketService.isConnected.value
                        ? Icons.check_circle
                        : Icons.error,
                    color: _socketService.isConnected.value
                        ? Colors.green
                        : Colors.red,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _socketService.isConnected.value
                          ? 'Connected to socket server'
                          : 'Not connected to socket server',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: _socketService.isConnected.value
                            ? Colors.green.shade700
                            : Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ))
          else
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.red.shade50,
              child: const Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Socket service not available',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _serviceAvailable
                      ? () {
                          _socketService.reconnect();
                          _addLog('Manual reconnection requested');
                        }
                      : null,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reconnect'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _serviceAvailable && _socketService.isConnected.value
                      ? () {
                          _socketService.sendTestNotification();
                          _addLog('Test notification sent');
                        }
                      : null,
                  icon: const Icon(Icons.send),
                  label: const Text('Send Test'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // Debug logs
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text(
                  'Debug Logs',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _logs.isEmpty ? null : () {
                    // Clear logs
                    setState(() {
                      _logs.clear();
                    });
                  },
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          
          // Log list
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: _logs.isEmpty
                  ? const Center(
                      child: Text(
                        'No logs yet',
                        style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            log,
                            style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'monospace',
                              color: log.contains('error') || log.contains('not available')
                                  ? Colors.red.shade700
                                  : log.contains('NOTIFICATION RECEIVED')
                                      ? Colors.green.shade700
                                      : Colors.black87,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
          
          // Manual simulation button
          if (_serviceAvailable)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: () {
                  // Simulate receiving a notification
                  final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
                  try {
                    _addLog('Attempting to simulate local notification...');
                    
                    // Create test notification data
                    final notification = {
                      'id': 'local-$timestamp',
                      'title': 'Local Test Notification',
                      'message': 'This is a locally generated test notification',
                      'time': DateTime.now().toIso8601String(),
                    };
                    
                    // We can't add directly to a Stream, use the service method instead
                    _socketService.simulateNotification(notification);
                    _addLog('Local test notification sent successfully');
                  } catch (e) {
                    _addLog('Error simulating notification: $e');
                  }
                },
                icon: const Icon(Icons.lightbulb),
                label: const Text('Simulate Notification Locally'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
