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
  
  // Update data is kept as is for now
  final List<Update> _updates = [
    Update(
      id: 'n1',
      title: 'New Event Registration Open',
      message: 'Tree Plantation Drive registration is now open. Register before June 3rd.',
      time: '2 hours ago',
      isRead: false,
    ),
    Update(
      id: 'n2',
      title: 'Reminder: NSS Meetup',
      message: 'Don\'t forget to attend the NSS Annual Meetup on June 12th.',
      time: '1 day ago',
      isRead: true,
    ),
    Update(
      id: 'n3',
      title: 'Certificate Available',
      message: 'Your participation certificate for Blood Donation Camp is available for download.',
      time: '3 days ago',
      isRead: true,
    ),
  ];

  // TODO: Fetch top users from backend API
  // Sample top users by points
  final List<User> _topUsers = [
    User(
      id: 'u1',
      name: 'Rajesh Kumar',
      points: 780,
      imageUrl: 'assets/images/profile1.jpg',
      rank: 1,
    ),
    User(
      id: 'u2',
      name: 'Priya Singh',
      points: 720,
      imageUrl: 'assets/images/profile2.jpg',
      rank: 2,
    ),
    User(
      id: 'u3',
      name: 'Amit Sharma',
      points: 690,
      imageUrl: 'assets/images/profile3.jpg',
      rank: 3,
    ),
  ];

  // TODO: Fetch user points data from backend API
  // Sample current month points data
  final int _currentMonthPoints = 180;
  
  // TODO: Fetch recent event participation from backend API
  // Sample recent event participation
  final List<EventParticipation> _recentParticipations = [
    EventParticipation(
      eventId: 'e1',
      eventName: 'Blood Donation Camp',
      pointsEarned: 50,
      date: 'May 15, 2023',
    ),
    EventParticipation(
      eventId: 'e2',
      eventName: 'Food Distribution Drive',
      pointsEarned: 75,
      date: 'May 22, 2023',
    ),
    EventParticipation(
      eventId: 'e3',
      eventName: 'Environmental Awareness Workshop',
      pointsEarned: 55,
      date: 'May 28, 2023',
    ),
  ];

  // Sample badges earned
  final List<Badge> _badges = [
    Badge(
      id: 'b1',
      title: 'NSS Volunteer',
      description: 'Completed 5 NSS activities',
      imageUrl: 'assets/images/badges/nss_volunteer.png',
    ),
    Badge(
      id: 'b2',
      title: 'Social Worker',
      description: 'Participated in 3 social service activities',
      imageUrl: 'assets/images/badges/social_worker.png',
    ),
    Badge(
      id: 'b3',
      title: 'Community Leader',
      description: 'Led community activities',
      imageUrl: 'assets/images/badges/community_leader.png',
    ),
  ];

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

    Timer(const Duration(milliseconds: 1000), () {
      _apiService.debugUserInfo(); // Add this line for debugging
    });
    
    // Delay fetch to ensure all services are fully initialized
    Timer(const Duration(milliseconds: 500), () {
      _fetchEvents();
      _fetchRegisteredEventsWithTimeout();
    });
  }
  
  void _connectAndListenToSocket() {
    // Register this widget with the socket service
    _socketNotificationService.registerUser();
    
    // Listen for connection status changes
    _socketNotificationService.isConnected.listen((connected) {
      if (mounted) {
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
        if (mounted) {
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
    setState(() {
      _isLoading = true;
      _hasLoadingError = false;
      _errorMessage = '';
    });

    try {
      print('Attempting to fetch events from backend...');
      
      // First try to get events from the API
      final apiEvents = await _apiService.getEvents();
      
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
          )).toList();
          
          _isLoading = false;
          _useTestData = true;
          _errorMessage = 'Using sample events (API returned no events)';
        }
      });
    } catch (e) {
      print('Error in _fetchEvents: $e');
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
    setState(() {
      _isLoadingRegistered = true;
      _hasLoadingError = false;
      _errorMessage = '';
    });
    
    // Create a timeout
    Timer timeoutTimer = Timer(const Duration(seconds: 15), () {
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
        // Timer already fired, so we're already showing an error
        return;
      }
      
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
        // Timer already fired
        return;
      }
      
      print('Error fetching registered events: $e');
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

  // Show event details dialog
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
                // Event image placeholder
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isRegistered 
                        ? AppColors.success.withOpacity(0.1)
                        : AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Icon(
                          Icons.event,
                          size: 50,
                          color: isRegistered 
                              ? AppColors.success.withOpacity(0.5)
                              : AppColors.primary.withOpacity(0.5),
                        ),
                      ),
                      if (isRegistered)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  size: 12,
                                  color: AppColors.success,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Registered',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
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
                          height: 210, // Increased from 190 to 210
                          child: _events.isEmpty
                            ? Center(
                                child: Text(
                                  'No events available',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontStyle: FontStyle.italic,
                                  ),
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
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const CircularProgressIndicator(),
                                    const SizedBox(height: 12),
                                    Text(
                                      'Loading your registered events...',
                                      style: TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : _registeredEvents.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.event_note,
                                        size: 40,
                                        color: AppColors.textSecondary.withOpacity(0.5),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        'You haven\'t registered for any events yet',
                                        style: TextStyle(
                                          color: AppColors.textSecondary,
                                          fontSize: 14,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Register for events above to see them here',
                                        style: TextStyle(
                                          color: AppColors.textSecondary.withOpacity(0.7),
                                          fontSize: 12,
                                        ),
                                        textAlign: TextAlign.center,
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
      // Add a floating action button to test socket connection
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_socketConnected) {
            _socketNotificationService.sendTestNotification();
            Get.snackbar(
              'Test',
              'Sent test notification request',
              snackPosition: SnackPosition.BOTTOM,
            );
          } else {
            _socketNotificationService.reconnect();
            Get.snackbar(
              'Socket',
              'Attempting to reconnect to notification server',
              snackPosition: SnackPosition.BOTTOM,
            );
          }
        },
        backgroundColor: _socketConnected ? AppColors.success : AppColors.warning,
        child: Icon(
          _socketConnected ? Icons.send : Icons.refresh,
          color: Colors.white,
        ),
      ),
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
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Text(
                //   'Recent Updates',
                //   style: TextStyle(
                //     fontWeight: FontWeight.bold,
                //     fontSize: 16,
                //     color: AppColors.primary,
                //   ),
                // ),

                //Text button to view all
                // TextButton(
                //   onPressed: () {
                //     // TODO: Navigate to all updates page
                //   },
                //   child: const Text('View All'),
                // ),
              ],
            ),
            const SizedBox(height: 10),
            ...updates.take(3).map((update) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: update.isRead 
                    ? AppColors.background 
                    : AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: update.isRead 
                      ? AppColors.divider 
                      : AppColors.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: update.isRead 
                          ? AppColors.textSecondary.withOpacity(0.1)
                          : AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications,
                        color: update.isRead 
                          ? AppColors.textSecondary
                          : AppColors.primary,
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
                                  style: TextStyle(
                                    fontWeight: update.isRead ? FontWeight.normal : FontWeight.bold,
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

  // Helper method to get event images based on title
  DecorationImage? _getEventImage(String title) {
    String imagePath;
    
    if (title.contains('Tree')) {
      imagePath = 'assets/images/tree_plantation.jpg';
    } else if (title.contains('NSS')) {
      imagePath = 'assets/images/nss_meetup.jpg';
    } else if (title.contains('Campus')) {
      imagePath = 'assets/images/campus_cleanup.jpg';
    } else {
      // Default image
      imagePath = 'assets/images/wooden_shelf.png';
    }
    
    return DecorationImage(
      image: AssetImage(imagePath),
      fit: BoxFit.cover,
      colorFilter: ColorFilter.mode(
        Colors.black.withOpacity(0.15),
        BlendMode.darken,
      ),
    );
  }

  // Helper method to format event time
  String _formatEventTime(String fromTime, String toTime) {
    // Convert API time format to more readable format
    String formatTimeString(String time) {
      if (time.isEmpty) return '';
      
      // If it's already in readable format, return as is
      if (!time.contains(':')) return time;
      
      try {
        final parts = time.split(':');
        if (parts.length >= 2) {
          int hour = int.parse(parts[0]);
          final minutes = parts[1];
          final amPm = hour >= 12 ? 'PM' : 'AM';
          hour = hour % 12;
          if (hour == 0) hour = 12;
          return '$hour:$minutes $amPm';
        }
      } catch (e) {
        print('Error formatting time: $e');
      }
      return time;
    }
    
    return '${formatTimeString(fromTime)} - ${formatTimeString(toTime)}';
  }
  
  // Fix the closing parentheses in these methods
  Widget _buildEnhancedEventCard(Event event, bool isRegistered) {
    return Container(
      height: 210, // Increased from 195 to 210
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        shadowColor: AppColors.blackOpacity10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: InkWell(
          onTap: () => _showEventDialog(event),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min, // Use min to avoid stretching
            children: [
              // Event image with overlay gradient
              Stack(
                children: [
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.15),
                      image: _getEventImage(event.title),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 30,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppColors.cardBackground.withOpacity(0.9),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Date badge
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            event.date,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Event details with compact layout to avoid overflow
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 4), // Reduced padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min, // Use min size
                    children: [
                      // Title
                      Text(
                        event.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2), // Reduced from 4
                      
                      // Time row
                      Row(
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              _formatEventTime(event.fromTime, event.toTime),
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      
                      // Location row
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(width: 2),
                          Expanded(
                            child: Text(
                              event.location,
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 4), // Reduced spacing
                      
                      const Spacer(), // Push buttons to bottom
                      
                      // Button row with both details and register
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          TextButton(
                            onPressed: () => _showEventDialog(event),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0), // Reduced vertical padding
                              visualDensity: VisualDensity.compact,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              minimumSize: Size.zero,
                            ),
                            child: const Text('Details', style: TextStyle(fontSize: 12)),
                          ),
                          // Show different button based on registration status
                          if (!isRegistered)
                            ElevatedButton(
                              onPressed: () => _registerForEvent(event),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0), // Reduced vertical padding
                                visualDensity: VisualDensity.compact,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                textStyle: const TextStyle(fontSize: 12),
                                minimumSize: const Size(60, 24),
                              ),
                              child: const Text('Register'),
                            )
                          else
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.success.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: AppColors.success.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_outline,
                                    color: AppColors.success,
                                    size: 12,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Registered',
                                    style: TextStyle(
                                      color: AppColors.success,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4), // Added small bottom padding
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
    ));
  }

  // Registered event card with confirmation UI
  Widget _buildRegisteredEventCard(Event event) {
    bool isPlaceholder = event.title.contains('Details Unavailable') || 
                        event.title.contains('Registered Event #');
    
    return Container(
      height: 210,
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        shadowColor: isPlaceholder 
            ? AppColors.warning.withOpacity(0.3)
            : AppColors.success.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isPlaceholder 
                ? AppColors.warning.withOpacity(0.3)
                : AppColors.success.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: () => _showEventDialog(event),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Event image with registration badge
              Stack(
                children: [
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isPlaceholder 
                          ? AppColors.warning.withOpacity(0.05)
                          : AppColors.success.withOpacity(0.05),
                      image: isPlaceholder ? null : _getEventImage(event.title),
                    ),
                    child: isPlaceholder 
                        ? Icon(
                            Icons.event_note,
                            size: 40,
                            color: AppColors.warning.withOpacity(0.5),
                          )
                        : null,
                  ),
                  // Registration badge
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isPlaceholder 
                            ? AppColors.warning.withOpacity(0.2)
                            : AppColors.success.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isPlaceholder ? Icons.warning : Icons.check_circle,
                            size: 12,
                            color: isPlaceholder ? AppColors.warning : AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Registered',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isPlaceholder ? AppColors.warning : AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Date badge - only show if not placeholder
                  if (!isPlaceholder && event.date != 'TBD')
                    Positioned(
                      bottom: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.cardBackground.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              event.date,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              // Event details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 6, 12, 4), // Reduced padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: isPlaceholder ? AppColors.warning : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      if (!isPlaceholder && event.fromTime != '00:00:00') ...[
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                _formatEventTime(event.fromTime, event.toTime),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                      ],
                      if (!isPlaceholder && event.location != 'TBD') ...[
                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 12,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                event.location,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ] else if (isPlaceholder) ...[
                        Text(
                          'Event details temporarily unavailable',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const Spacer(),
                      Center(
                        child: TextButton.icon(
                          onPressed: () => _showEventDialog(event),
                          icon: Icon(
                            isPlaceholder ? Icons.info_outline : Icons.visibility, 
                            size: 14, 
                            color: isPlaceholder ? AppColors.warning : AppColors.primary
                          ),
                          label: Text(
                            isPlaceholder ? 'View Info' : 'View Details',
                            style: TextStyle(
                              color: isPlaceholder ? AppColors.warning : AppColors.primary, 
                              fontSize: 12
                            ),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
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

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.fromTime,
    required this.toTime,
    required this.location,
    this.imageUrl,
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