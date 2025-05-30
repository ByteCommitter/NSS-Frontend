import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async'; // Add import for Timer
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

  // Add a map to track operations in progress for specific users
  final Map<String, bool> _operationsInProgress = {};

  // Debounce for operations to prevent multiple rapid clicks
  DateTime? _lastOperationTime;
  
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
    _operationsInProgress.clear();
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
      
      // Use a try-catch to fetch data from API
      List<Map<String, dynamic>> allUsers = [];
      try {
        allUsers = await _apiService.getAllUsers();
        print('Successfully loaded ${allUsers.length} users from API');
        
        // Debug: Print the first user's data if available
        if (allUsers.isNotEmpty) {
          print('First user sample: ${allUsers[0]}');
        }
      } catch (apiError) {
        print('API error: $apiError - Using mock data instead');
        // Fall back to mock data only if API completely fails
        allUsers = [
          {
            'id': 1,
            'university_id': 'f20220123',
            'username': 'John Doe',
            'isVolunteer': 1,
            'isWishVolunteer': 0,
            'isAdmin': 0,
            // Don't include points in mock data since we don't know if API provides it
          },
          {
            'id': 2,
            'university_id': 'f20220456',
            'username': 'Jane Smith',
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
    
    // FIXED: Apply tab filter with proper boolean logic
    switch (_selectedTab) {
      case 'volunteers':
        result = result.where((user) => 
          (user['isVolunteer'] == 1 || user['isVolunteer'] == true)
        ).toList();
        break;
      case 'pending':
        result = result.where((user) => 
          (user['isWishVolunteer'] == 1 || user['isWishVolunteer'] == true) && 
          !(user['isVolunteer'] == 1 || user['isVolunteer'] == true)
        ).toList();
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

  // Replace the _safeOperation method with this completely redesigned version
  Future<void> _safeOperation(Map<String, dynamic> user, String operationType, 
      Future<bool> Function() apiCall, Function(Map<String, dynamic>) updateUserState) async {
    final universityId = user['university_id'];
    
    // Much stronger debouncing - ignore operations within 2 seconds
    final now = DateTime.now();
    if (_lastOperationTime != null && 
        now.difference(_lastOperationTime!).inMilliseconds < 2000) {
      print('STRICT DEBOUNCE: Operation ignored - too soon after last operation');
      return;
    }
    _lastOperationTime = now;
    
    // Double-check we're not already in an operation
    if (_isApiCalling) {
      print('GLOBAL OPERATION LOCK: API already calling, ignoring request');
      return;
    }
    
    // Mark global operation in progress - prevent ANY operations while one is in progress
    setState(() {
      _isApiCalling = true;
    });
    
    print('Starting $operationType operation for user: $universityId');
    
    // Use simple local variable to track if operation completed
    bool operationCompleted = false;
    
    // Set a timeout to forcibly end the operation after 3 seconds
    // Use a more reliable approach with microtask scheduling
    Future.delayed(const Duration(seconds: 3), () {
      if (!operationCompleted) {
        print('FORCE TIMEOUT: Operation $operationType for user $universityId');
        // Force cleanup without waiting for anything
        if (mounted) {
          // Reset ALL state to ensure we break any loops
          setState(() {
            _isApiCalling = false;
            _operationsInProgress.clear(); // Clear ALL operations
          });
        }
        
        // Show timeout message
        Get.closeAllSnackbars();
        Get.snackbar(
          'Operation Timeout',
          'The operation took too long and was cancelled',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange.withOpacity(0.1),
          colorText: Colors.orange,
          duration: const Duration(seconds: 2),
        );
      }
    });
    
    try {
      // Show loading indicator inline in the UI instead of a dialog
      // This avoids any dialog management issues
      
      // Execute the API call directly without a dialog
      final success = await apiCall();
      print('API call completed for user $universityId, success: $success');
      
      // Mark operation as completed to prevent timeout from firing
      operationCompleted = true;
      
      if (success) {
        // Update user state
        if (mounted) {
          setState(() {
            // Update the user
            updateUserState(user);
            // Reset ALL flags to ensure clean state
            _isApiCalling = false;
          });
          
          // Apply filters separately to avoid loops
          Future.microtask(() {
            if (mounted) {
              setState(() {
                _applyFiltersInternal();
              });
            }
          });
        }
        
        // Show success message AFTER state is updated
        Future.microtask(() {
          Get.closeAllSnackbars();
          Get.snackbar(
            'Success',
            'Operation completed successfully',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green.withOpacity(0.1),
            colorText: Colors.green,
            duration: const Duration(seconds: 2),
          );
        });
      } else {
        // Handle failure
        if (mounted) {
          setState(() {
            _isApiCalling = false;
          });
        }
        
        Future.microtask(() {
          Get.closeAllSnackbars();
          Get.snackbar(
            'Error',
            'Operation failed',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red.withOpacity(0.1),
            colorText: Colors.red,
            duration: const Duration(seconds: 2),
          );
        });
      }
    } catch (e) {
      // Mark operation as completed to prevent timeout from firing
      operationCompleted = true;
      
      print('Error in $operationType: $e');
      
      // Reset state
      if (mounted) {
        setState(() {
          _isApiCalling = false;
        });
      }
      
      Future.microtask(() {
        Get.closeAllSnackbars();
        Get.snackbar(
          'Error',
          'An error occurred: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
          duration: const Duration(seconds: 2),
        );
      });
    }
  }
  
  Widget _buildUserCard(Map<String, dynamic> user) {
    final universityId = user['university_id'];
    final isOperationInProgress = _isApiCalling;
    
    // FIXED: Parse volunteer status properly - handle both int and bool values
    final isVolunteer = (user['isVolunteer'] == 1 || user['isVolunteer'] == true);
    final isWishVolunteer = (user['isWishVolunteer'] == 1 || user['isWishVolunteer'] == true);
    final isAdmin = (user['isAdmin'] == 1 || user['isAdmin'] == true);
    
    print('User ${user['username']}: isVolunteer=$isVolunteer, isWishVolunteer=$isWishVolunteer');
    
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
                if (isAdmin)
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
                if (isVolunteer)
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
                if (isWishVolunteer && !isVolunteer)
                  Container(
                    margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'PENDING',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // If any operation is in progress, disable all buttons across the UI
                if (isOperationInProgress) ...[
                  // Show loading indicator instead of buttons when any operation is in progress
                  const Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: LinearProgressIndicator(),
                      ),
                    ),
                  ),
                ] else if (isWishVolunteer && !isVolunteer) ...[
                  // FIXED: User has requested to be volunteer - show approve/reject options
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
                ] else if (isVolunteer) ...[
                  // FIXED: User is already a volunteer - show remove option
                  OutlinedButton.icon(
                    onPressed: () => _removeVolunteer(user),
                    icon: const Icon(Icons.remove_circle, size: 16),
                    label: const Text('Remove Volunteer'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                    ),
                  ),
                ] else ...[
                  // FIXED: User is not a volunteer and hasn't requested - show make volunteer option
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
                  onPressed: isOperationInProgress ? null : () => _confirmDeleteUser(user),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Use the new safeOperation method for all volunteer operations
  void _makeVolunteer(Map<String, dynamic> user) {
    _safeOperation(
      user, 
      'make_volunteer',
      () => _apiService.makeVolunteer(user['university_id']),
      (u) => u['isVolunteer'] = 1
    );
  }

  void _removeVolunteer(Map<String, dynamic> user) {
    _safeOperation(
      user, 
      'remove_volunteer',
      () => _apiService.removeVolunteer(user['university_id']),
      (u) => u['isVolunteer'] = 0
    );
  }

  void _approveVolunteer(Map<String, dynamic> user) {
    _safeOperation(
      user, 
      'approve_volunteer',
      () => _apiService.makeVolunteer(user['university_id']),
      (u) {
        u['isVolunteer'] = 1;
        u['isWishVolunteer'] = 0;
      }
    );
  }

  void _rejectVolunteer(Map<String, dynamic> user) {
    _safeOperation(
      user, 
      'reject_volunteer',
      () => _apiService.rejectVolunteerRequest(user['university_id']),
      (u) => u['isWishVolunteer'] = 0
    );
  }
  
  // Update the delete user method as well
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
              if (_isApiCalling) {
                print('API already in progress, ignoring request');
                return;
              }
              
              Get.back(); // Close confirmation dialog
              
              setState(() {
                _isApiCalling = true;
              });
              
              // Show loading indicator
              Get.dialog(
                const Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );
              
              try {
                final universityId = user['university_id'];
                print('Deleting user: $universityId');
                
                final success = await _apiService.deleteUser(universityId);
                
                // Close loading dialog
                if (Get.isDialogOpen ?? false) {
                  Get.back();
                }
                
                if (success) {
                  // Remove user from list directly instead of reloading
                  setState(() {
                    users.removeWhere((u) => u['university_id'] == universityId);
                    _applyFiltersInternal();
                    _isApiCalling = false;
                  });
                  
                  Get.snackbar(
                    'Success',
                    'User has been deleted',
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
                    'Failed to delete user',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.withOpacity(0.1),
                    colorText: Colors.red,
                  );
                }
              } catch (e) {
                // Close loading dialog if still showing
                if (Get.isDialogOpen ?? false) {
                  Get.back();
                }
                
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
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
