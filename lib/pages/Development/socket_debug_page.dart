import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/services/socket_notification_service.dart';
import 'package:mentalsustainability/theme/app_colors.dart';

class SocketDebugPage extends StatefulWidget {
  const SocketDebugPage({super.key});

  @override
  State<SocketDebugPage> createState() => _SocketDebugPageState();
}

class _SocketDebugPageState extends State<SocketDebugPage> {
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
      });
    } catch (e) {
      _serviceAvailable = false;
      _addLog('⚠️ Socket service not available: $e');
    }
  }
  
  void _addLog(String log) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $log');
      
      // Scroll to bottom after rendering
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    });
  }
  
  void _clearLogs() {
    setState(() {
      _logs.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Socket.IO Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearLogs,
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
              child: Row(
                children: [
                  Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Socket service not available',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
          // Action buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _serviceAvailable
                      ? () {
                          _socketService.reconnect();
                          _addLog('🔄 Reconnection requested');
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
                          _addLog('📤 Test notification sent');
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

          // Received notifications
          if (_serviceAvailable)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Received Notifications',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
            
          if (_serviceAvailable)
            Obx(() {
              final notifications = _socketService.liveNotifications;
              return Padding(
                padding: const EdgeInsets.all(16),
                child: notifications.isEmpty
                    ? Center(
                        child: Text(
                          'No notifications received yet',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    : Column(
                        children: notifications.take(3).map((notification) {
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(notification['title'] ?? 'No title'),
                              subtitle: Text(notification['message'] ?? 'No message'),
                            ),
                          );
                        }).toList(),
                      ),
              );
            }),
            
          // Debug logs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  'Debug Logs',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearLogs,
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
          
          // Log list
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ListView.builder(
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
                        color: log.contains('⚠️')
                            ? Colors.red.shade700
                            : log.contains('✅')
                                ? Colors.green.shade700
                                : Colors.grey.shade800,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
