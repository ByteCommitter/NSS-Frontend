import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/models/admin_models.dart';  // Import our models
import 'package:mentalsustainability/services/api_service.dart';
import 'package:mentalsustainability/theme/app_colors.dart';

class AdminUserManagement extends StatefulWidget {
  const AdminUserManagement({super.key});

  @override
  State<AdminUserManagement> createState() => _AdminUserManagementState();
}

class _AdminUserManagementState extends State<AdminUserManagement> {
  final ApiService _apiService = Get.find<ApiService>();
  List<AdminUser> _users = []; // Changed to AdminUser
  bool _isLoading = true;
  String _searchQuery = '';
  
  @override
  void initState() {
    super.initState();
    _loadUsers();
  }
  
  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // API call to get users - will need to be implemented in ApiService
      final users = await _apiService.getAdminUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading users: $e');
      // For now, use sample data
      setState(() {
        _users = [
          AdminUser(
            id: 'u1',
            name: 'Rajesh Kumar',
            points: 780,
            imageUrl: 'assets/images/profile1.jpg',
            rank: 1,
          ),
          AdminUser(
            id: 'u2',
            name: 'Priya Singh',
            points: 720,
            imageUrl: 'assets/images/profile2.jpg',
            rank: 2,
          ),
          AdminUser(
            id: 'u3',
            name: 'Amit Sharma',
            points: 690,
            imageUrl: 'assets/images/profile3.jpg',
            rank: 3,
          ),
        ];
        _isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Failed to load users. Using sample data.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
    }
  }
  
  List<AdminUser> get _filteredUsers {
    if (_searchQuery.isEmpty) {
      return _users;
    }
    
    final query = _searchQuery.toLowerCase();
    return _users.where((user) => 
      user.name.toLowerCase().contains(query) || 
      user.id.toLowerCase().contains(query)
    ).toList();
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search users...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          
          // User stats overview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCard(
                      icon: Icons.people,
                      title: 'Total Users',
                      value: _users.length.toString(),
                      color: AppColors.primary,
                    ),
                    _buildStatCard(
                      icon: Icons.verified_user,
                      title: 'Active Users',
                      value: _users.length.toString(), // This would be a different value in reality
                      color: AppColors.success,
                    ),
                    _buildStatCard(
                      icon: Icons.event_available,
                      title: 'Total Events',
                      value: '12', // This would come from actual data
                      color: Colors.orange,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Users list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadUsers,
                    child: _filteredUsers.isEmpty
                        ? const Center(child: Text('No users found'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = _filteredUsers[index];
                              return Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundImage: user.imageUrl != null
                                        ? AssetImage(user.imageUrl!)
                                        : null,
                                    child: user.imageUrl == null
                                        ? Text(user.name[0])
                                        : null,
                                  ),
                                  title: Text(user.name),
                                  subtitle: Text('ID: ${user.id}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: AppColors.primary.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '${user.points} points',
                                          style: TextStyle(
                                            color: AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      IconButton(
                                        icon: const Icon(Icons.visibility),
                                        onPressed: () => _showUserDetails(user),
                                        color: AppColors.primary,
                                      ),
                                    ],
                                  ),
                                  onTap: () => _showUserDetails(user),
                                ),
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
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
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
  
  void _showUserDetails(AdminUser user) { // Changed to AdminUser
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          width: 400,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: user.imageUrl != null
                        ? AssetImage(user.imageUrl!)
                        : null,
                    child: user.imageUrl == null
                        ? Text(
                            user.name[0],
                            style: const TextStyle(fontSize: 24),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'User ID: ${user.id}',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              
              // Stats
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildUserStat('Points', user.points.toString()),
                  _buildUserStat('Rank', '#${user.rank}'),
                  _buildUserStat('Events', '5'), // This would be a real value
                ],
              ),
              
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 10),
              
              // Actions
              const Text(
                'Actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    icon: Icons.edit,
                    label: 'Edit User',
                    onTap: () {
                      Get.back();
                      // Show edit user dialog
                    },
                    color: AppColors.primary,
                  ),
                  _buildActionButton(
                    icon: Icons.history,
                    label: 'Activity Log',
                    onTap: () {
                      Get.back();
                      // Show activity log
                    },
                    color: Colors.orange,
                  ),
                  _buildActionButton(
                    icon: Icons.block,
                    label: 'Block User',
                    onTap: () {
                      Get.back();
                      // Show block confirmation
                    },
                    color: AppColors.error,
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildUserStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
  
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required Color color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
