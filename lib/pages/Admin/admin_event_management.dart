import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/models/admin_models.dart';  // Import our models
import 'package:mentalsustainability/services/api_service.dart';
import 'package:mentalsustainability/theme/app_colors.dart';

class AdminEventManagement extends StatefulWidget {
  const AdminEventManagement({super.key});

  @override
  State<AdminEventManagement> createState() => _AdminEventManagementState();
}

class _AdminEventManagementState extends State<AdminEventManagement> {
  final ApiService _apiService = Get.find<ApiService>();
  List<AdminEvent> _events = []; // Changed to AdminEvent
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadEvents();
  }
  
  // Fix the loadEvents method to convert Event to AdminEvent
Future<void> _loadEvents() async {
  setState(() {
    _isLoading = true;
  });
  
  try {
    final events = await _apiService.getEvents();
    setState(() {
      // Convert Event objects to AdminEvent objects
      _events = events.map((e) => AdminEvent.fromEvent(e)).toList();
      _isLoading = false;
    });
  } catch (e) {
    print('Error loading events: $e');
    setState(() {
      // Convert Event objects to AdminEvent objects
      _events = _apiService.getTestEvents()
          .map((e) => AdminEvent.fromEvent(e))
          .toList();
      _isLoading = false;
    });
    Get.snackbar(
      'Error',
      'Failed to load events. Using test data.',
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
              onRefresh: _loadEvents,
              child: _events.isEmpty
                  ? _buildEmptyState()
                  : _buildEventList(),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEventDialog(),
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
            Icons.event_busy,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No events available',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () => _showEventDialog(),
            icon: const Icon(Icons.add),
            label: const Text('Add New Event'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEventList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(
              event.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('Date: ${event.date}'),
                Text('Time: ${event.fromTime} - ${event.toTime}'),
                Text('Location: ${event.location}'),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showEventDialog(event: event),
                  color: AppColors.primary,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _showDeleteConfirmation(event),
                  color: AppColors.error,
                ),
              ],
            ),
            onTap: () => _showEventDialog(event: event),
          ),
        );
      },
    );
  }
  
  void _showEventDialog({AdminEvent? event}) { // Changed to AdminEvent
    final isEditing = event != null;
    final titleController = TextEditingController(text: event?.title ?? '');
    final descriptionController = TextEditingController(text: event?.description ?? '');
    final dateController = TextEditingController(text: event?.date ?? '');
    final fromTimeController = TextEditingController(text: event?.fromTime ?? '');
    final toTimeController = TextEditingController(text: event?.toTime ?? '');
    final locationController = TextEditingController(text: event?.location ?? '');
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          width: 500, // Max width
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEditing ? 'Edit Event' : 'Add New Event',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Event Title',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: dateController,
                              decoration: InputDecoration(
                                labelText: 'Date',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.now().add(const Duration(days: 365)),
                                    );
                                    if (date != null) {
                                      dateController.text = '${date.day}/${date.month}/${date.year}';
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: fromTimeController,
                              decoration: InputDecoration(
                                labelText: 'Start Time',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.access_time),
                                  onPressed: () async {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    if (time != null) {
                                      fromTimeController.text = '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: toTimeController,
                              decoration: InputDecoration(
                                labelText: 'End Time',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.access_time),
                                  onPressed: () async {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                    );
                                    if (time != null) {
                                      toTimeController.text = '${time.hour}:${time.minute.toString().padLeft(2, '0')}';
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Get.back(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // Validate form
                      if (titleController.text.isEmpty || 
                          dateController.text.isEmpty ||
                          locationController.text.isEmpty) {
                        Get.snackbar(
                          'Error',
                          'Please fill in all required fields',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: AppColors.error.withOpacity(0.1),
                          colorText: AppColors.error,
                        );
                        return;
                      }
                      
                      // Create or update event
                      if (isEditing) {
                        _updateEvent(
                          event.id,
                          titleController.text,
                          descriptionController.text,
                          dateController.text,
                          fromTimeController.text,
                          toTimeController.text,
                          locationController.text,
                        );
                      } else {
                        _createEvent(
                          titleController.text,
                          descriptionController.text,
                          dateController.text,
                          fromTimeController.text,
                          toTimeController.text,
                          locationController.text,
                        );
                      }
                      
                      Get.back();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(isEditing ? 'Update' : 'Create'),
                  ),
                ],
              ),
            ],
          ),
        ),
    ),
    );
  }
  
  Future<void> _createEvent(
    String title,
    String description,
    String date,
    String fromTime,
    String toTime,
    String location,
  ) async {
    try {
      // Change _apiService._createEvent to _apiService.createAdminEvent
      await _apiService.createAdminEvent(
        title,
        description,
        date,
        fromTime,
        toTime,
        location,
      );
      
      Get.snackbar(
        'Success',
        'Event created successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withOpacity(0.1),
        colorText: AppColors.success,
      );
      
      _loadEvents();
    } catch (e) {
      print('Error creating event: $e');
      Get.snackbar(
        'Error',
        'Failed to create event: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
    }
  }
  
  Future<void> _updateEvent(
    String id,
    String title,
    String description,
    String date,
    String fromTime,
    String toTime,
    String location,
  ) async {
    try {
      await _apiService.updateEvent(
        id,
        title,
        description,
        date,
        fromTime,
        toTime,
        location,
      );
      
      Get.snackbar(
        'Success',
        'Event updated successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withOpacity(0.1),
        colorText: AppColors.success,
      );
      
      _loadEvents();
    } catch (e) {
      print('Error updating event: $e');
      Get.snackbar(
        'Error',
        'Failed to update event: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
    }
  }
  
  void _showDeleteConfirmation(AdminEvent event) { // Changed to AdminEvent
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              _deleteEvent(event.id);
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
  
  Future<void> _deleteEvent(String id) async {
    try {
      await _apiService.deleteEvent(id);
      
      Get.snackbar(
        'Success',
        'Event deleted successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withOpacity(0.1),
        colorText: AppColors.success,
      );
      
      _loadEvents();
    } catch (e) {
      print('Error deleting event: $e');
      Get.snackbar(
        'Error',
        'Failed to delete event: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
    }
  }
}
