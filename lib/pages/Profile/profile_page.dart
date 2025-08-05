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

  // FIXED: Remove default achievements - use only BadgeService
  List<AchievementBadge> _achievements = [];
  bool _isLoadingAchievements = true;

  @override
  void initState() {
    super.initState();
    _initUsername();
    _loadProfileData(); // Load data in proper sequence
  }

  // Add method to initialize username
  Future<void> _initUsername() async {
    print('Starting _initUsername() method');

    // FIXED: Force refresh username from storage on init
    final username = await _authService.getUsername();
    print('_initUsername received username: $username');

    if (username != null && mounted) {
      print('Setting state with username: $username');
      setState(() {
        // Force the UI to refresh with the username
      });
    } else {
      print(
          'Username is null or widget not mounted. Username=$username, mounted=$mounted');

      // FIXED: If no username found, try to refresh from auth service
      if (mounted) {
        await _authService
            .initUsername(); // FIXED: Remove underscore - use public method
        final refreshedUsername = await _authService.getUsername();
        if (refreshedUsername != null && mounted) {
          print('Found refreshed username: $refreshedUsername');
          setState(() {});
        }
      }
    }
  }

  // Add method to load profile data in correct sequence - like dashboard
  Future<void> _loadProfileData() async {
    // FIXED: Load points first, then badges - same sequence as dashboard
    await _refreshUserPoints(); // Wait for points to load first
    await _refreshVolunteerStatus(); // Wait for volunteer status
    await _loadEventsAttendedCount(); // Load events count
    _loadAchievements(); // Then load badges with fresh data
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
        // FIXED: Force BadgeService to refresh when volunteer status changes
        try {
          final badgeService = Get.find<BadgeService>();
          badgeService.refreshBadges();
        } catch (e) {
          print('Error refreshing badge service: $e');
        }

        // Refresh badges when volunteer status changes
        _loadAchievements();
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

          // FIXED: Force immediate badge refresh in BadgeService
          try {
            final badgeService = Get.find<BadgeService>();
            badgeService.refreshBadges();
          } catch (e) {
            print(
                'Error refreshing badge service after volunteer registration: $e');
          }

          // Refresh achievements immediately to show new badge
          _loadAchievements();

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
          Future.delayed(const Duration(seconds: 1), () {
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

  Future<void> _loadEventsAttendedCount() async {
    if (!mounted) return;

    setState(() {
      _isLoadingEvents = true;
    });

    try {
      final userId = _authService.userId;
      if (userId != null) {
        // FIXED: Use getRecentParticipations like dashboard instead of getUserRegisteredEvents
        final participations =
            await _apiService.getRecentParticipations(userId);

        // FIXED: Count the participations (same as dashboard logic)
        // This returns actual event participations with points, not just registrations
        int totalCount = participations.length;

        print(
            'Profile: User has participated in $totalCount events (same as dashboard)');

        if (!mounted) return;
        setState(() {
          _eventsAttended = totalCount;
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

  // FORCE USE OF SHARED METHOD - No other calls allowed
  void _loadAchievements() {
    print('=== PROFILE: _loadAchievements START ===');
    if (!mounted) return;

    setState(() {
      _isLoadingAchievements = true;
    });

    try {
      // FORCE USE SHARED METHOD - Remove any other badge calls
      final badges = BadgeService.getSharedBadges();

      print('Profile: Got ${badges.length} badges from SHARED method');
      for (var badge in badges) {
        print('Profile Badge: ${badge.name} (Level ${badge.level})');
      }

      if (mounted) {
        setState(() {
          _achievements = badges;
          _isLoadingAchievements = false;
        });

        print('Profile: UI updated with ${_achievements.length} badges');
        print(
            'Profile: Badge names: ${_achievements.map((b) => b.name).join(', ')}');
      }
    } catch (e) {
      print('Profile: Error loading achievements: $e');
      if (mounted) {
        setState(() {
          _isLoadingAchievements = false;
        });
      }
    }

    print('=== PROFILE: _loadAchievements END ===');
  }

  // FIXED: Update refresh method to match dashboard sequence
  Future<void> _refreshAllData() async {
    print('Profile: Refreshing profile data and badges');

    // SAME SEQUENCE AS DASHBOARD - Load points first, then badges
    await _refreshUserPoints(); // Load fresh points from API
    await _refreshVolunteerStatus(); // Refresh volunteer status
    await _loadEventsAttendedCount(); // Load events count

    // Force badge service to refresh user data - SAME as dashboard
    try {
      final authService = Get.find<AuthService>();
      await authService.refreshUserStatus(); // Refresh user status first
    } catch (e) {
      print('Profile: Error refreshing user status: $e');
    }

    _loadAchievements(); // Then refresh badges with updated data
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
      body: RefreshIndicator(
        onRefresh: _refreshAllData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
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

              // Statistics section - THIS SHOWS THE REAL ACHIEVEMENT COUNT
              _buildStatisticsSection(points),

              const SizedBox(height: 16),

              // Enhanced Achievements section
              _buildEnhancedAchievementsSection(),
            ],
          ),
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
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.volunteer_activism),
                      label: Text(_isLoading
                          ? 'Submitting...'
                          : 'Register as Volunteer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
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
  Widget _buildVolunteerStatusCard(
      String title, String message, IconData icon, Color color) {
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
                    ? _buildLoadingStatItem(
                        Icons.event_available, 'Events\nAttended')
                    : _buildStatItem(Icons.event_available, 'Events\nAttended',
                        _eventsAttended.toString()),
                _buildStatItem(Icons.stars, 'Total\nPoints', points.toString()),
                // FIXED: Show loading state and use correct count
                _isLoadingAchievements
                    ? _buildLoadingStatItem(Icons.emoji_events, 'Achievements')
                    : _buildStatItem(Icons.emoji_events, 'Achievements',
                        _achievements.length.toString()),
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

  // FIXED: Show achievement count in header for verification
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
                Text(
                  'Achievements (${_achievements.length})', // Show count to verify sync
                  style: const TextStyle(
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
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Show loading or badges
            _isLoadingAchievements
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : _achievements.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'No achievements earned yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: _achievements.length,
                        itemBuilder: (context, index) {
                          final achievement = _achievements[index];
                          return _buildAchievementBadge(achievement);
                        },
                      ),
            const SizedBox(height: 75)
          ],
        ),
      ),
    );
  }

  // FIXED: Update to work with AchievementBadge objects
  Widget _buildAchievementBadge(AchievementBadge achievement) {
    return Container(
      decoration: BoxDecoration(
        color: achievement.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.color.withOpacity(0.3),
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
                  color: achievement.color.withOpacity(0.2),
                  border: Border.all(
                    color: achievement.color,
                    width: 2,
                  ),
                ),
                child: Icon(
                  achievement.icon,
                  color: achievement.color,
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
                    color: AppColors.white,
                    border: Border.all(
                      color: achievement.color,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    achievement.level.toString(),
                    style: TextStyle(
                      color: achievement.color,
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
            achievement.name,
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
              achievement.description,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
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
