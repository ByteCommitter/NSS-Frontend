import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/theme/app_colors.dart';
import 'package:mentalsustainability/services/auth_service.dart';
import 'package:mentalsustainability/services/api_service.dart';
import 'package:mentalsustainability/services/badge_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = Get.find<AuthService>();
  final ApiService _apiService = Get.find<ApiService>();
  
  bool _isLoading = false;
  int _eventsAttended = 0;
  bool _isLoadingEvents = true;
  
  // Use real achievements data from API (will be populated)
  List<Map<String, dynamic>> _achievements = [
    // Default achievements until we implement API for real ones
    {
      'name': 'NSS Volunteer',
      'description': 'Registered as NSS volunteer',
      'icon': Icons.volunteer_activism,
      'color': AppColors.success,
      'level': 1,
    },
    {
      'name': 'Event Participant',
      'description': 'Participated in NSS events',
      'icon': Icons.event_available,
      'color': AppColors.primary,
      'level': 1,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Load real user points if needed
    _refreshUserPoints();
    // Refresh volunteer status
    _refreshVolunteerStatus();
    // Load event participation count
    _loadEventsAttendedCount();
    // Make sure username is initialized
    _initUsername();
    // Load achievements from badge service
    _loadAchievements();
  }
  
  // Add method to initialize username
  Future<void> _initUsername() async {
    print('Starting _initUsername() method');
    final username = await _authService.getUsername();
    print('_initUsername received username: $username');
    
    if (username != null && mounted) {
      print('Setting state with username: $username');
      setState(() {
        // Force the UI to refresh with the username
      });
    } else {
      print('Username is null or widget not mounted. Username=$username, mounted=$mounted');
    }
  }
  
  // Refresh user points from API
  Future<void> _refreshUserPoints() async {
    final userId = _authService.userId;
    if (userId != null && mounted) {
      final points = await _apiService.getUserTotalPoints(userId);
      if (mounted) {
        _authService.updatePoints(points);
        setState(() {}); // Refresh UI with updated points
      }
    }
  }
  
  // Add a method to refresh volunteer status
  Future<void> _refreshVolunteerStatus() async {
    final userId = _authService.userId;
    if (userId != null && mounted) {
      await _authService.refreshUserStatus();
      if (mounted) {
        setState(() {}); // Refresh UI with updated status
      }
    }
  }
  
  // Handle volunteer registration
  Future<void> _registerAsVolunteer() async {
    if (!mounted) return;
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userId = _authService.userId;
      if (userId != null) {
        final result = await _apiService.wishToBeVolunteer(userId);
        
        if (result['success']) {
          _authService.setWishVolunteerStatus(true);
          
          Get.snackbar(
            'Application Submitted',
            result['message'],
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success.withOpacity(0.1),
            colorText: AppColors.success,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
            icon: Icon(Icons.check_circle, color: AppColors.success),
            borderRadius: 10,
            boxShadows: [
              BoxShadow(
                color: AppColors.success.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 2),
              )
            ],
          );
          
          if (mounted) {
            setState(() {
              // This will refresh UI to show pending status
            });
          }
          
          // Call refreshUserStatus() after a brief delay
          Future.delayed(Duration(seconds: 1), () {
            if (mounted) {
              _refreshVolunteerStatus();
            }
          });
        } else {
          Get.snackbar(
            'Request Failed',
            result['message'],
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error.withOpacity(0.1),
            colorText: AppColors.error,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
            icon: Icon(Icons.error_outline, color: AppColors.error),
            borderRadius: 10,
          );
        }
      }
    } catch (e) {
      print('Error registering as volunteer: $e');
      Get.snackbar(
        'Error',
        'An error occurred. Please try again later.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
        margin: const EdgeInsets.all(16),
        icon: Icon(Icons.error_outline, color: AppColors.error),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Add method to load attended events count
  Future<void> _loadEventsAttendedCount() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingEvents = true;
    });
    
    try {
      final userId = _authService.userId;
      if (userId != null) {
        // Use the existing API call - no need for a dedicated endpoint
        final participations = await _apiService.getRecentParticipations(userId);
        
        // Count only verified participations (isParticipated = 1)
        int verifiedCount = 0;
        for (var participation in participations) {
          if (participation['isParticipated'] == 1) {
            verifiedCount++;
          }
        }
        
        if (!mounted) return;
        setState(() {
          _eventsAttended = verifiedCount;
          _isLoadingEvents = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isLoadingEvents = false;
        });
      }
    } catch (e) {
      print('Error loading events attended count: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingEvents = false;
      });
    }
  }
  
  // Add method to load achievements
  void _loadAchievements() {
    try {
      // Create default achievements in case badge service isn't available
      _achievements = [
        {
          'name': 'NSS Volunteer',
          'description': 'Registered as NSS volunteer',
          'icon': Icons.volunteer_activism,
          'color': AppColors.success,
          'level': 1,
        },
        {
          'name': 'Event Participant',
          'description': 'Participated in NSS events',
          'icon': Icons.event_available,
          'color': AppColors.primary,
          'level': 1,
        },
      ];
      
      // Try to get the BadgeService
      BadgeService? badgeService;
      try {
        badgeService = Get.find<BadgeService>();
        print('BadgeService found in _loadAchievements');
      } catch (e) {
        print('BadgeService not found, creating a new instance');
        badgeService = BadgeService();
        Get.put(badgeService, permanent: true);
      }
      
      // Get badges from the service
      final badges = badgeService.calculateUserBadges();
      
      print('Calculated ${badges.length} badges from BadgeService');
      
      // Only update achievements if we got some badges
      if (badges.isNotEmpty) {
        setState(() {
          _achievements = badges.map((badge) => {
            'name': badge.name,
            'description': badge.description,
            'icon': badge.icon,
            'color': badge.color,
            'level': badge.level,
          }).toList();
        });
        
        print('Updated achievements with ${_achievements.length} items');
      }
    } catch (e) {
      print('Error loading achievements: $e');
      // We already have default achievements set above
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get user data from AuthService
    final String name = _authService.username ?? 'User';
    final String userId = _authService.userId ?? 'Unknown ID';
    final int points = _authService.points;
    final bool isVolunteer = _authService.isVolunteer;
    final bool isWishVolunteer = _authService.isWishVolunteer;
    
    
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header with real name
            _buildProfileHeader(name, userId, points),
            
            const SizedBox(height: 16),
            
            // Volunteer status/registration section
            _buildVolunteerSection(isVolunteer, isWishVolunteer),
            
            const SizedBox(height: 16),
            
            // Statistics section
            _buildStatisticsSection(points),
            
            const SizedBox(height: 16),
            
            // Enhanced Achievements section
            _buildEnhancedAchievementsSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileHeader(String name, String userId, int points) {
    return Row(
      children: [
        // Avatar
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColors.primary,
          child: Text(
            name.isNotEmpty ? name.substring(0, 1).toUpperCase() : 'U',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
        ),
        const SizedBox(width: 20),
        
        // User info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name
              Text(
                name,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              // User ID
              Text(
                'ID: $userId',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Points display
              Row(
                children: [
                  Icon(Icons.stars, color: AppColors.warning, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    '$points points',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildVolunteerSection(bool isVolunteer, bool isWishVolunteer) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.volunteer_activism,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Volunteer Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Show different content based on volunteer status
            if (isVolunteer)
              _buildVolunteerStatusCard(
                'Active Volunteer',
                'You are registered as an NSS volunteer',
                Icons.check_circle,
                AppColors.success,
              )
            else if (isWishVolunteer)
              _buildVolunteerStatusCard(
                'Registration Pending',
                'Your volunteer registration is awaiting approval',
                Icons.hourglass_top,
                AppColors.warning,
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildVolunteerStatusCard(
                    'Not Registered',
                    'Register as a volunteer to participate in organizing events',
                    Icons.info_outline,
                    AppColors.info,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: _isLoading ? null : _registerAsVolunteer,
                      icon: _isLoading 
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(Icons.volunteer_activism),
                      label: Text(_isLoading ? 'Submitting...' : 'Register as Volunteer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
  
  // Update the volunteer status card to clearly show applied status
  Widget _buildVolunteerStatusCard(String title, String message, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(fontSize: 14),
                ),
                
                // Add additional info for pending requests
                if (title == 'Registration Pending')
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 14, color: color),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Your application is being reviewed by administrators',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: color.withOpacity(0.8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatisticsSection(int points) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _isLoadingEvents
                  ? _buildLoadingStatItem(Icons.event_available, 'Events\nAttended')
                  : _buildStatItem(Icons.event_available, 'Events\nAttended', _eventsAttended.toString()),
                _buildStatItem(Icons.stars, 'Total\nPoints', points.toString()),
                _buildStatItem(Icons.emoji_events, 'Achievements', _achievements.length.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Add a loading state for stat items
  Widget _buildLoadingStatItem(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 28, color: AppColors.primary),
        const SizedBox(height: 8),
        SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
  
  // Add the missing method for stat items
  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 28, color: AppColors.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
  
  // Modify the _buildEnhancedAchievementsSection to not rely on BadgeService
  Widget _buildEnhancedAchievementsSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Achievements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.grid_view, size: 16),
                  label: const Text("View All"),
                  onPressed: () {
                    // Future enhancement: Navigate to full achievements page
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary, // Use theme color
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Enhanced badges
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.0,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _achievements.length,
              itemBuilder: (context, index) {
                final achievement = _achievements[index];
                return _buildAchievementBadge(achievement);
              },
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildAchievementBadge(Map<String, dynamic> achievement) {
    return Container(
      decoration: BoxDecoration(
        color: achievement['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement['color'].withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Badge Icon with Level indicator
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: achievement['color'].withOpacity(0.2),
                  border: Border.all(
                    color: achievement['color'],
                    width: 2,
                  ),
                ),
                child: Icon(
                  achievement['icon'],
                  color: achievement['color'],
                  size: 32,
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white, // Use theme color
                    border: Border.all(
                      color: achievement['color'],
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    achievement['level'].toString(),
                    style: TextStyle(
                      color: achievement['color'],
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            achievement['name'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              achievement['description'],
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary, // Use theme color
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
