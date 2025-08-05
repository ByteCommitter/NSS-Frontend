import 'package:flutter/material.dart';
import 'package:mentalsustainability/theme/app_colors.dart';

// Update model class to include all needed properties
class NSTeamMember {
  final String id;
  final String name;
  final String role;
  final String description;
  final String specialty;
  final String bio;
  final Color bookColor;
  final List<String> presetMessages;
  final IconData icon;

  NSTeamMember({
    required this.id,
    required this.name,
    required this.role,
    required this.description,
    required this.specialty,
    required this.bio,
    required this.bookColor,
    required this.presetMessages,
    required this.icon,
  });
}

class CommunityPage extends StatefulWidget {
  const CommunityPage({Key? key}) : super(key: key);

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Change TabController length from 3 to 2 (removing Threads)
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
      body: Stack(
        children: [
          // Original community content (visible underneath the overlay)
          Column(
            children: [
              // Tab bar for navigation - removed "Threads" tab
              Container(
                color: AppColors.primary,
                child: TabBar(
                  controller: _tabController,
                  tabs: const [
                    Tab(text: 'NSS Team'),
                    Tab(text: 'Seremate'),
                  ],
                  indicatorColor: Colors.white,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white70,
                ),
              ),

              // Tab content - removed Threads tab
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // NSS Team tab
                    _buildSereineTeamTab(),

                    // Seremate tab
                    _buildSeremateTab(),
                  ],
                ),
              ),
            ],
          ),

          // Hazy semi-transparent overlay with "Coming Soon" message
          // Increased opacity from 0.85 to 0.92 (more opaque)
          _buildComingSoonOverlay(),
        ],
      ),
    );
  }

  // Coming soon overlay with increased opacity
  Widget _buildComingSoonOverlay() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.white.withOpacity(1),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Remove the infinite animation loop - just use a static icon
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.groups,
                size: 64,
                color: AppColors.primary.withOpacity(0.7),
              ),
            ),

            const SizedBox(height: 32),

            // Coming soon text
            Text(
              "Community Features Coming Soon!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                "We're working on bringing you enhanced community features, including NSS Team and Seremate services to support student mental health and wellbeing.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[700],
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 32),

            // Teasers about the features
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildFeaturePreview(
                    Icons.people_outline,
                    "The Student's Anonymous",
                    "The Student's Anonymous team that addresses student issues",
                    Colors.purple,
                  ),
                  const SizedBox(height: 16),
                  _buildFeaturePreview(
                    Icons.support_agent,
                    "Seremate",
                    "Support for students facing loneliness and depression",
                    Colors.teal,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 50)
          ],
        ),
      ),
    );
  }

  // Helper method to build feature preview
  Widget _buildFeaturePreview(
      IconData icon, String title, String description, Color color) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
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
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Placeholder content for Sereine Team tab
  Widget _buildSereineTeamTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.purple.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.people,
                        color: Colors.purple,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'About NSS Team',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'The NSS Team is a group of anonymous student volunteers who help address various student issues on campus. The team works to create a supportive environment and resolve challenges faced by students.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Our Mission',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'To provide anonymous support and assistance to students facing various challenges, creating a safer and more inclusive campus environment.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'How to Reach Us',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildContactMethod(
                  Icons.email_outlined,
                  'Email',
                  'Send us an anonymous email',
                ),
                const SizedBox(height: 12),
                _buildContactMethod(
                  Icons.chat_bubble_outline,
                  'Chat',
                  'Chat anonymously with our team members',
                ),
                const SizedBox(height: 12),
                _buildContactMethod(
                  Icons.forum_outlined,
                  'Forum',
                  'Post your concerns in our private forum',
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper to build contact method
  Widget _buildContactMethod(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.purple.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.purple,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Placeholder content for Seremate tab
  Widget _buildSeremateTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.volunteer_activism,
                        color: Colors.teal,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'About Seremate',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Seremate is a specialized support service that helps students dealing with loneliness, depression, and other mental health challenges on campus. Our trained volunteers provide confidential support and resources.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Our Services',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                _buildServiceItem(
                  Icons.chat,
                  'One-on-One Support',
                  'Connect with a dedicated volunteer',
                ),
                const SizedBox(height: 12),
                _buildServiceItem(
                  Icons.groups,
                  'Group Sessions',
                  'Join peer support groups',
                ),
                const SizedBox(height: 12),
                _buildServiceItem(
                  Icons.auto_stories,
                  'Resources',
                  'Access mental health resources',
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Get Help Now',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.health_and_safety,
                        color: Colors.teal,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Immediate Support',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Feeling overwhelmed? Connect with a support volunteer now',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: null, // Disabled for now
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Request Support'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper to build service item
  Widget _buildServiceItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.teal,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
