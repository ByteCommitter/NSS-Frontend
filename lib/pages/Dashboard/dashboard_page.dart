import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/services/badge_service.dart';
import 'package:mentalsustainability/theme/app_colors.dart';
import 'package:mentalsustainability/services/api_service.dart';
import 'package:mentalsustainability/services/auth_service.dart';
import 'dart:async';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ApiService _apiService = Get.find<ApiService>();
  final AuthService _authService = Get.find<AuthService>();
  late final BadgeService _badgeService;

  // Add timer for periodic badge refresh
  Timer? _badgeRefreshTimer;

  // State variables for API data
  int _totalPoints = 0;
  bool _isLoadingPoints = true;

  List<User> _topUsers = [];
  bool _isLoadingTopUsers = true;

  // Full leaderboard data
  List<User> _allUsers = [];
  bool _isLoadingAllUsers = false;

  List<EventParticipation> _recentParticipations = [];
  bool _isLoadingParticipations = true;

  // Replace the _achievementBadges with proper BadgeService integration
  List<AchievementBadge> _badges = [];
  bool _isLoadingBadges = true;

  // Remove the hardcoded badges - we'll use BadgeService instead

  @override
  void initState() {
    super.initState();
    // Initialize badge service - SAME as profile page
    try {
      _badgeService = Get.find<BadgeService>();
      print('Found existing BadgeService in Dashboard');
    } catch (e) {
      print('BadgeService not found in Dashboard, creating new instance');
      _badgeService = BadgeService();
      Get.put(_badgeService, permanent: true);
    }

    // FIXED: Start periodic badge refresh timer
    _startBadgeRefreshTimer();

    _loadDashboardData();
    _loadBadges();
  }

  @override
  void dispose() {
    // FIXED: Cancel timer when disposing
    _badgeRefreshTimer?.cancel();
    super.dispose();
  }

  // FIXED: Add periodic badge refresh timer
  void _startBadgeRefreshTimer() {
    _badgeRefreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        print('Dashboard: Periodic badge refresh');
        _loadBadges();
      }
    });
  }

  // Load all dashboard data
  Future<void> _loadDashboardData() async {
    _loadUserPoints();
    _loadTopVolunteers();
    _loadRecentParticipations();
  }

  // Load user's total points
  Future<void> _loadUserPoints() async {
    if (!mounted) return; // Add mounted check

    setState(() {
      _isLoadingPoints = true;
    });

    try {
      final userId = await _authService.getUserId();
      if (userId != null) {
        final points = await _apiService.getUserTotalPoints(userId);
        if (!mounted) return; // Add mounted check after await
        setState(() {
          _totalPoints = points;
          _isLoadingPoints = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isLoadingPoints = false;
        });
      }
    } catch (e) {
      print('Error loading user points: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingPoints = false;
      });
    }
  }

  // Load top volunteers
  Future<void> _loadTopVolunteers() async {
    if (!mounted) return; // Add mounted check

    setState(() {
      _isLoadingTopUsers = true;
    });

    try {
      final topVolunteers = await _apiService.getTopVolunteers();
      if (!mounted) return; // Add mounted check after await

      final List<User> users = [];

      for (int i = 0; i < topVolunteers.length; i++) {
        final volunteer = topVolunteers[i];
        users.add(User(
          id: i.toString(),
          name: volunteer['username'] ?? 'Unknown User',
          points: volunteer['totalPoints'] ?? 0,
          rank: i + 1,
        ));
      }

      if (!mounted) return;
      setState(() {
        _topUsers = users;
        _isLoadingTopUsers = false;
      });
    } catch (e) {
      print('Error loading top volunteers: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingTopUsers = false;
      });
    }
  }

  // NEW: Load full leaderboard for the dialog
  Future<void> _loadFullLeaderboard([StateSetter? dialogSetState]) async {
    if (!mounted) return;

    final setStateFunction = dialogSetState ?? setState;

    setStateFunction(() {
      _isLoadingAllUsers = true;
    });

    try {
      final allVolunteers = await _apiService.getTopVolunteers();
      if (!mounted) return;

      final List<User> users = [];
      for (int i = 0; i < allVolunteers.length; i++) {
        final volunteer = allVolunteers[i];
        users.add(User(
          id: i.toString(),
          name: volunteer['username'] ?? 'Unknown User',
          points: volunteer['totalPoints'] ?? 0,
          rank: i + 1,
        ));
      }

      if (!mounted) return;
      setStateFunction(() {
        _allUsers = users;
        _isLoadingAllUsers = false;
      });
    } catch (e) {
      print('Error loading full leaderboard: $e');
      if (!mounted) return;
      setStateFunction(() {
        _isLoadingAllUsers = false;
      });
    }
  }

  // Load recent participations
  Future<void> _loadRecentParticipations() async {
    if (!mounted) return; // Add mounted check

    setState(() {
      _isLoadingParticipations = true;
    });

    try {
      final userId = await _authService.getUserId();
      if (userId != null) {
        final participations =
            await _apiService.getRecentParticipations(userId);
        if (!mounted) return; // Add mounted check after await

        // Store all participations for the history dialog
        _allParticipations = participations;

        // Convert API data to EventParticipation objects
        final List<EventParticipation> formattedParticipations = [];

        for (var participation in participations) {
          // Get event details from the event ID
          final eventId = participation['event_id']?.toString() ?? '';
          final eventDetails = await _apiService.getEventById(eventId);
          if (!mounted) return; // Add mounted check in loop

          formattedParticipations.add(EventParticipation(
            eventId: eventId,
            eventName: eventDetails?.title ?? 'Event #$eventId',
            pointsEarned: participation['points'] ?? 0,
            date: eventDetails?.date ?? 'Unknown Date',
          ));
        }

        if (!mounted) return;
        setState(() {
          // Limit to 3 most recent participations for dashboard
          _recentParticipations = formattedParticipations.take(3).toList();
          _isLoadingParticipations = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _isLoadingParticipations = false;
        });
      }
    } catch (e) {
      print('Error loading recent participations: $e');
      if (!mounted) return;
      setState(() {
        _isLoadingParticipations = false;
      });
    }
  }

  // FORCE USE OF SHARED METHOD - No other calls allowed
  void _loadBadges() {
    print('=== DASHBOARD: _loadBadges START ===');
    if (!mounted) return;

    setState(() {
      _isLoadingBadges = true;
    });

    try {
      // FORCE USE SHARED METHOD - Remove any other badge calls
      final badges = BadgeService.getSharedBadges();

      print('Dashboard: Got ${badges.length} badges from SHARED method');
      for (var badge in badges) {
        //print('Dashboard Badge: ${badge.name} (Level ${badge.level})');
      }

      if (mounted) {
        setState(() {
          _badges = badges;
          _isLoadingBadges = false;
        });

        //print('Dashboard: UI updated with ${_badges.length} badges');
        //print('Dashboard: Badge names: ${_badges.map((b) => b.name).join(', ')}');
      }
    } catch (e) {
      print('Dashboard: Error loading badges: $e');
      if (mounted) {
        setState(() {
          _isLoadingBadges = false;
        });
      }
    }

    //print('=== DASHBOARD: _loadBadges END ===');
  }

  // FIXED: Add method to refresh all dashboard data including badges
  Future<void> _refreshDashboard() async {
    print('Refreshing dashboard data and badges');
    await _loadDashboardData();

    // Force badge service to refresh user data
    try {
      final authService = Get.find<AuthService>();
      await authService.refreshUserStatus(); // Refresh user status first
    } catch (e) {
      print('Error refreshing user status in dashboard: $e');
    }

    _loadBadges(); // Then refresh badges with updated data
  }

  // NEW: Show full leaderboard dialog

  void _showFullLeaderboardDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            if (_allUsers.isEmpty && !_isLoadingAllUsers) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _loadFullLeaderboard(setDialogState);
              });
            }
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              elevation: 0,
              backgroundColor: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.8,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10.0,
                      offset: Offset(0.0, 10.0),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header
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
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Full Leaderboard',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),
                    // Leaderboard content
                    Expanded(
                      child: _isLoadingAllUsers
                          ? const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  CircularProgressIndicator(),
                                  SizedBox(height: 16),
                                  Text('Loading leaderboard...'),
                                ],
                              ),
                            )
                          : _allUsers.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No data available',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              : ListView.builder(
                                  itemCount: _allUsers.length,
                                  itemBuilder: (context, index) {
                                    final user = _allUsers[index];
                                    return _buildLeaderboardItem(user, index);
                                  },
                                ),
                    ),

                    // Footer info
                    const SizedBox(height: 16),
                    Text(
                      'Rankings are based on total volunteer points earned.',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // NEW: Build individual leaderboard item for the dialog
  Widget _buildLeaderboardItem(User user, int index) {
    // Set medal color and icon based on rank
    Color medalColor;
    IconData medalIcon;
    Color? backgroundColor;

    switch (user.rank) {
      case 1:
        medalColor = Colors.amber;
        medalIcon = Icons.emoji_events;
        backgroundColor = Colors.amber.withOpacity(0.1);
        break;
      case 2:
        medalColor = Colors.grey.shade400;
        medalIcon = Icons.emoji_events;
        backgroundColor = Colors.grey.withOpacity(0.1);
        break;
      case 3:
        medalColor = Colors.brown.shade300;
        medalIcon = Icons.emoji_events;
        backgroundColor = Colors.brown.withOpacity(0.1);
        break;
      default:
        medalColor = AppColors.primary;
        medalIcon = Icons.star;
        backgroundColor = null;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor ?? AppColors.cardBackground.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              user.rank <= 3 ? medalColor.withOpacity(0.3) : AppColors.divider,
          width: user.rank <= 3 ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Rank number
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: medalColor.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: medalColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Center(
              child: user.rank <= 3
                  ? Icon(
                      medalIcon,
                      color: medalColor,
                      size: 18,
                    )
                  : Text(
                      '${user.rank}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: medalColor,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 16),

          // User avatar placeholder
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                user.name.isNotEmpty ? user.name[0].toUpperCase() : 'U',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // User name
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  style: TextStyle(
                    fontWeight:
                        user.rank <= 3 ? FontWeight.bold : FontWeight.w600,
                    fontSize: 16,
                    color: user.rank <= 3 ? medalColor : null,
                  ),
                ),
                if (user.rank <= 3)
                  Text(
                    _getRankTitle(user.rank),
                    style: TextStyle(
                      fontSize: 12,
                      color: medalColor.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
              ],
            ),
          ),

          // Points
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: medalColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: medalColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              '${user.points} pts',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: medalColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // NEW: Get rank title for top 3 users
  String _getRankTitle(int rank) {
    switch (rank) {
      case 1:
        return 'Champion';
      case 2:
        return 'Runner-up';
      case 3:
        return 'Third Place';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
        child: RefreshIndicator(
          onRefresh: _refreshDashboard,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Dashboard header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.dashboard_rounded,
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
                            'Your Dashboard',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Track your progress and achievements',
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

                // Monthly Points Card
                _buildMonthlyPointsCard(_totalPoints),
                const SizedBox(height: 20),

                // Leaderboard Card - Top 3 Users
                _buildLeaderboardCard(_topUsers),
                const SizedBox(height: 20),

                // Recent Event Participation
                _buildRecentParticipationCard(_recentParticipations),
                const SizedBox(height: 20),

                // Badges Earned - Now using the same badges as profile page
                _buildBadgesCard(_badges),
                const SizedBox(height: 32),
              ],
            ),
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
                  'Your Total Points', // Changed from "Monthly Points" to "Total Points"
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                _isLoadingPoints
                    ? SizedBox(
                        height: 28,
                        width: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : Text(
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
                // Show participation history dialog
                _showParticipationHistoryDialog();
              },
              child: const Text('History'),
            ),
          ],
        ),
      ),
    );
  }

  // Leaderboard card - UPDATED with working "See All" button
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
                    // UPDATED: Show full leaderboard dialog

                    _showFullLeaderboardDialog();
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _isLoadingTopUsers
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : users.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'No data available',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : Column(
                        children: users.map((user) {
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
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
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
                      ),
          ],
        ),
      ),
    );
  }

  // Recent event participation card
  Widget _buildRecentParticipationCard(
      List<EventParticipation> participations) {
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
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Show participation history dialog
                    _showParticipationHistoryDialog();
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _isLoadingParticipations
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : participations.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'No participation records found',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : Column(
                        children: [
                          ...participations.map((participation) {
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color:
                                    AppColors.cardBackground.withOpacity(0.5),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
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
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
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

                          // Add the disclaimer at the bottom
                          const SizedBox(height: 16),
                          Text(
                            'Note: Participation records and points are updated once every 24 hours.',
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: Colors.grey[600],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
          ],
        ),
      ),
    );
  }

  // Badges card
  Widget _buildBadgesCard(List<AchievementBadge> badges) {
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
                Text(
                  'Badges Earned (${badges.length})', // Show count to verify sync
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Show all badges in a dialog
                    _showAllBadgesDialog();
                  },
                  child: const Text('See All'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _isLoadingBadges
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : badges.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(
                            'No badges earned yet',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: badges.take(3).map((badge) {
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
                                      badge.color.withOpacity(0.2),
                                      badge.color.withOpacity(0.05),
                                    ],
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: badge.color.withOpacity(0.2),
                                      blurRadius: 10,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                  border: Border.all(
                                    color: badge.color.withOpacity(0.5),
                                    width: 2,
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Icon(
                                        badge.icon,
                                        color: badge.color,
                                        size: 32,
                                      ),
                                    ),
                                    // Level indicator
                                    Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: badge.color,
                                            width: 1.5,
                                          ),
                                        ),
                                        child: Text(
                                          badge.level.toString(),
                                          style: TextStyle(
                                            color: badge.color,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: 90,
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 8),
                                decoration: BoxDecoration(
                                  color: badge.color.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: badge.color.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  badge.name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: badge.color.withOpacity(0.8),
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

  // Update the dialog to use AchievementBadge instead of old Badge type
  void _showAllBadgesDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.emoji_events,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Your Achievements',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),

                // Badges grid
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: _isLoadingBadges
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : _badges.isEmpty
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(20.0),
                                child: Text(
                                  'No badges earned yet',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            )
                          : GridView.builder(
                              shrinkWrap: true,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.8,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                              itemCount: _badges.length,
                              itemBuilder: (context, index) {
                                final badge = _badges[index];
                                return _buildBadgeGridItem(badge);
                              },
                            ),
                ),

                // Footnote about badges
                const SizedBox(height: 16),
                Text(
                  'Badges are earned based on your participation and contributions.',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper to build a badge grid item
  Widget _buildBadgeGridItem(AchievementBadge badge) {
    return Container(
      decoration: BoxDecoration(
        color: badge.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badge.color.withOpacity(0.3),
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: badge.color.withOpacity(0.2),
                  border: Border.all(
                    color: badge.color,
                    width: 2,
                  ),
                ),
                child: Icon(
                  badge.icon,
                  color: badge.color,
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
                      color: badge.color,
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    badge.level.toString(),
                    style: TextStyle(
                      color: badge.color,
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
            badge.name,
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
              badge.description,
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

  // Add a variable to store all participations for the history dialog
  List<Map<String, dynamic>> _allParticipations = [];
  final bool _isLoadingAllParticipations = false;

  // New method to show participation history dialog
  Future<void> _showParticipationHistoryDialog() async {
    // Calculate total points from participations
    int totalPoints = 0;
    for (var p in _allParticipations) {
      if (p.containsKey('points')) {
        totalPoints += (p['points'] ?? 0) as int;
      }
    }

    // Show dialog with participation history
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Row(
                  children: [
                    Icon(
                      Icons.history,
                      color: AppColors.primary,
                      size: 24,
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Participation History',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),

                // Points summary
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total Points',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '$totalPoints',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'Events',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_allParticipations.length}',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Participation list
                Container(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: _allParticipations.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              'No participation records found',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          itemCount: _allParticipations.length,
                          itemBuilder: (context, index) {
                            final participation = _allParticipations[index];
                            final eventId =
                                participation['event_id']?.toString() ??
                                    'Unknown';
                            final participationPoints =
                                participation['points'] ?? 0;
                            final verified =
                                participation['isParticipated'] == 1;

                            return FutureBuilder<ApiEvent?>(
                              future: _apiService.getEventById(eventId),
                              builder: (context, snapshot) {
                                final eventName =
                                    snapshot.data?.title ?? 'Event #$eventId';
                                final eventDate =
                                    snapshot.data?.date ?? 'Unknown Date';

                                return ListTile(
                                  leading: Container(
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
                                  title: Text(eventName),
                                  subtitle: Text(eventDate),
                                  trailing: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: verified
                                          ? AppColors.success.withOpacity(0.1)
                                          : Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      verified
                                          ? '+$participationPoints pts'
                                          : 'Pending',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: verified
                                            ? AppColors.success
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                ),

                // Disclaimer
                const SizedBox(height: 16),
                Text(
                  'Note: Participation records and points are updated once every 24 hours.',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Model classes for the dashboard
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
