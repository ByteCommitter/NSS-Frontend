import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/theme/app_colors.dart';

class UsersManagement extends StatefulWidget {
  const UsersManagement({Key? key}) : super(key: key);

  @override
  State<UsersManagement> createState() => _UsersManagementState();
}

class _UsersManagementState extends State<UsersManagement> {
  List<Map<String, dynamic>> users = [];
  bool _isLoading = true;
  String _selectedTab = 'all'; // 'all', 'volunteers', 'pending'

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });
    
    // TODO: Replace with actual API call
    await Future.delayed(const Duration(seconds: 1));
    
    // Mock data
    users = [
      {
        'id': 1,
        'university_id': 'f20220123',
        'username': 'John Doe',
        'email': 'john@university.edu',
        'points': 150,
        'isVolunteer': 1,
        'isWishVolunteer': 0,
        'isAdmin': 0,
        'joined_date': '2024-01-10',
        'status': 'active',
      },
      {
        'id': 2,
        'university_id': 'f20220456',
        'username': 'Jane Smith',
        'email': 'jane@university.edu',
        'points': 75,
        'isVolunteer': 0,
        'isWishVolunteer': 1,
        'isAdmin': 0,
        'joined_date': '2024-01-12',
        'status': 'active',
      },
      // Add more mock users
    ];
    
    setState(() {
      _isLoading = false;
    });
  }

  List<Map<String, dynamic>> get filteredUsers {
    switch (_selectedTab) {
      case 'volunteers':
        return users.where((user) => user['isVolunteer'] == 1).toList();
      case 'pending':
        return users.where((user) => user['isWishVolunteer'] == 1 && user['isVolunteer'] == 0).toList();
      default:
        return users;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Users Management',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildTabButton('all', 'All Users'),
                          const SizedBox(width: 8),
                          _buildTabButton('volunteers', 'Volunteers'),
                          const SizedBox(width: 8),
                          _buildTabButton('pending', 'Pending Requests'),
                        ],
                      ),
                    ],
                  ),
                ),
                
                Expanded(
                  child: filteredUsers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64, 
                                color: Colors.grey,
                                semanticLabel: 'Users', // Add semantic label
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _selectedTab == 'volunteers'
                                    ? 'No volunteers found'
                                    : _selectedTab == 'pending'
                                        ? 'No pending requests'
                                        : 'No users found',
                                style: const TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadUsers,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: filteredUsers.length,
                            itemBuilder: (context, index) {
                              final user = filteredUsers[index];
                              return _buildUserCard(user);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildTabButton(String value, String label) {
    final isSelected = _selectedTab == value;
    return ElevatedButton(
      onPressed: () {
        setState(() {
          _selectedTab = value;
        });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? AppColors.primary : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black,
        elevation: isSelected ? 2 : 0,
      ),
      child: Text(label),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Text(
                    user['username']?.toString().substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['username'] ?? 'Unknown User',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        user['university_id'] ?? 'No ID',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                if (user['isAdmin'] == 1)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ADMIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (user['isVolunteer'] == 1)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'VOLUNTEER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text('${user['points']} points'),
                const SizedBox(width: 16),
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('Joined ${user['joined_date']}'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (user['isWishVolunteer'] == 1 && user['isVolunteer'] == 0) ...[
                  ElevatedButton.icon(
                    onPressed: () => _approveVolunteer(user),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Approve'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton.icon(
                    onPressed: () => _rejectVolunteer(user),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Reject'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ] else if (user['isVolunteer'] == 1) ...[
                  OutlinedButton.icon(
                    onPressed: () => _removeVolunteer(user),
                    icon: const Icon(Icons.remove_circle, size: 16),
                    label: const Text('Remove Volunteer'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ] else ...[
                  OutlinedButton.icon(
                    onPressed: () => _makeVolunteer(user),
                    icon: const Icon(Icons.add_circle, size: 16),
                    label: const Text('Make Volunteer'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _approveVolunteer(Map<String, dynamic> user) {
    // TODO: Implement approve volunteer API call
    Get.snackbar(
      'Feature Coming Soon',
      'Approve volunteer functionality will be implemented with API integration',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _rejectVolunteer(Map<String, dynamic> user) {
    // TODO: Implement reject volunteer API call
    Get.snackbar(
      'Feature Coming Soon',
      'Reject volunteer functionality will be implemented with API integration',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _removeVolunteer(Map<String, dynamic> user) {
    // TODO: Implement remove volunteer API call
    Get.snackbar(
      'Feature Coming Soon',
      'Remove volunteer functionality will be implemented with API integration',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void _makeVolunteer(Map<String, dynamic> user) {
    // TODO: Implement make volunteer API call
    Get.snackbar(
      'Feature Coming Soon',
      'Make volunteer functionality will be implemented with API integration',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
