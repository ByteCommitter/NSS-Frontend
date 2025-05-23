import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/theme/app_colors.dart'; // Add theme import

class ModeratorDashboard extends StatefulWidget {
  const ModeratorDashboard({super.key});

  @override
  State<ModeratorDashboard> createState() => _ModeratorDashboardState();
}

class _ModeratorDashboardState extends State<ModeratorDashboard> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  // Sample data
  final List<Map<String, dynamic>> _reportedPosts = [
    {
      'id': 'r1',
      'username': 'AnxiousMind22',
      'content': 'This medication is definitely better than what doctors prescribe!',
      'timeAgo': '3h ago',
      'reportCount': 4,
      'reportReason': 'False medical information',
      'action': 'pending',
    },
    {
      'id': 'r2',
      'username': 'DepressedThoughts',
      'content': 'I feel like no one cares anymore. What\'s the point of continuing?',
      'timeAgo': '1d ago',
      'reportCount': 2,
      'reportReason': 'Self-harm concerns',
      'action': 'pending',
    },
    {
      'id': 'r3',
      'username': 'AngryUser44',
      'content': '[Content hidden due to violation of community guidelines]',
      'timeAgo': '5h ago',
      'reportCount': 7,
      'reportReason': 'Harassment',
      'action': 'removed',
    },
  ];
  
  final List<Map<String, dynamic>> _bannedUsers = [
    {
      'username': 'ToxicBehavior12',
      'banDate': '2023-11-15',
      'banReason': 'Multiple instances of harassment',
      'postViolations': 5,
    },
    {
      'username': 'SpamBot99',
      'banDate': '2023-11-10',
      'banReason': 'Spam content',
      'postViolations': 12,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Moderator Dashboard', 
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.orange, // Keep orange for moderator interface
        foregroundColor: AppColors.white, // Use theme color
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.white, // Use theme color
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppColors.white, // Use theme color
          tabs: const [
            Tab(text: 'Reported Content'),
            Tab(text: 'Banned Users'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportedContentTab(),
          _buildBannedUsersTab(),
        ],
      ),
    );
  }
  
  Widget _buildReportedContentTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Posts Flagged by Community',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_reportedPosts.where((p) => p['action'] == 'pending').length} posts need review',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 16),
        
        ..._reportedPosts.map((post) => _buildReportedPostCard(post)),
      ],
    );
  }
  
  Widget _buildReportedPostCard(Map<String, dynamic> post) {
    final isPending = post['action'] == 'pending';
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: isPending ? 2 : 1,
      color: isPending ? null : Colors.grey[100],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isPending 
          ? BorderSide(color: Colors.orange.withOpacity(0.5), width: 1.5)
          : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.deepPurple.withOpacity(0.2),
                  child: Text(
                    post['username'].substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.deepPurple,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post['username'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        post['timeAgo'],
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isPending ? Colors.orange.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isPending ? Colors.orange.withOpacity(0.5) : Colors.grey.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPending ? Icons.flag : Icons.check_circle_outline,
                        size: 14,
                        color: isPending ? Colors.orange : Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isPending ? 'Needs Review' : 'Handled',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isPending ? Colors.orange : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Post content
            Text(post['content']),
            const SizedBox(height: 16),
            
            // Report details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.report_problem_outlined, size: 16, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        'Reported ${post['reportCount']} times',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Reason: ${post['reportReason']}',
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            
            // Action buttons
            if (isPending)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        // Mark as safe
                        setState(() {
                          post['action'] = 'approved';
                        });
                        
                        Get.snackbar(
                          'Post Approved',
                          'Post has been marked as safe',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green[100],
                          colorText: Colors.green[800],
                          margin: const EdgeInsets.all(16),
                          borderRadius: 8,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                      child: const Text('Approve'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {
                        // Show warning to user
                        setState(() {
                          post['action'] = 'warned';
                        });
                        
                        Get.snackbar(
                          'Warning Issued',
                          'User has been warned',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.amber[100],
                          colorText: Colors.amber[800],
                          margin: const EdgeInsets.all(16),
                          borderRadius: 8,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.amber,
                      ),
                      child: const Text('Warn User'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        // Remove post and possibly ban user
                        setState(() {
                          post['action'] = 'removed';
                        });
                        
                        Get.snackbar(
                          'Post Removed',
                          'The post has been removed from community',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.red[100],
                          colorText: Colors.red[800],
                          margin: const EdgeInsets.all(16),
                          borderRadius: 8,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Remove'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildBannedUsersTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Banned Users',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_bannedUsers.length} active bans',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        ..._bannedUsers.map((user) => _buildBannedUserCard(user)),
      ],
    );
  }
  
  Widget _buildBannedUserCard(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.red.withOpacity(0.2),
                  child: Text(
                    user['username'].substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user['username'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'BANNED',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Banned on: ${user['banDate']}',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Ban details
            Row(
              children: [
                const Icon(Icons.gavel, size: 16, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  'Reason: ${user['banReason']}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.warning_amber, size: 16, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'Post violations: ${user['postViolations']}',
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () {
                    // Show user activity
                    Get.snackbar(
                      'User Activity',
                      'Loading ${user['username']}\'s activity history...',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.grey[100],
                      colorText: Colors.grey[800],
                      margin: const EdgeInsets.all(16),
                      borderRadius: 8,
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                  ),
                  child: const Text('View Activity'),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                    // Unban user
                    setState(() {
                      _bannedUsers.remove(user);
                    });
                    
                    Get.snackbar(
                      'User Unbanned',
                      '${user['username']} has been unbanned',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green[100],
                      colorText: Colors.green[800],
                      margin: const EdgeInsets.all(16),
                      borderRadius: 8,
                    );
                  },
                  icon: const Icon(Icons.undo, size: 16),
                  label: const Text('Unban User'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
