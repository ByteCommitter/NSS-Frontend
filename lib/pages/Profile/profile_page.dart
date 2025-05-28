import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/theme/app_colors.dart';
import 'package:mentalsustainability/services/auth_service.dart';
import 'package:mentalsustainability/services/api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = Get.find<AuthService>();
  final ApiService _apiService = Get.find<ApiService>();
  
  bool _isLoading = false;
  
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
  }
  
  // Refresh user points from API
  Future<void> _refreshUserPoints() async {
    final userId = _authService.userId;
    if (userId != null) {
      final points = await _apiService.getUserTotalPoints(userId);
      _authService.updatePoints(points);
      setState(() {}); // Refresh UI with updated points
    }
  }
  
  // Handle volunteer registration
  Future<void> _registerAsVolunteer() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final userId = _authService.userId;
      if (userId != null) {
        final success = await _apiService.wishToBeVolunteer(userId);
        
        if (success) {
          // Refresh the auth service instead of directly modifying its private field
          await _authService.refreshUserStatus();
          
          Get.snackbar(
            'Request Submitted',
            'Your volunteer registration request has been submitted for approval.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success.withOpacity(0.1),
            colorText: AppColors.success,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
          );
        } else {
          Get.snackbar(
            'Request Failed',
            'Unable to submit volunteer registration. Please try again later.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error.withOpacity(0.1),
            colorText: AppColors.error,
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 3),
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
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
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
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatisticsSection(int points) {
    // Get completed events count (hardcoded for now)
    final int completedEvents = 5; // This should come from API
    
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
                _buildStatItem(Icons.event_available, 'Events\nAttended', completedEvents.toString()),
                _buildStatItem(Icons.stars, 'Total\nPoints', points.toString()),
                _buildStatItem(Icons.emoji_events, 'Achievements', _achievements.length.toString()),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, size: 28, color: AppColors.primary), // Use theme color
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary, // Use theme color
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary, // Use theme color
          ),
        ),
      ],
    );
  }
  
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
            
            // Enhanced badges - fixed to use _achievements instead of _userData
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
