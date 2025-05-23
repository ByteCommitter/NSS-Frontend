import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/theme/app_colors.dart'; // Add theme import

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Mock user data
  final Map<String, dynamic> _userData = {
    'name': 'Alex Johnson',  // Real name
    'anonymousName': 'SereneSpirit42',  // Anonymous username for community
    'email': 'alex.johnson@example.com',
    'joinDate': 'March 2023',
    'points': 1250,
    'completedQuests': 42,
    'achievements': [
      {
        'name': 'Eco Warrior',
        'description': 'Completed 10 sustainability challenges',
        'icon': Icons.nature_people,
        'color': AppColors.success, // Use theme color
        'level': 2,
      },
      {
        'name': 'Mindfulness Master',
        'description': 'Practiced mindfulness for 30 days',
        'icon': Icons.self_improvement,
        'color': AppColors.info, // Use theme color
        'level': 3,
      },
      {
        'name': 'Community Leader',
        'description': 'Helped 5 other community members',
        'icon': Icons.people,
        'color': AppColors.warning, // Use theme color
        'level': 1,
      },
      {
        'name': 'Knowledge Seeker',
        'description': 'Completed all educational modules',
        'icon': Icons.school,
        'color': AppColors.primary, // Use theme color
        'level': 2,
      },
    ],
    'interests': ['Meditation', 'Sustainability', 'Mental Health'],
    'avatarColor': AppColors.primary, // Use theme color
  };

  // For editing profile
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _anonymousNameController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _userData['name']);
    _anonymousNameController = TextEditingController(text: _userData['anonymousName']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _anonymousNameController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      if (_isEditing) {
        // Save changes
        if (_formKey.currentState!.validate()) {
          _userData['anonymousName'] = _anonymousNameController.text;
          
          Get.snackbar(
            'Profile Updated',
            'Your anonymous username has been updated successfully.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.success.withOpacity(0.1), // Use theme color
            colorText: AppColors.success, // Use theme color
            margin: const EdgeInsets.all(16),
            borderRadius: 8,
            duration: const Duration(seconds: 3),
          );
        } else {
          // Return without toggling if validation fails
          return;
        }
      } else {
        // Reset controllers when entering edit mode
        _anonymousNameController.text = _userData['anonymousName'];
      }
      _isEditing = !_isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header with real name
            _buildProfileHeader(),
            
            const SizedBox(height: 12),
            
            // Anonymous username section
            _buildAnonymousUsernameSection(),
            
            const SizedBox(height: 12),
            
            // Statistics section
            _buildStatisticsSection(),
            
            const SizedBox(height: 12),
            
            // Enhanced Achievements section
            _buildEnhancedAchievementsSection(),
            
            const SizedBox(height: 12),
            
            // Interests section
            _buildInterestsSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildProfileHeader() {
    return Row(
      children: [
        // Avatar
        CircleAvatar(
          radius: 40,
          backgroundColor: _userData['avatarColor'],
          child: Text(
            _userData['name'].substring(0, 1).toUpperCase(),
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: AppColors.white, // Use theme color
            ),
          ),
        ),
        const SizedBox(width: 20),
        
        // Real name and points
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Real name
              Text(
                _userData['name'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Points display
              Row(
                children: [
                  Icon(Icons.stars, color: AppColors.warning, size: 20), // Use theme color
                  const SizedBox(width: 4),
                  Text(
                    '${_userData['points']} points',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.primary, // Use theme color
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

  // New method for anonymous username section
  Widget _buildAnonymousUsernameSection() {
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
                Row(
                  children: [
                    Icon(Icons.person_outline, color: AppColors.primary), // Use theme color
                    const SizedBox(width: 8),
                    const Text(
                      'Community Username',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: _toggleEditMode,
                  icon: Icon(
                    _isEditing ? Icons.save : Icons.edit,
                    color: AppColors.primary, // Use theme color
                  ),
                  tooltip: 'Change anonymous username',
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // Anonymous name display or edit form
            if (_isEditing)
              _buildEditForm()
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1), // Use theme color
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)), // Use theme color
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.shield, size: 16, color: AppColors.primary), // Use theme color
                            const SizedBox(width: 6),
                            Text(
                              _userData['anonymousName'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primary, // Use theme color
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1), // Use theme color
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.success.withOpacity(0.3)), // Use theme color
                        ),
                        child: Text(
                          'Anonymous',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.success, // Use theme color
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This is your anonymous identity in the community section.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary, // Use theme color
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Anonymous username field
          TextFormField(
            controller: _anonymousNameController,
            decoration: InputDecoration(
              labelText: 'Anonymous Username',
              helperText: 'This name will be visible in the community tab',
              prefixIcon: const Icon(Icons.person_outline),
              suffixIcon: IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Generate random username',
                onPressed: () {
                  // Generate a random username
                  final options = [
                    'MindfulWanderer',
                    'SereneSpirit',
                    'CalmExplorer',
                    'PeacefulJourney',
                    'GentleSoul',
                    'TransquilThinker',
                    'QuietObserver',
                    'ZenPathfinder'
                  ];
                  final random = DateTime.now().millisecondsSinceEpoch % options.length;
                  final randomNum = DateTime.now().second % 100;
                  setState(() {
                    _anonymousNameController.text = '${options[random]}$randomNum';
                  });
                },
              ),
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a username';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // Privacy note
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1), // Use theme color
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.info.withOpacity(0.3)), // Use theme color
            ),
            child: Row(
              children: [
                Icon(Icons.privacy_tip_outlined, 
                  color: AppColors.info, // Use theme color
                  size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Your real name is never shown to other community members',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.info, // Use theme color
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Save button
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _toggleEditMode,
              icon: const Icon(Icons.check),
              label: const Text('Save Username'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, // Use theme color
                foregroundColor: AppColors.white, // Use theme color
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatisticsSection() {
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
                _buildStatItem(Icons.task_alt, 'Quests\nCompleted', _userData['completedQuests'].toString()),
                _buildStatItem(Icons.stars, 'Total\nPoints', _userData['points'].toString()),
                _buildStatItem(Icons.emoji_events, 'Achievements', _userData['achievements'].length.toString()),
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
              itemCount: _userData['achievements'].length,
              itemBuilder: (context, index) {
                final achievement = _userData['achievements'][index];
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
  
  Widget _buildInterestsSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Interests',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _userData['interests']
                  .map<Widget>((interest) => Chip(
                        avatar: Icon(Icons.favorite, color: AppColors.primary, size: 16), // Use theme color
                        label: Text(interest),
                        backgroundColor: AppColors.primary.withOpacity(0.1), // Use theme color
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
