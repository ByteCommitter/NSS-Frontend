import 'package:flutter/material.dart';
import 'package:mentalsustainability/theme/app_colors.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  // TODO: Fetch user points data from backend API
  // Sample current month points data
  final int _currentMonthPoints = 180;
  
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
              _buildMonthlyPointsCard(_currentMonthPoints),
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
