import 'dart:math' as Math;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/services/api_service.dart';
import 'package:mentalsustainability/services/auth_service.dart';
import 'package:mentalsustainability/theme/app_colors.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Empty list to be filled from API
  List<Event> _events = [];
  List<Event> _registeredEvents = [];
  Map<String, bool> _eventRegistrationStatus = {};
  bool _isLoadingRegistered = false;
  
  // Notification data is kept as is for now
  final List<Notification> _notifications = [
    Notification(
      id: 'n1',
      title: 'New Event Registration Open',
      message: 'Tree Plantation Drive registration is now open. Register before June 3rd.',
      time: '2 hours ago',
      isRead: false,
    ),
    Notification(
      id: 'n2',
      title: 'Reminder: NSS Meetup',
      message: 'Don\'t forget to attend the NSS Annual Meetup on June 12th.',
      time: '1 day ago',
      isRead: true,
    ),
    Notification(
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

  @override
  void initState() {
    super.initState();
    _apiService = Get.find<ApiService>();
    _authService = Get.find<AuthService>();
    
    // Delay fetch to ensure all services are fully initialized
    Timer(const Duration(milliseconds: 500), () {
      _fetchEvents();
      _fetchRegisteredEventsWithTimeout();
    });
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
      final events = await _apiService.getEvents();
      
      setState(() {
        if (events.isNotEmpty) {
          _events = events;
          _isLoading = false;
          _useTestData = false;
          print('Successfully loaded ${events.length} events from API');
        } else {
          // If no events from API, use test data
          print('No events from API, using test data');
          _events = _apiService.getTestEvents();
          _isLoading = false;
          _useTestData = true;
          _errorMessage = 'Using sample events (API returned no events)';
        }
      });
    } catch (e) {
      print('Error in _fetchEvents: $e');
      setState(() {
        // Use test data on error
        _events = _apiService.getTestEvents();
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
    Timer timeoutTimer = Timer(const Duration(seconds: 10), () {
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
      final registeredEvents = await _apiService.getUserRegisteredEvents();
      
      // Cancel the timer if we got a response
      if (timeoutTimer.isActive) {
        timeoutTimer.cancel();
      } else {
        // Timer already fired, so we're already showing an error
        return;
      }
      
      setState(() {
        _registeredEvents = registeredEvents;
        
        // Update registration status map
        for (var event in registeredEvents) {
          _eventRegistrationStatus[event.id] = true;
        }
        
        _isLoadingRegistered = false;
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
        _errorMessage = 'Error loading registered events: ${e.toString()}';
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
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Notifications section
                    _buildSectionHeader('Recent Updates', Icons.notifications_active),
                    const SizedBox(height: 16),
                    _buildNotificationsCard(_notifications),
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
                    
                    // Dashboard Section
                    _buildSectionHeader('Your Dashboard', Icons.dashboard_rounded),
                    const SizedBox(height: 16),
                    
                    // Monthly Points Card
                    _buildMonthlyPointsCard(_currentMonthPoints),
                    const SizedBox(height: 20),
                    
                    // Leaderboard Card - Top 3 Users
                    _buildLeaderboardCard(_topUsers),
                    const SizedBox(height: 20),
                    
                    // Recent Event Participation
                    _buildRecentParticipationCard(_recentParticipations),
                    const SizedBox(height: 20),
                    
                    // Badges Earned
                    _buildEnhancedBadgesCard(_badges),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
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

  // Notifications card
  Widget _buildNotificationsCard(List<Notification> notifications) {
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
                //     // TODO: Navigate to all notifications page
                //   },
                //   child: const Text('View All'),
                // ),
              ],
            ),
            const SizedBox(height: 10),
            ...notifications.take(3).map((notification) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: notification.isRead 
                    ? AppColors.background 
                    : AppColors.primary.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: notification.isRead 
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
                        color: notification.isRead 
                          ? AppColors.textSecondary.withOpacity(0.1)
                          : AppColors.primary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications,
                        color: notification.isRead 
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
                                  notification.title,
                                  style: TextStyle(
                                    fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                              Text(
                                notification.time,
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

  // Enhanced event card with fixed overflow
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
      ),
    );
  }

  // Monthly points card
  Widget _buildMonthlyPointsCard(int points) {
    return Card(
      elevation: 3,
      shadowColor: AppColors.primary.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.star,
                color: AppColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Points This Month',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  points.toString(),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            TextButton(
              onPressed: () {
                // TODO: Navigate to detailed points history
              },
              child: const Text('History'),
            ),
          ],
        ),
      ),
    );
  }

  // Leaderboard card
  Widget _buildLeaderboardCard(List<User> users) {
    return Card(
      elevation: 3,
      shadowColor: AppColors.primary.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.leaderboard,
                    color: Colors.amber[700],
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Top Volunteers',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to full leaderboard
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...users.map((user) {
              // Set medal color based on rank
              Color medalColor;
              IconData medalIcon;
              
              switch (user.rank) {
                case 1:
                  medalColor = Colors.amber;
                  medalIcon = Icons.emoji_events;
                  break;
                case 2:
                  medalColor = Colors.grey.shade400;
                  medalIcon = Icons.emoji_events;
                  break;
                case 3:
                  medalColor = Colors.brown.shade300;
                  medalIcon = Icons.emoji_events;
                  break;
                default:
                  medalColor = AppColors.primary;
                  medalIcon = Icons.star;
              }
              
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                decoration: BoxDecoration(
                  color: user.rank == 1 
                    ? Colors.amber.withOpacity(0.05)
                    : AppColors.background,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: user.rank == 1 
                      ? Colors.amber.withOpacity(0.3)
                      : AppColors.divider,
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: medalColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          medalIcon,
                          color: medalColor,
                          size: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        user.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${user.points} pts',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
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

  // Recent event participation card
  Widget _buildRecentParticipationCard(List<EventParticipation> participations) {
    return Card(
      elevation: 3,
      shadowColor: AppColors.primary.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.history,
                    color: AppColors.success,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Recent Participations',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...participations.map((participation) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.divider,
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
                        Icons.event_available,
                        color: AppColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            participation.eventName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            participation.date,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+${participation.pointsEarned} pts',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
                        ),
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

  // Enhanced badges earned card with better visuals
  Widget _buildEnhancedBadgesCard(List<Badge> badges) {
    return Card(
      elevation: 3,
      shadowColor: AppColors.primary.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.emoji_events_rounded,
                    color: Colors.amber[700],
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Badges Earned',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: badges.map((badge) {
                // Get specific color for each badge type
                Color badgeColor = _getBadgeColor(badge.title);
                
                return Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            badgeColor.withOpacity(0.2),
                            badgeColor.withOpacity(0.05),
                          ],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: badgeColor.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                        border: Border.all(
                          color: badgeColor.withOpacity(0.5),
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          _getBadgeIcon(badge.title),
                          color: badgeColor,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: 90,
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                      decoration: BoxDecoration(
                        color: badgeColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: badgeColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        badge.title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: badgeColor.withOpacity(0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to get the appropriate icon for badge types
  IconData _getBadgeIcon(String badgeTitle) {
    if (badgeTitle.contains('Mind')) {
      return Icons.spa;
    } else if (badgeTitle.contains('Eco')) {
      return Icons.eco;
    } else if (badgeTitle.contains('Community')) {
      return Icons.people;
    } else {
      return Icons.star;
    }
  }
  
  // Helper method to get appropriate color for badge types
  Color _getBadgeColor(String badgeTitle) {
    if (badgeTitle.contains('Mind')) {
      return Colors.purple;
    } else if (badgeTitle.contains('Eco')) {
      return Colors.green[700]!;
    } else if (badgeTitle.contains('Community')) {
      return Colors.blue[700]!;
    } else {
      return Colors.amber[700]!;
    }
  }

  // Helper method to get event icon based on title
  IconData _getEventIcon(String title) {
    if (title.contains('Blood')) {
      return Icons.favorite;
    } else if (title.contains('Clothes')) {
      return Icons.checkroom;
    } else if (title.contains('Beach')) {
      return Icons.beach_access;
    } else {
      return Icons.event;
    }
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

  // Registered event card with confirmation UI
  Widget _buildRegisteredEventCard(Event event) {
    return Container(
      height: 210, // Increased from 194 to 210
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        shadowColor: AppColors.success.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.success.withOpacity(0.3),
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
                      color: AppColors.success.withOpacity(0.05),
                      image: _getEventImage(event.title),
                    ),
                  ),
                  // Registration badge
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.2),
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
                  // Date badge
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
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2), // Reduced from 4
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
                      const Spacer(),
                      Center(
                        child: TextButton.icon(
                          onPressed: () => _showEventDialog(event),
                          icon: Icon(Icons.visibility, size: 14, color: AppColors.primary),
                          label: Text(
                            'View Details',
                            style: TextStyle(color: AppColors.primary, fontSize: 12),
                          ),
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4), // Added small bottom padding
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
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

class Notification {
  final String id;
  final String title;
  final String message;
  final String time;
  final bool isRead;

  Notification({
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
