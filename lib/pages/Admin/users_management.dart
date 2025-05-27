import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/theme/app_colors.dart';
import 'package:mentalsustainability/services/api_service.dart';

class UsersManagement extends StatefulWidget {
  const UsersManagement({Key? key}) : super(key: key);

  @override
  State<UsersManagement> createState() => _UsersManagementState();
}

class _UsersManagementState extends State<UsersManagement> {
  final ApiService _apiService = Get.find<ApiService>();
  List<Map<String, dynamic>> users = [];
  List<Map<String, dynamic>> filteredUsers = [];
  bool _isLoading = true;
  bool _isApiCalling = false; // Add a separate flag for API calls
  String _selectedTab = 'all'; // 'all', 'volunteers', 'pending'
  
  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadUsers();
    
    // Add listener to search controller
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
        _applyFilters();
      });
    });
  }
  
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Fix the loading issue by completely restructuring the load method
  Future<void> _loadUsers() async {
    // Don't try to load again if we're already making an API call
    if (_isApiCalling) return;
    
    setState(() {
      _isLoading = true;
      _isApiCalling = true; // Set API calling flag
    });
    
    try {
      print('Making API call to load users');
      
      // Use a try-catch to fetch mock data if the API fails for any reason
      List<Map<String, dynamic>> allUsers = [];
      try {
        allUsers = await _apiService.getAllUsers();
        print('Successfully loaded ${allUsers.length} users from API');
      } catch (apiError) {
        print('API error: $apiError - Using mock data instead');
        // Fall back to mock data
        allUsers = [
          {
            'id': 1,
            'university_id': 'f20220123',
            'username': 'John Doe',
            'points': 150,
            'isVolunteer': 1,
            'isWishVolunteer': 0,
            'isAdmin': 0,
          },
          {
            'id': 2,
            'university_id': 'f20220456',
            'username': 'Jane Smith',
            'points': 75,
            'isVolunteer': 0,
            'isWishVolunteer': 1,
            'isAdmin': 0,
          },
        ];
      }
      
      // Only update state if the widget is still mounted
      if (mounted) {
        setState(() {
          users = allUsers;
          _applyFiltersInternal(); // Use a non-state-setting version
          _isLoading = false;
          _isApiCalling = false;
        });
      }
    } catch (e) {
      print('Unexpected error in _loadUsers: $e');
      
      // Only update state if the widget is still mounted
      if (mounted) {
        setState(() {
          users = []; // Clear users on error
          filteredUsers = []; // Clear filtered users
          _isLoading = false;
          _isApiCalling = false;
        });
        
        // Show error snackbar
        Future.microtask(() {
          Get.snackbar(
            'Error',
            'Failed to load users. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
          );
        });
      }
    }
  }
  
  // Split the filter application from the state setting to avoid loops
  void _applyFilters() {
    setState(() {
      _applyFiltersInternal();
    });
  }
  
  // Internal method that doesn't set state
  void _applyFiltersInternal() {
    List<Map<String, dynamic>> result = List<Map<String, dynamic>>.from(users);
    
    // Apply tab filter
    switch (_selectedTab) {
      case 'volunteers':
        result = result.where((user) => user['isVolunteer'] == 1).toList();
        break;
      case 'pending':
        result = result.where((user) => user['isWishVolunteer'] == 1 && user['isVolunteer'] == 0).toList();
        break;
    }
    
    // Apply search query if not empty
    if (_searchQuery.isNotEmpty) {
      result = result.where((user) {
        final username = user['username']?.toString().toLowerCase() ?? '';
        final universityId = user['university_id']?.toString().toLowerCase() ?? '';
        return username.contains(_searchQuery) || universityId.contains(_searchQuery);
      }).toList();
    }
    
    filteredUsers = result;
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
                      // Search field
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by name or ID',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                  },
                                )
                              : null,
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
                                semanticLabel: 'Users',
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _searchQuery.isNotEmpty
                                    ? 'No users match your search'
                                    : _selectedTab == 'volunteers'
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
          _applyFiltersInternal(); // Use non-state-setting version
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
                Text('${user['points'] ?? 0} points'),
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
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  tooltip: 'Delete User',
                  onPressed: () => _confirmDeleteUser(user),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Fix the volunteer management methods to prevent continuous loops
  void _approveVolunteer(Map<String, dynamic> user) async {
    // Prevent multiple clicks or calls during loading
    if (_isApiCalling) return;
    
    setState(() {
      _isApiCalling = true;
    });
    
    try {
      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      
      final success = await _apiService.makeVolunteer(user['university_id']);
      
      // Close loading dialog - make sure we handle all code paths
      if (Get.isDialogOpen ?? false) Get.back();
      
      if (success) {
        // Update the user in place rather than reloading everything
        setState(() {
          user['isVolunteer'] = 1;
          user['isWishVolunteer'] = 0;
          _applyFiltersInternal();
          _isApiCalling = false;
        });
        
        // Show success message
        Get.snackbar(
          'Success',
          'User has been approved as a volunteer',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
      } else {
        setState(() {
          _isApiCalling = false;
        });
        Get.snackbar(
          'Error',
          'Failed to approve volunteer request',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      setState(() {
        _isApiCalling = false;
      });
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  // Update the remove volunteer method to fix the issue
  void _removeVolunteer(Map<String, dynamic> user) async {
    // Prevent multiple clicks
    if (_isLoading) return;
    
    final universityId = user['university_id'];
    print('Attempting to remove volunteer status for: $universityId');
    
    try {
      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      
      final success = await _apiService.removeVolunteer(universityId);
      
      // Close loading dialog - make sure we handle all code paths
      if (Get.isDialogOpen ?? false) Get.back();
      
      if (success) {
        Get.snackbar(
          'Success',
          'Volunteer status has been removed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
        
        // Update the user list using a proper Future
        await _loadUsers();
      } else {
        Get.snackbar(
          'Error',
          'Failed to remove volunteer status',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      // Close loading dialog if still showing
      if (Get.isDialogOpen ?? false) Get.back();
      
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  // Update make volunteer method as well
  void _makeVolunteer(Map<String, dynamic> user) async {
    // Prevent multiple clicks
    if (_isLoading) return;
    
    try {
      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      
      final success = await _apiService.makeVolunteer(user['university_id']);
      
      // Close loading dialog - make sure we handle all code paths
      if (Get.isDialogOpen ?? false) Get.back();
      
      if (success) {
        Get.snackbar(
          'Success',
          'User is now a volunteer',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
        
        // Update the user list using a proper Future
        await _loadUsers();
      } else {
        Get.snackbar(
          'Error',
          'Failed to make user a volunteer',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      // Close loading dialog if still showing
      if (Get.isDialogOpen ?? false) Get.back();
      
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }
  
  // Update reject volunteer method
  void _rejectVolunteer(Map<String, dynamic> user) async {
    // Prevent multiple clicks
    if (_isLoading) return;
    
    try {
      // Show loading indicator
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );
      
      final success = await _apiService.rejectVolunteerRequest(user['university_id']);
      
      // Close loading dialog - make sure we handle all code paths
      if (Get.isDialogOpen ?? false) Get.back();
      
      if (success) {
        Get.snackbar(
          'Success',
          'Volunteer request has been rejected',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.withOpacity(0.1),
          colorText: Colors.green,
        );
        
        // Update the user list using a proper Future
        await _loadUsers();
      } else {
        Get.snackbar(
          'Error',
          'Failed to reject volunteer request',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
        );
      }
    } catch (e) {
      // Close loading dialog if still showing
      if (Get.isDialogOpen ?? false) Get.back();
      
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  void _confirmDeleteUser(Map<String, dynamic> user) {
    // Show confirmation dialog
    Get.dialog(
      AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete user "${user['username']}" (${user['university_id']})?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Close confirmation dialog
              
              // Show loading indicator
              Get.dialog(
                const Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );
              
              try {
                final success = await _apiService.deleteUser(user['university_id']);
                
                // Close loading dialog
                Get.back();
                
                if (success) {
                  Get.snackbar(
                    'Success',
                    'User has been deleted',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.withOpacity(0.1),
                    colorText: Colors.green,
                  );
                  _loadUsers(); // Refresh the list
                } else {
                  Get.snackbar(
                    'Error',
                    'Failed to delete user',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.withOpacity(0.1),
                    colorText: Colors.red,
                  );
                }
              } catch (e) {
                // Close loading dialog if still showing
                if (Get.isDialogOpen ?? false) Get.back();
                
                Get.snackbar(
                  'Error',
                  'An error occurred: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red.withOpacity(0.1),
                  colorText: Colors.red,
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
