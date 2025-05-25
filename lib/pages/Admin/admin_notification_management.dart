import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/models/admin_models.dart';  // Import our models
import 'package:mentalsustainability/services/api_service.dart';
import 'package:mentalsustainability/theme/app_colors.dart';

class AdminNotificationManagement extends StatefulWidget {
  const AdminNotificationManagement({super.key});

  @override
  State<AdminNotificationManagement> createState() => _AdminNotificationManagementState();
}

class _AdminNotificationManagementState extends State<AdminNotificationManagement> {
  final ApiService _apiService = Get.find<ApiService>();
  List<AdminUpdate> _updates = []; // Changed to AdminUpdate
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadUpdates();
  }
  
  Future<void> _loadUpdates() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // API call to get updates - will need to be implemented in ApiService
      final updates = await _apiService.getAdminUpdates();
      setState(() {
        _updates = updates;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading updates: $e');
      // For now, use sample data
      setState(() {
        _updates = [
          AdminUpdate(
            id: 'n1',
            title: 'New Event Registration Open',
            message: 'Tree Plantation Drive registration is now open. Register before June 3rd.',
            time: '2 hours ago',
            isRead: false,
          ),
          AdminUpdate(
            id: 'n2',
            title: 'Reminder: NSS Meetup',
            message: 'Don\'t forget to attend the NSS Annual Meetup on June 12th.',
            time: '1 day ago',
            isRead: true,
          ),
        ];
        _isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Failed to load notifications. Using sample data.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadUpdates,
              child: _updates.isEmpty
                  ? _buildEmptyState()
                  : _buildUpdatesList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showNotificationDialog(),
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications available',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _showNotificationDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add New Notification'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUpdatesList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _updates.length,
      itemBuilder: (context, index) {
        final update = _updates[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(
                Icons.notifications,
                color: AppColors.primary,
              ),
            ),
            title: Text(
              update.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(update.message),
                const SizedBox(height: 4),
                Text(
                  update.time,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showNotificationDialog(update: update),
                  color: AppColors.primary,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteConfirmation(update),
                  color: AppColors.error,
                ),
              ],
            ),
            onTap: () => _showNotificationDialog(update: update),
          ),
        );
      },
    );
  }
  
  void _showNotificationDialog({AdminUpdate? update}) { // Changed to AdminUpdate
    final isEditing = update != null;
    final titleController = TextEditingController(text: update?.title ?? '');
    final messageController = TextEditingController(text: update?.message ?? '');
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          width: 400, // Max width
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Notification' : 'Add New Notification',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(
                  labelText: 'Message',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Option to send as live notification
                  Row(
                    children: [
                      Checkbox(
                        value: true, // Default to true
                        onChanged: (value) {
                          // This would toggle whether to send as live notification
                        },
                      ),
                      const Text('Send as live notification'),
                    ],
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () => Get.back(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          // Validate form
                          if (titleController.text.isEmpty || messageController.text.isEmpty) {
                            Get.snackbar(
                              'Error',
                              'Please fill in all fields',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: AppColors.error.withOpacity(0.1),
                              colorText: AppColors.error,
                            );
                            return;
                          }
                          
                          // Create or update notification
                          if (isEditing) {
                            _updateNotification(
                              update.id,
                              titleController.text,
                              messageController.text,
                            );
                          } else {
                            _createNotification(
                              titleController.text,
                              messageController.text,
                            );
                          }
                          
                          Get.back();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: Text(isEditing ? 'Update' : 'Send'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  Future<void> _createNotification(String title, String message) async {
    try {
      // API call to create notification - will need to be implemented in ApiService
      await _apiService.createNotification(title, message);
      
      Get.snackbar(
        'Success',
        'Notification sent successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withOpacity(0.1),
        colorText: AppColors.success,
      );
      
      _loadUpdates();
    } catch (e) {
      print('Error creating notification: $e');
      Get.snackbar(
        'Error',
        'Failed to send notification: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
    }
  }
  
  Future<void> _updateNotification(String id, String title, String message) async {
    try {
      // API call to update notification - will need to be implemented in ApiService
      await _apiService.updateNotification(id, title, message);
      
      Get.snackbar(
        'Success',
        'Notification updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withOpacity(0.1),
        colorText: AppColors.success,
      );
      
      _loadUpdates();
    } catch (e) {
      print('Error updating notification: $e');
      Get.snackbar(
        'Error',
        'Failed to update notification: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
    }
  }
  
  void _showDeleteConfirmation(AdminUpdate update) { // Changed to AdminUpdate
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Notification'),
        content: Text('Are you sure you want to delete "${update.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _deleteNotification(update.id);
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
  
  Future<void> _deleteNotification(String id) async {
    try {
      // API call to delete notification - will need to be implemented in ApiService
      await _apiService.deleteNotification(id);
      
      Get.snackbar(
        'Success',
        'Notification deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withOpacity(0.1),
        colorText: AppColors.success,
      );
      
      _loadUpdates();
    } catch (e) {
      print('Error deleting notification: $e');
      Get.snackbar(
        'Error',
        'Failed to delete notification: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
    }
  }
}
