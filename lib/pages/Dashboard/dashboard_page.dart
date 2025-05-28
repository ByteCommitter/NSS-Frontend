import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/theme/app_colors.dart';
import 'package:mentalsustainability/services/api_service.dart';
import 'package:mentalsustainability/services/auth_service.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ApiService _apiService = Get.find<ApiService>();
  final AuthService _authService = Get.find<AuthService>();
  
  // State variables for API data
  int _totalPoints = 0;
  bool _isLoadingPoints = true;
  
  List<User> _topUsers = [];
  bool _isLoadingTopUsers = true;
  
  List<EventParticipation> _recentParticipations = [];
  bool _isLoadingParticipations = true;
  
  // Remove the hardcoded participations since we'll load them from API
  // Sample badges earned - kept for now
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

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
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
  
  // Load recent participations
  Future<void> _loadRecentParticipations() async {
    if (!mounted) return; // Add mounted check
    
    setState(() {
      _isLoadingParticipations = true;
    });
    
    try {
      final userId = await _authService.getUserId();
      if (userId != null) {
        final participations = await _apiService.getRecentParticipations(userId);
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
              
              // Badges Earned
              _buildBadgesCard(_badges),
              const SizedBox(height: 32),
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
                  'Your Total Points',  // Changed from "Monthly Points" to "Total Points"
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
            _isLoadingTopUsers
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: CircularProgressIndicator(),
                  ),
                )
              : users.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
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
                  ),
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
  Widget _buildBadgesCard(List<Badge> badges) {
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
  
  // Add a variable to store all participations for the history dialog
  List<Map<String, dynamic>> _allParticipations = [];
  bool _isLoadingAllParticipations = false;
  
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: const Offset(0.0, 10.0),
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
                      size: 28,
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'Participation History',
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
                
                // Points summary
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                            final eventId = participation['event_id']?.toString() ?? 'Unknown';
                            final participationPoints = participation['points'] ?? 0;
                            final verified = participation['isParticipated'] == 1;
                            
                            return FutureBuilder<ApiEvent?>(
                              future: _apiService.getEventById(eventId),
                              builder: (context, snapshot) {
                                final eventName = snapshot.data?.title ?? 'Event #$eventId';
                                final eventDate = snapshot.data?.date ?? 'Unknown Date';
                                
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
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: verified 
                                          ? AppColors.success.withOpacity(0.1)
                                          : Colors.grey.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      verified ? '+$participationPoints pts' : 'Pending',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: verified ? AppColors.success : Colors.grey,
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
