import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/services/api_service.dart';
import 'package:mentalsustainability/services/auth_service.dart';
import 'package:mentalsustainability/services/socket_notification_service.dart';
import 'package:mentalsustainability/theme/app_colors.dart';
import 'dart:async';
// Import models.dart but rename its Event class to avoid conflicts

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Empty list to be filled from API
  List<Event> _events = [];
  List<Event> _registeredEvents = [];
  final Map<String, bool> _eventRegistrationStatus = {};
  bool _isLoadingRegistered = false;
  
  // New state for notifications from API
  List<Update> _updates = [];
  bool _isLoadingUpdates = false;
  bool _hasUpdatesError = false;
  
 

  late final ApiService _apiService;
  late final AuthService _authService;
  bool _isLoading = false;
  bool _useTestData = false; // Flag to use test data if API fails

  // Error and loading state variables - consolidated
  bool _hasLoadingError = false;
  String _errorMessage = '';

  // Add these properties for socket notifications
  late final SocketNotificationService _socketNotificationService;
  bool _socketConnected = false;
  final List<SocketNotification> _socketNotifications = [];
  StreamSubscription? _notificationSubscription;
  
  // Add cancellation tokens for async operations
  bool _isDisposed = false;
  List<Timer> _activeTimers = [];
  
  @override
  void initState() {
    super.initState();
    _apiService = Get.find<ApiService>();
    _authService = Get.find<AuthService>();
    
    // Initialize socket notification service
    try {
      _socketNotificationService = Get.find<SocketNotificationService>();
      _connectAndListenToSocket();
    } catch (e) {
      print('Error initializing socket notification service: $e');
    }

    // Use safer timer management
    _activeTimers.add(Timer(const Duration(milliseconds: 1000), () {
      if (mounted && !_isDisposed) {
        _apiService.debugUserInfo();
      }
    }));
    
    // Delay fetch to ensure all services are fully initialized
    _activeTimers.add(Timer(const Duration(milliseconds: 500), () {
      if (mounted && !_isDisposed) {
        _fetchEvents();
        _fetchRegisteredEventsWithTimeout();
        _fetchNotifications();
      }
    }));
  }
  
  void _connectAndListenToSocket() {
    // Register this widget with the socket service
    _socketNotificationService.registerUser();
    
    // Listen for connection status changes
    _socketNotificationService.isConnected.listen((connected) {
      if (mounted && !_isDisposed) {
        setState(() {
          _socketConnected = connected;
          print('Socket connection status: ${connected ? "Connected" : "Disconnected"}');
        });
      }
    });
    
    // Listen for incoming notifications - CHANGE EVENT NAME FROM 'notification' TO 'pushNotification'
    _notificationSubscription = _socketNotificationService.notificationStream.listen(
      (data) {
        print('Received notification data: $data');
        if (mounted && !_isDisposed) {
          setState(() {
            // Add to the beginning of our list
            _socketNotifications.insert(0, SocketNotification.fromMap(data));
            
            // Limit the list to 10 items to avoid memory issues
            if (_socketNotifications.length > 10) {
              _socketNotifications.removeLast();
            }
          });
          
          // Show a snackbar for immediate feedback
          _showNotificationSnackbar(_socketNotifications.first);
        }
      },
      onError: (error) {
        print('Error in socket notification stream: $error');
      }
    );
  }
  
  void _showNotificationSnackbar(SocketNotification notification) {
    Get.snackbar(
      '🔔 ${notification.title}',
      notification.message,
      snackPosition: SnackPosition.TOP,
      backgroundColor: AppColors.primary,
      colorText: Colors.white,
      duration: const Duration(seconds: 4),
      margin: const EdgeInsets.all(8),
      borderRadius: 8,
      dismissDirection: DismissDirection.horizontal,
    );
  }
  
  @override
  void dispose() {
    _isDisposed = true;
    
    // Cancel all active timers
    for (final timer in _activeTimers) {
      timer.cancel();
    }
    _activeTimers.clear();
    
    // Clean up socket subscription
    _notificationSubscription?.cancel();
    
    // Unregister from socket service
    try {
      _socketNotificationService.unregisterUser();
    } catch (e) {
      print('Error unregistering from socket service: $e');
    }
    
    super.dispose();
  }

  Future<void> _fetchEvents() async {
    if (!mounted || _isDisposed) return;
    
    setState(() {
      _isLoading = true;
      _hasLoadingError = false;
      _errorMessage = '';
    });

    try {
      print('Attempting to fetch events from backend...');
      
      // First try to get events from the API
      final apiEvents = await _apiService.getEvents();
      
      // Check if widget is still mounted before setState
      if (!mounted || _isDisposed) return;
      
      setState(() {
        if (apiEvents.isNotEmpty) {
          // Convert the API events to our local Event type
          _events = apiEvents.map((e) => Event(
            id: e.id,
            title: e.title,
            description: e.description,
            date: e.date,
            fromTime: e.fromTime,
            toTime: e.toTime,
            location: e.location,
            imageUrl: e.imageUrl,
            points: e.points,
          )).toList();
          
          _isLoading = false;
          _useTestData = false;
          print('Successfully loaded ${apiEvents.length} events from API');
        } else {
          // If no events from API, use test data
          print('No events from API, using test data');
          final testEvents = _apiService.getTestEvents();
          _events = testEvents.map((e) => Event(
            id: e.id,
            title: e.title,
            description: e.description,
            date: e.date,
            fromTime: e.fromTime,
            toTime: e.toTime,
            location: e.location,
            imageUrl: e.imageUrl,
            points: e.points,
          )).toList();
          
          _isLoading = false;
          _useTestData = true;
          _errorMessage = 'Using sample events (API returned no events)';
        }
      });
    } catch (e) {
      print('Error in _fetchEvents: $e');
      
      // Check if widget is still mounted before setState
      if (!mounted || _isDisposed) return;
      
      setState(() {
        // Use test data on error
        final testEvents = _apiService.getTestEvents();
        _events = testEvents.map((e) => Event(
          id: e.id,
          title: e.title,
          description: e.description,
          date: e.date,
          fromTime: e.fromTime,
          toTime: e.toTime,
          location: e.location,
          imageUrl: e.imageUrl,
          points: e.points,
        )).toList();
        
        _isLoading = false;
        _useTestData = true;
        _hasLoadingError = true;
        _errorMessage = 'Error fetching events: $e. Using sample events instead.';
      });
    }
  }

  // Modified method to fetch registered events with timeout
  Future<void> _fetchRegisteredEventsWithTimeout() async {
    if (!mounted || _isDisposed) return;
    
    setState(() {
      _isLoadingRegistered = true;
      _hasLoadingError = false;
      _errorMessage = '';
    });
    
    // Create a timeout with cancellation check
    Timer? timeoutTimer;
    timeoutTimer = Timer(const Duration(seconds: 15), () {
      if (!mounted || _isDisposed) return;
      
      if (_isLoadingRegistered) {
        setState(() {
          _isLoadingRegistered = false;
          _hasLoadingError = true;
          _errorMessage = 'Timed out while loading registered events';
          print('Loading registered events timed out');
        });
      }
    });
    
    try {
      final registeredApiEvents = await _apiService.getUserRegisteredEvents();
      
      // Cancel the timer if we got a response
      if (timeoutTimer.isActive) {
        timeoutTimer.cancel();
      } else {
        return; // Timer already fired
      }
      
      // Check if widget is still mounted before setState
      if (!mounted || _isDisposed) return;
      
      setState(() {
        // Convert API events to our local Event type
        _registeredEvents = registeredApiEvents.map((e) => Event(
          id: e.id,
          title: e.title,
          description: e.description,
          date: e.date,
          fromTime: e.fromTime,
          toTime: e.toTime,
          location: e.location,
          imageUrl: e.imageUrl,
          points: e.points,
        )).toList();
        
        // Update registration status map
        for (var event in _registeredEvents) {
          _eventRegistrationStatus[event.id] = true;
        }
        
        _isLoadingRegistered = false;
        
        // Log success message
        if (_registeredEvents.isNotEmpty) {
          print('Successfully loaded ${_registeredEvents.length} registered events');
        } else {
          print('No registered events found for user');
        }
      });
    } catch (e) {
      // Cancel the timer if we got an error
      if (timeoutTimer.isActive) {
        timeoutTimer.cancel();
      } else {
        return;
      }
      
      print('Error fetching registered events: $e');
      
      // Check if widget is still mounted before setState
      if (!mounted || _isDisposed) return;
      
      setState(() {
        _isLoadingRegistered = false;
        _hasLoadingError = true;
        _errorMessage = 'Error loading registered events. Some event details may be unavailable.';
      });
    }
  }

  // Check if user is registered for an event
  bool _isRegisteredForEvent(String eventId) {
    return _eventRegistrationStatus[eventId] == true;
  }

  // Register for event with 5-second timeout
  Future<void> _registerForEvent(Event event) async {
    try {
      final String? userId = await _authService.getUserId();
      
      if (userId == null) {
        Get.snackbar(
          'Error',
          'You need to be logged in to register for events',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withOpacity(0.1),
          colorText: AppColors.error,
        );
        return;
      }
      
      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      
      // Set up a 5-second timeout
      bool hasTimedOut = false;
      Timer timeoutTimer = Timer(const Duration(seconds: 5), () {
        hasTimedOut = true;
        // Close dialog if it's showing
        if (Get.isDialogOpen ?? false) {
          Navigator.of(Get.overlayContext!).pop();
        }
        
        // Show timeout error
        Get.snackbar(
          'Registration Timeout',
          'Request took too long. Please check your connection and try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withOpacity(0.1),
          colorText: AppColors.error,
        );
      });
      
      // Call API to register
      bool success = false;
      try {
        success = await _apiService.registerForEvent(userId, event.id);
      } catch (e) {
        // Re-throw to be handled by outer catch
        rethrow;
      } finally {
        // Cancel timeout timer if not already triggered
        if (!hasTimedOut && timeoutTimer.isActive) {
          timeoutTimer.cancel();
        }
      }
      
      // If we've timed out, don't proceed
      if (hasTimedOut) return;
      
      // Close loading dialog if it's open
      if (Get.isDialogOpen ?? false) {
        Navigator.of(Get.overlayContext!).pop();
      }
      
      if (success) {
        // Update local state
        setState(() {
          _eventRegistrationStatus[event.id] = true;
          if (!_registeredEvents.any((e) => e.id == event.id)) {
            _registeredEvents.add(event);
          }
        });
        
        Get.snackbar(
          'Success',
          'Successfully registered for "${event.title}"',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.success.withOpacity(0.1),
          colorText: AppColors.success,
        );
      } else {
        Get.snackbar(
          'Registration Failed',
          'Could not register for the event. Please try again later.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withOpacity(0.1),
          colorText: AppColors.error,
        );
      }
    } catch (e) {
      // If the dialog is still open, close it
      if (Get.isDialogOpen ?? false) {
        Navigator.of(Get.overlayContext!).pop();
      }
      
      if (e is AlreadyRegisteredException) {
        // Handle already registered case
        setState(() {
          _eventRegistrationStatus[event.id] = true;
          if (!_registeredEvents.any((e) => e.id == event.id)) {
            _registeredEvents.add(event);
          }
        });
        
        Get.snackbar(
          'Already Registered',
          'You are already registered for this event',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.warning.withOpacity(0.1),
          colorText: AppColors.warning,
        );
      } else {
        // Handle other errors
        print('Error in _registerForEvent: $e');
        Get.snackbar(
          'Error',
          'An error occurred during registration',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withOpacity(0.1),
          colorText: AppColors.error,
        );
      }
    }
  }

  // Show event details dialog - UPDATED to show points
  void _showEventDialog(Event event) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final bool isRegistered = _isRegisteredForEvent(event.id);
        
        return AlertDialog(
          title: Text(event.title),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Event image - UPDATED to use imageUrl
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isRegistered 
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    image: event.imageUrl != null && event.imageUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(event.imageUrl!),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Colors.black.withOpacity(0.15),
                              BlendMode.darken,
                            ),
                          )
                        : null,
                  ),
                  child: event.imageUrl == null || event.imageUrl!.isEmpty
                      ? Center(
                          child: Icon(
                            Icons.event,
                            size: 50,
                            color: AppColors.primary.withOpacity(0.5),
                          ),
                        )
                      : null,
                ),
                const SizedBox(height: 16),
                
                // Event details
                const Text(
                  'Description:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  event.description,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                
                // Points section - NEW
                if (event.points != null && event.points! > 0) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.stars,
                        size: 16,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Points: ${event.points}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Event date and location
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Date: ${event.date}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Time: ${event.fromTime} - ${event.toTime}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Location: ${event.location}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
            // Only show register button if not already registered
            if (!isRegistered)
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _registerForEvent(event);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                ),
                child: const Text('Register'),
              )
            else
              // Show "Already Registered" button that's disabled
              ElevatedButton(
                onPressed: null, // Disabled
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success.withOpacity(0.5),
                  foregroundColor: AppColors.white,
                  disabledBackgroundColor: AppColors.success.withOpacity(0.3),
                  disabledForegroundColor: AppColors.white.withOpacity(0.7),
                ),
                child: const Text('Already Registered'),
              ),
          ],
        );
      },
    );
  }

  Future<void> _fetchNotifications() async {
    if (!mounted || _isDisposed) return;
    
    setState(() {
      _isLoadingUpdates = true;
      _hasUpdatesError = false;
    });
    
    try {
      final notificationsData = await _apiService.getNotifications();
      
      if (!mounted || _isDisposed) return;
      
      // Convert API data to Update objects
      final List<Update> updates = notificationsData.map((notification) {
        // Format the timestamp
        String formattedTime = 'Recently';
        try {
          if (notification['time'] != null) {
            final time = DateTime.parse(notification['time']);
            final now = DateTime.now();
            final difference = now.difference(time);
            
            if (difference.inMinutes < 60) {
              formattedTime = '${difference.inMinutes} minutes ago';
            } else if (difference.inHours < 24) {
              formattedTime = '${difference.inHours} hours ago';
            } else if (difference.inDays < 7) {
              formattedTime = '${difference.inDays} days ago';
            } else {
              formattedTime = '${time.day}/${time.month}/${time.year}';
            }
          }
        } catch (e) {
          print('Error formatting notification time: $e');
        }
        
        return Update(
          id: notification['id'].toString(),
          title: notification['title'] ?? 'Notification',
          message: notification['message'] ?? 'No message',
          time: formattedTime,
          isRead: false, // Always set to false to use blue styling
        );
      }).toList();
      
      setState(() {
        _updates = updates;
        _isLoadingUpdates = false;
      });
      
      print('Loaded ${updates.length} notifications from API');
    } catch (e) {
      print('Error fetching notifications: $e');
      if (!mounted || _isDisposed) return;
      
      setState(() {
        _isLoadingUpdates = false;
        _hasUpdatesError = true;
      });
    }
  }

  // Update the _formatEventTime method to handle both a single time or a time range
  String _formatEventTime(String fromTime, [String? toTime]) {
    // Format the fromTime
    String formattedFromTime = _formatSingleTime(fromTime);
    
    // If toTime is provided, format it and return a range
    if (toTime != null && toTime.isNotEmpty && toTime != '00:00:00') {
      String formattedToTime = _formatSingleTime(toTime);
      return '$formattedFromTime - $formattedToTime';
    }
    
    // Otherwise just return the formatted fromTime
    return formattedFromTime;
  }

  // Helper method to format a single time string
  String _formatSingleTime(String time) {
    // Check if the time is in the expected format
    if (time == '00:00:00' || time.isEmpty) {
      return 'TBD';
    }
    
    try {
      // Parse the time string (expected format: HH:MM:SS)
      final parts = time.split(':');
      if (parts.length >= 2) {
        // Convert to 12-hour format
        int hour = int.parse(parts[0]);
        final minutes = parts[1];
        final period = hour >= 12 ? 'PM' : 'AM';
        
        // Convert hour to 12-hour format
        hour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
        
        return '$hour:$minutes $period';
      }
      return time; // Return as-is if not in expected format
    } catch (e) {
      print('Error formatting time: $e');
      return time; // Return original string if parsing fails
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.cardBackground,
        onRefresh: () async {
          // Reset error state on refresh
          setState(() {
            _hasLoadingError = false;
            _errorMessage = '';
          });
          
          // Refresh both events and registered events with timeout
          await Future.wait([
            _fetchEvents(),
            _fetchRegisteredEventsWithTimeout(),
          ]);
        },
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.background,
                    AppColors.background.withOpacity(0.95),
                  ],
                ),
              ),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome message with NSS branding
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.volunteer_activism,
                            color: AppColors.primary,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome to NSS',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Not Me But You - National Service Scheme',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Add socket indicator
                        if (_socketNotifications.isNotEmpty || _socketConnected)
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: _socketConnected 
                                  ? AppColors.success.withOpacity(0.1)
                                  : AppColors.warning.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _socketConnected ? Icons.wifi : Icons.wifi_off,
                              size: 16,
                              color: _socketConnected ? AppColors.success : AppColors.warning,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Socket Notifications (only show if we have any)
                    if (_socketNotifications.isNotEmpty) ...[
                      _buildSectionHeader('Live Notifications', Icons.notifications_active),
                      const SizedBox(height: 16),
                      _buildSocketNotificationsCard(_socketNotifications),
                      const SizedBox(height: 28),
                    ],
                    
                    // Updates section (original)
                    _buildSectionHeader('Recent Updates', Icons.announcement),
                    const SizedBox(height: 16),
                    _buildUpdatesCard(_updates),
                    const SizedBox(height: 28),
                    
                    // Current Events section
                    _buildSectionHeader('Current Events', Icons.event_available_rounded),
                    const SizedBox(height: 16),
                    
                    // Show error message if present
                    if (_errorMessage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          _errorMessage,
                          style: TextStyle(
                            color: AppColors.error,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    
                    // Event list with loading indicator
                    _isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : SizedBox(
                          height: 210,
                          child: _events.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.event_busy,
                                      size: 40,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 12),
                                    const Text(
                                      'No events available',
                                      style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Please check your internet connection and try again',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                        fontSize: 12,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    TextButton.icon(
                                      onPressed: _fetchEvents,
                                      icon: Icon(Icons.refresh, size: 16),
                                      label: Text('Refresh'),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _events.length,
                                itemBuilder: (context, index) {
                                  return _buildEnhancedEventCard(
                                    _events[index], 
                                    _isRegisteredForEvent(_events[index].id)
                                  );
                                },
                              ),
                        ),
                    
                    const SizedBox(height: 28),
                    
                    // Always show Registered Events section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionHeader('Your Registered Events', Icons.check_circle_outline),
                        const SizedBox(height: 16),
                        
                        // Registered events list
                        SizedBox(
                          height: 210, // Increased from 190 to 210
                          child: _isLoadingRegistered
                            ? const Center(child: CircularProgressIndicator())
                            : _registeredEvents.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.event_note,
                                        size: 40,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 8),
                                      const Text(
                                        'No registered events',
                                        style: TextStyle(
                                          color: Colors.grey,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Register for events to see them here',
                                        style: TextStyle(
                                          color: Colors.grey.shade500,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: _registeredEvents.length,
                                  itemBuilder: (context, index) {
                                    return _buildRegisteredEventCard(_registeredEvents[index]);
                                  },
                                ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                    
                   
                  ],
                ),
              ),
            ),
      ),
      // Remove the floating action button - it's only for testing notifications
    );
  }

  // Section header with icon and divider
  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppColors.primary,
          size: 22,
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.5),
                  AppColors.primary.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Updates card
  Widget _buildUpdatesCard(List<Update> updates) {
    return Card(
      elevation: 3,
      shadowColor: AppColors.primary.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // View All button
                if (updates.length > 4)
                  TextButton(
                    onPressed: () {
                      // TODO: Navigate to all updates page
                    },
                    child: const Text('View All'),
                  ),
              ],
            ),
            
            // Show loading indicator if notifications are being fetched
            if (_isLoadingUpdates)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            // Show error message if failed to load notifications
            else if (_hasUpdatesError)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Failed to load notifications',
                        style: TextStyle(color: AppColors.error),
                      ),
                      TextButton(
                        onPressed: _fetchNotifications,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              )
            // Show message if no notifications available
            else if (updates.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Text(
                    'No updates available',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            // Show notifications, limited to first 4
            else
              Column(
                children: updates.take(4).map((update) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      // Always use the blue styling (for unread notifications)
                      color: AppColors.primary.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.notifications,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      update.title,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    update.time,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                update.message,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  // Add a new widget to display socket notifications
  Widget _buildSocketNotificationsCard(List<SocketNotification> notifications) {
    return Card(
      elevation: 3,
      shadowColor: AppColors.primary.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Socket connection status indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _socketConnected 
                        ? AppColors.success.withOpacity(0.1) 
                        : AppColors.warning.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _socketConnected ? Icons.circle : Icons.circle_outlined,
                        size: 10,
                        color: _socketConnected ? AppColors.success : AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _socketConnected ? 'Connected' : 'Connecting...',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _socketConnected ? AppColors.success : AppColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
                
                if (notifications.length > 3)
                  TextButton(
                    onPressed: () {
                      // Clear all notifications
                      setState(() {
                        _socketNotifications.clear();
                      });
                    },
                    child: const Text('Clear All'),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            
            ...notifications.take(3).map((notification) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_active,
                        color: AppColors.primary,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Text(
                                'Just now',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            notification.message,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Helper method to get event images based on title - FIXED
  DecorationImage? _getEventImage(String title, String? imageUrl) {
    // If there's a valid image URL, try to use it
    if (imageUrl != null && imageUrl.isNotEmpty) {
      try {
        return DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.15),
            BlendMode.darken,
          ),
        );
      } catch (e) {
        print('Error with network image: $e');
        // Fall back to default image
        return _getDefaultEventImage(title);
      }
    }
    
    // Use default image logic
    return _getDefaultEventImage(title);
  }

  // Helper method to get default event images based on title - SIMPLIFIED
  DecorationImage _getDefaultEventImage(String title) {
    String imagePath;
    
    // Simplified logic with fallback to a known working image
    if (title.toLowerCase().contains('tree') || title.toLowerCase().contains('plantation')) {
      imagePath = 'assets/images/tree_plantation.jpg';
    } else if (title.toLowerCase().contains('nss') || title.toLowerCase().contains('meetup')) {
      imagePath = 'assets/images/nss_meetup.jpg';
    } else if (title.toLowerCase().contains('campus') || title.toLowerCase().contains('cleanup')) {
      imagePath = 'assets/images/campus_cleanup.jpg';
    } else {
      // Use a simple color background instead of potentially missing image
      return DecorationImage(
        image: AssetImage('assets/images/wooden_shelf.png'),
        fit: BoxFit.cover,
        colorFilter: ColorFilter.mode(
          Colors.black.withOpacity(0.15),
          BlendMode.darken,
        ),
        onError: (exception, stackTrace) {
          print('Error loading default image: $exception');
        },
      );
    }
    
    return DecorationImage(
      image: AssetImage(imagePath),
      fit: BoxFit.cover,
      colorFilter: ColorFilter.mode(
        Colors.black.withOpacity(0.15),
        BlendMode.darken,
      ),
      onError: (exception, stackTrace) {
        print('Error loading asset image $imagePath: $exception');
      },
    );
  }

  // Update the _buildEnhancedEventCard method to show points
  Widget _buildEnhancedEventCard(Event event, bool isRegistered) {
    return Container(
      height: 220,
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 8,
        shadowColor: AppColors.primary.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: InkWell(
          onTap: () => _showEventDialog(event),
          child: Stack(
            children: [
              // Background image with gradient overlay
              Container(
                height: 220,
                width: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    // Event image
                    _buildEventImageWidget(event),
                    
                    // Gradient overlay for better text readability
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.3),
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.0, 0.5, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Event title
                      Text(
                        event.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      
                      // Points badge - NEW
                      if (event.points != null && event.points! > 0) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.stars,
                                color: Colors.white,
                                size: 14,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${event.points} pts',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 6),
                      ],
                      
                      // Date and time
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.white.withOpacity(0.9),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              event.date,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.white.withOpacity(0.9),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              event.location,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Details button
                          TextButton(
                            onPressed: () => _showEventDialog(event),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.white.withOpacity(0.2),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(color: Colors.white.withOpacity(0.3)),
                              ),
                            ),
                            child: const Text('Details'),
                          ),
                          
                          // Register/Registered button
                          if (!isRegistered)
                            ElevatedButton(
                              onPressed: () => _registerForEvent(event),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                elevation: 4,
                              ),
                              child: const Text('Register'),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.success,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.success.withOpacity(0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  const Text(
                                    'Registered',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Status badge (top right)
              if (isRegistered)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Text(
                      'REGISTERED',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
    ));
  }

  // Enhanced image widget with proper banner_image loading - FIXED
  Widget _buildEventImageWidget(Event event) {
    // print('Building image widget for event: ${event.title}');
    // print('Image URL: ${event.imageUrl}');
    
    // Try to load banner image from API first
    if (event.imageUrl != null && event.imageUrl!.isNotEmpty) {
      // Clean and validate the URL
      String imageUrl = event.imageUrl!.trim();
      
      // Add protocol if missing
      if (!imageUrl.startsWith('http://') && !imageUrl.startsWith('https://')) {
        if (imageUrl.startsWith('//')) {
          imageUrl = 'https:$imageUrl';
        } else if (imageUrl.startsWith('/')) {
          // Relative URL - might need to prepend your server URL
          // imageUrl = 'http://localhost:8081$imageUrl'; // Uncomment if needed
        } else {
          imageUrl = 'https://$imageUrl';
        }
      }
      
      print('Cleaned image URL: $imageUrl');
      
      return ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.network(
          imageUrl,
          width: 280,
          height: 220,
          fit: BoxFit.cover,
          headers: {
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36',
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) {
              print('Image loaded successfully: $imageUrl');
              return child;
            }
            
            final progress = loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                : null;
            
            //print('Loading image: ${(progress ?? 0) * 100}%');
            
            return Container(
              width: 280,
              height: 220,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 3,
                      color: AppColors.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Loading image...',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 12,
                      ),
                    ),
                    if (progress != null)
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            print('Failed to load banner image: $imageUrl');
            print('Error: $error');
            print('Stack trace: $stackTrace');
            
            // Try a fallback approach for common image hosting issues
            if (imageUrl.contains('imgur') || imageUrl.contains('drive.google')) {
              print('Detected common image host, falling back to default design');
            }
            
            // Fall back to default aesthetic design
            return _buildDefaultEventDesign(event.title);
          },
        ),
      );
    }
    
    print('No image URL provided, using default design');
    // Use default design if no banner image
    return _buildDefaultEventDesign(event.title);
  }

  // Beautiful default design when no image is available
  Widget _buildDefaultEventDesign(String title) {
    // Choose gradient colors based on event type
    List<Color> gradientColors;
    IconData eventIcon;
    
    if (title.toLowerCase().contains('tree') || title.toLowerCase().contains('plantation') || title.toLowerCase().contains('environment')) {
      gradientColors = [Colors.green.shade400, Colors.green.shade700];
      eventIcon = Icons.eco;
    } else if (title.toLowerCase().contains('blood') || title.toLowerCase().contains('donation') || title.toLowerCase().contains('health')) {
      gradientColors = [Colors.red.shade400, Colors.red.shade700];
      eventIcon = Icons.favorite;
    } else if (title.toLowerCase().contains('education') || title.toLowerCase().contains('teaching') || title.toLowerCase().contains('workshop')) {
      gradientColors = [Colors.blue.shade400, Colors.blue.shade700];
      eventIcon = Icons.school;
    } else if (title.toLowerCase().contains('food') || title.toLowerCase().contains('meal') || title.toLowerCase().contains('nutrition')) {
      gradientColors = [Colors.orange.shade400, Colors.orange.shade700];
      eventIcon = Icons.restaurant;
    } else if (title.toLowerCase().contains('community') || title.toLowerCase().contains('social') || title.toLowerCase().contains('awareness')) {
      gradientColors = [Colors.purple.shade400, Colors.purple.shade700];
      eventIcon = Icons.people;
    } else {
      // Default NSS theme
      gradientColors = [AppColors.primary, AppColors.primary.withOpacity(0.7)];
      eventIcon = Icons.volunteer_activism;
    }
    
    return Container(
      width: 280,
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradientColors,
        ),
      ),
      child: Stack(
        children: [
          // Decorative pattern
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -30,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          
          // Main event icon
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    eventIcon,
                    size: 48,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'NSS EVENT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Enhanced registered event card with better styling
  Widget _buildRegisteredEventCard(Event event) {
    return Container(
      height: 220,
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 8,
        shadowColor: AppColors.success.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: AppColors.success.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: InkWell(
          onTap: () => _showEventDialog(event),
          child: Stack(
            children: [
              // Background image with green tint
              Container(
                height: 220,
                width: 280,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Stack(
                  children: [
                    // Event image
                    _buildEventImageWidget(event),
                    
                    // Green success overlay
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppColors.success.withOpacity(0.1),
                            AppColors.success.withOpacity(0.3),
                            Colors.black.withOpacity(0.7),
                          ],
                          stops: const [0.0, 0.3, 1.0],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              // Content overlay (same as regular event card)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Event title
                      Text(
                        event.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      
                      // Date and time
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: Colors.white.withOpacity(0.9),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              event.date,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Location
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.white.withOpacity(0.9),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              event.location,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      
                      // View Details button
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () => _showEventDialog(event),
                          icon: const Icon(Icons.visibility, size: 18),
                          label: const Text('View Details'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.success,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            elevation: 4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Registered badge (top right)
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.white,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        'REGISTERED',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    ));
  }
}

// Model classes

class Event {
  final String id;
  final String title;
  final String description;
  final String date;
  final String fromTime;
  final String toTime;
  final String location;
  final String? imageUrl;
  final int? points; // Add points field

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.fromTime,
    required this.toTime,
    required this.location,
    this.imageUrl,
    this.points,
  });
}

class Quest {
  final String id;
  final String title;
  final String description;
  final int points;
  final bool isCompleted;
  final bool isSuggestion;
  final String? completedDate;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.isCompleted,
    this.isSuggestion = false,
    this.completedDate,
  });
}

class Badge {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;

  Badge({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
  });
}

// New model classes for NSS app

class Update {
  final String id;
  final String title;
  final String message;
  final String time;
  final bool isRead;

  Update({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
  });
}

class User {
  final String id;
  final String name;
  final int points;
  final String? imageUrl;
  final int rank;

  User({
    required this.id,
    required this.name,
    required this.points,
    this.imageUrl,
    required this.rank,
  });
}

class EventParticipation {
  final String eventId;
  final String eventName;
  final int pointsEarned;
  final String date;

  EventParticipation({
    required this.eventId,
    required this.eventName,
    required this.pointsEarned,
    required this.date,
  });
}

class DailyPoints {
  final String day;
  final int points;

  DailyPoints({
    required this.day,
    required this.points,
  });
}

class Tip {
  final String id;
  final String shortText;
  final String longText;
  final String questTitle;
  final String questDescription;
  final int questPoints;

  Tip({
    required this.id,
    required this.shortText,
    required this.longText,
    required this.questTitle,
    required this.questDescription,
    required this.questPoints,
  });
}

// Add this model class for socket notifications
class SocketNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;

  SocketNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
  });

  factory SocketNotification.fromMap(Map<String, dynamic> map) {
    return SocketNotification(
      id: map['id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString(),
      title: map['title']?.toString() ?? 'New Notification',
      message: map['message']?.toString() ?? map['content']?.toString() ?? 'You have a new notification',
      timestamp: map['time'] != null 
          ? DateTime.tryParse(map['time']) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}