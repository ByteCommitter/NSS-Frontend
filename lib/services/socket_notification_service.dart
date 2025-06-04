import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class SocketNotificationService extends GetxService {
  // Socket instance
  io.Socket? _socket;
  
  // Stream controller for notifications
  final _notificationController = StreamController<Map<String, dynamic>>.broadcast();
  
  // Observable list of notifications
  final liveNotifications = <Map<String, dynamic>>[].obs;
  
  // Connection status
  final isConnected = false.obs;
  
  // Stream getter
  Stream<Map<String, dynamic>> get notificationStream => _notificationController.stream;
  
  // Reference counter to track how many widgets are using this service
  final _referenceCount = 0.obs;
  
  // Initialize the service
  Future<SocketNotificationService> init() async {
    print('🔌 Socket Notification Service: Initializing');
    return this;
  }

  // Register a widget as using this service
  void registerUser() {
    _referenceCount.value++;
    print('🔌 Socket registered user: Reference count is now ${_referenceCount.value}');
    if (_referenceCount.value == 1) {
      // First user, start connection
      _connectSocket();
    }
  }

  // Unregister a widget when it's no longer using this service
  void unregisterUser() {
    if (_referenceCount.value > 0) {
      _referenceCount.value--;
      print('🔌 Socket unregistered user: Reference count is now ${_referenceCount.value}');
      if (_referenceCount.value == 0) {
        // No more users, close connection
        _disconnectSocket();
      }
    }
  }
  
  // Connect to socket server
  void _connectSocket() {
    try {
      print('🔌 Socket Notification Service: Attempting to connect to server');
      
      // Close any existing connection
      _socket?.disconnect();
      
      // Create socket connection
      // For web, we need to use the full URL including protocol
      const serverUrl = "https://notificationserver-production-6fc2.up.railway.app" ;
      
      // kIsWeb 
      //     ? 'http://localhost:8991' 
      //     : 'http://10.0.2.2:8991';  // Use this for Android emulator (or localhost for iOS simulator)
      
      print('🔌 Socket Notification Service: Connecting to $serverUrl');
      
      _socket = io.io(
        serverUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect() 
            .enableForceNew()
            .enableReconnection()
            .setReconnectionAttempts(10)
            .setReconnectionDelay(3000)
            .build()
      );
      
      // Setup all connection listeners
      _setupConnectionListeners();
      
      // Connect to the server
      _socket!.connect();
      print('🔌 Socket Notification Service: Connect method called');
      
    } catch (e) {
      print('⚠️ Socket Notification Service: Error initializing socket - $e');
    }
  }
  
  // Setup socket connection status listener
  void _setupConnectionListeners() {
    // Set up event handlers
    _socket!.onConnect((_) {
      print('✅ Socket Notification Service: Connected successfully');
      // Safely update the observable - check if this service is still active
      if (!_disposed) {
        isConnected.value = true;
      }
    });
    
    _socket!.onDisconnect((_) {
      print('❌ Socket Notification Service: Disconnected');
      // Safely update the observable - check if this service is still active
      if (!_disposed) {
        isConnected.value = false;
      }
    });
    
    _socket!.onConnectError((error) {
      print('⚠️ Socket Notification Service: Connection error - $error');
      // Safely update the observable - check if this service is still active
      if (!_disposed) {
        isConnected.value = false;
      }
    });
    
    _socket!.onError((error) {
      print('⚠️ Socket Notification Service: Socket error - $error');
    });
    
    // Listen for multiple notification event types
    _setupNotificationListeners();
  }

  // Setup notification event listeners for different event names
  void _setupNotificationListeners() {
    // Common notification handler function
    void handleNotification(dynamic data, String eventType) {
      print('📩 Socket Notification Service: Received $eventType - $data');
      
      if (_disposed) {
        print('⚠️ Socket Notification Service: Service disposed, ignoring notification');
        return;
      }
      
      try {
        final notification = _processNotification(data);
        
        // Add event type to the notification for debugging
        notification['eventType'] = eventType;
        
        // Only update if service is still active
        if (!_disposed) {
          liveNotifications.insert(0, notification);
          if (!_notificationController.isClosed) {
            _notificationController.add(notification);
          }
        }
        
        print('✅ Socket Notification Service: Processed $eventType successfully');
      } catch (e) {
        print('⚠️ Socket Notification Service: Error processing $eventType - $e');
      }
    }
    
    // Listen for 'notification' event
    _socket!.on('notification', (data) => handleNotification(data, 'notification'));
    
    // Also listen for 'pushNotification' event
    _socket!.on('pushNotification', (data) => handleNotification(data, 'pushNotification'));
    
    // Listen for 'message' event (another common event name)
    _socket!.on('message', (data) => handleNotification(data, 'message'));
    
    // Listen for server-side events
    _socket!.on('connect', (_) => print('🔌 Socket event: connect'));
    _socket!.on('disconnect', (_) => print('🔌 Socket event: disconnect'));
    _socket!.on('connecting', (_) => print('🔌 Socket event: connecting'));
    _socket!.on('reconnect', (_) => print('🔌 Socket event: reconnect'));
    _socket!.on('error', (e) => print('🔌 Socket event: error - $e'));
    
    // Debug - print all events received
    _socket!.onAny((event, data) {
      print('🔍 Socket ANY event: $event - $data');
    });
  }

  // Add these variables and methods to help manage the service lifecycle
  bool _disposed = false;
  
  // Mark as disposed when service is closed
  @override
  void onClose() {
    print('👋 Socket Notification Service: Closing');
    _disposed = true;
    _disconnectSocket();
    
    try {
      if (!_notificationController.isClosed) {
        _notificationController.close();
      }
    } catch (e) {
      print('⚠️ Socket Notification Service: Error closing notification controller - $e');
    }
    
    super.onClose();
  }

  // Disconnect from socket server
  void _disconnectSocket() {
    print('🔌 Socket Notification Service: Disconnecting socket');
    try {
      _socket?.disconnect();
      _socket = null;
      // Safely update the observable
      _safeUpdate(() => isConnected.value = false);
    } catch (e) {
      print('⚠️ Socket Notification Service: Error disconnecting socket - $e');
    }
  }
  
  // Process incoming notification data
  Map<String, dynamic> _processNotification(dynamic data) {
    print('🔄 Socket Notification Service: Processing notification data - $data');
    
    // Handle different data formats
    if (data is Map<String, dynamic>) {
      return {
        'id': data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'title': data['title'] ?? 'New Notification',
        'message': data['message'] ?? data['content'] ?? 'You have a new notification',
        'time': data['time'] ?? DateTime.now().toIso8601String(),
        'isRead': false,
      };
    } else if (data is String) {
      return {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'title': 'New Notification',
        'message': data,
        'time': DateTime.now().toIso8601String(),
        'isRead': false,
      };
    } else {
      try {
        final message = data.toString();
        return {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'title': 'New Notification',
          'message': message,
          'time': DateTime.now().toIso8601String(),
          'isRead': false,
        };
      } catch (e) {
        print('⚠️ Socket Notification Service: Error parsing notification - $e');
        return {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'title': 'New Notification',
          'message': 'You have a new notification',
          'time': DateTime.now().toIso8601String(),
          'isRead': false,
        };
      }
    }
  }
  
  // Test the connection by sending a message
  void sendTestNotification() {
    if (_socket != null && isConnected.value) {
      print('🧪 Socket Notification Service: Sending test message');
      _socket!.emit('test_notification', {'message': 'Test from app'});
    } else {
      print('❌ Socket Notification Service: Cannot send test, not connected');
    }
  }
  
  // Manually reconnect
  void reconnect() {
    print('🔄 Socket Notification Service: Manual reconnection requested');
    _connectSocket();
  }
  
  // Get connection status
  bool isSocketConnected() {
    return isConnected.value;
  }
  
  // Simulate a local notification for testing
  void simulateNotification(Map<String, dynamic> notification) {
    try {
      // Process the notification using existing mechanism
      final processedNotification = _processNotification(notification);
      
      // Safely update the observable list
      _safeUpdate(() {
        liveNotifications.insert(0, processedNotification);
      });
      
      // Emit to stream if not closed
      if (!_notificationController.isClosed) {
        _notificationController.add(processedNotification);
      }
      
      print('✅ Socket Notification Service: Simulated notification processed');
    } catch (e) {
      print('⚠️ Socket Notification Service: Error simulating notification - $e');
    }
  }
  
  // Safely update an observable value with proper error handling
  void _safeUpdate(VoidCallback callback) {
    try {
      callback();
    } catch (e) {
      print('⚠️ Socket Notification Service: Error updating state - $e');
    }
  }
}
