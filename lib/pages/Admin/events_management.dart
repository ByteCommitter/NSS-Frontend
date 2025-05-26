import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/theme/app_colors.dart';
import 'package:mentalsustainability/services/api_service.dart';
import 'package:intl/intl.dart';

class EventsManagement extends StatefulWidget {
  const EventsManagement({Key? key}) : super(key: key);

  @override
  State<EventsManagement> createState() => _EventsManagementState();
}

class _EventsManagementState extends State<EventsManagement> {
  final ApiService _apiService = Get.find<ApiService>();
  List<Map<String, dynamic>> events = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Use the real API to fetch events
      final apiEvents = await _apiService.getEvents();
      
      // Convert ApiEvent objects to maps for easier handling in the UI
      final List<Map<String, dynamic>> formattedEvents = apiEvents.map((event) => {
        'id': event.id,
        'title': event.title,
        'description': event.description,
        'date': event.date,
        'fromTime': event.fromTime,
        'toTime': event.toTime,
        'location': event.location,
        'imageUrl': event.imageUrl,
        'capacity': 100, // Default capacity (not provided by API)
        'enrolled': 0, // Default enrolled (not provided by API)
        'status': 'active', // Default status (not provided by API)
      }).toList();
      
      setState(() {
        events = formattedEvents;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading events: $e');
      setState(() {
        _isLoading = false;
      });
      Get.snackbar(
        'Error',
        'Failed to load events. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  // Format time string (HH:MM:SS) to a more readable format (HH:MM AM/PM)
  String formatTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return 'TBD';
    
    try {
      final timeParts = timeStr.split(':');
      if (timeParts.length < 2) return timeStr;
      
      int hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final period = hour >= 12 ? 'PM' : 'AM';
      
      if (hour > 12) hour -= 12;
      if (hour == 0) hour = 12;
      
      return '$hour:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return timeStr;
    }
  }

  // Format date string (YYYY-MM-DD) to a more readable format (Month DD, YYYY)
  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return 'TBD';
    
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('MMMM dd, yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Header with action buttons
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    border: Border(
                      bottom: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Events Management',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _showCreateEventDialog,
                        icon: const Icon(Icons.add),
                        label: const Text('Create Event'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      PopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        tooltip: 'More options',
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'hard_delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete_forever, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Hard Delete Event', style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          if (value == 'hard_delete' && events.isNotEmpty) {
                            Get.dialog(
                              AlertDialog(
                                title: const Text('Select Event to Delete Permanently'),
                                content: Container(
                                  width: double.maxFinite,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: events.length,
                                    itemBuilder: (context, index) {
                                      final event = events[index];
                                      return ListTile(
                                        title: Text(event['title'] ?? 'Untitled Event'),
                                        subtitle: Text(formatDate(event['date'])),
                                        trailing: const Icon(Icons.delete_forever, color: Colors.red),
                                        onTap: () {
                                          Get.back(); // Close the selection dialog
                                          _showHardDeleteDialog(event);
                                        },
                                      );
                                    },
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Get.back(),
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                
                // Events list
                Expanded(
                  child: events.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.event_note, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'No events found',
                                style: TextStyle(fontSize: 18, color: Colors.grey),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Create your first event to get started',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadEvents,
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              final event = events[index];
                              return _buildEventCard(event);
                            },
                          ),
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildEventCard(Map<String, dynamic> event) {
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
                Expanded(
                  child: Text(
                    event['title'] ?? 'Untitled Event',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              event['description'] ?? 'No description',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(formatDate(event['date'])),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${formatTime(event['fromTime'])} - ${formatTime(event['toTime'])}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(event['location'] ?? 'TBD'),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Add Verify Registered Users button
                TextButton.icon(
                  onPressed: () => _showVerifyUsersDialog(event),
                  icon: const Icon(Icons.people, color: Colors.blue),
                  label: const Text('Verify Users', style: TextStyle(color: Colors.blue)),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showEditEventDialog(event),
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                TextButton.icon(
                  onPressed: () => _showDeleteEventDialog(event),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Updated to use real API data instead of mock data
  void _showVerifyUsersDialog(Map<String, dynamic> event) {
    // Default to empty list - will be populated from API
    final List<Map<String, dynamic>> registeredUsers = [];
    bool isLoading = true;
    
    // Use StatefulBuilder to update the dialog content
    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          // Function to load registered users
          void loadRegisteredUsers() async {
            setState(() => isLoading = true);
            
            try {
              // Use the real API to get registered users
              final users = await _apiService.getEventRegisteredUsers(event['id'].toString());
              
              setState(() {
                registeredUsers.clear();
                registeredUsers.addAll(users);
                isLoading = false;
              });
              
              print('Loaded ${users.length} registered users for event ${event['id']}');
            } catch (e) {
              print('Error loading registered users: $e');
              setState(() => isLoading = false);
              Get.snackbar(
                'Error',
                'Failed to load registered users',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.withOpacity(0.1),
                colorText: Colors.red,
              );
            }
          }
          
          // Load users when dialog opens
          if (isLoading && registeredUsers.isEmpty) {
            loadRegisteredUsers();
          }
          
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              width: double.maxFinite,
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.8,
                maxWidth: 600,
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Registered Users for "${event['title']}"',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        tooltip: 'Refresh',
                        onPressed: loadRegisteredUsers,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        tooltip: 'Close',
                        onPressed: () => Get.back(),
                      ),
                    ],
                  ),
                  const Divider(),
                  if (isLoading)
                    const Expanded(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (registeredUsers.isEmpty)
                    const Expanded(
                      child: Center(
                        child: Text('No users registered for this event yet'),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        itemCount: registeredUsers.length,
                        itemBuilder: (context, index) {
                          final user = registeredUsers[index];
                          // Check if the user has participated
                          final bool isVerified = user['isParticipated'] == 1;
                          
                          return ListTile(
                            title: Text(user['user_id'] ?? 'Unknown User ID'),
                            subtitle: Text('Registration Status: ${isVerified ? 'Verified' : 'Not Verified'}'),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Verification status indicator
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isVerified ? Colors.green : Colors.grey,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    isVerified ? 'VERIFIED' : 'PENDING',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Toggle verification status
                                IconButton(
                                  icon: Icon(
                                    isVerified ? Icons.check_circle : Icons.check_circle_outline,
                                    color: isVerified ? Colors.green : Colors.grey,
                                  ),
                                  onPressed: () async {
                                    try {
                                      // Show loading indicator for the specific user
                                      setState(() => user['isUpdating'] = true);
                                      
                                      // Call API to update verification status
                                      final success = await _apiService.verifyUserAttendance(
                                        event['id'].toString(), 
                                        user['user_id'], 
                                        !isVerified
                                      );
                                      
                                      if (success) {
                                        // Update the UI
                                        setState(() {
                                          user['isParticipated'] = isVerified ? 0 : 1;
                                          user['isUpdating'] = false;
                                        });
                                        
                                        Get.snackbar(
                                          'Success',
                                          'User verification status updated',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.green.withOpacity(0.1),
                                          colorText: Colors.green,
                                        );
                                      } else {
                                        setState(() => user['isUpdating'] = false);
                                        Get.snackbar(
                                          'Error',
                                          'Failed to update verification status',
                                          snackPosition: SnackPosition.BOTTOM,
                                          backgroundColor: Colors.red.withOpacity(0.1),
                                          colorText: Colors.red,
                                        );
                                      }
                                    } catch (e) {
                                      setState(() => user['isUpdating'] = false);
                                      Get.snackbar(
                                        'Error',
                                        'An error occurred: $e',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: Colors.red.withOpacity(0.1),
                                        colorText: Colors.red,
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showCreateEventDialog() {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final dateController = TextEditingController();
    final fromTimeController = TextEditingController();
    final toTimeController = TextEditingController();
    final locationController = TextEditingController();
    final bannerImageController = TextEditingController(); // Add controller for banner image
    
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedFromTime = TimeOfDay.now();
    TimeOfDay selectedToTime = TimeOfDay.now().replacing(
      hour: (TimeOfDay.now().hour + 2) % 24
    );
    
    // Format initial date and time values
    dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
    fromTimeController.text = '${selectedFromTime.hour.toString().padLeft(2, '0')}:${selectedFromTime.minute.toString().padLeft(2, '0')}:00';
    toTimeController.text = '${selectedToTime.hour.toString().padLeft(2, '0')}:${selectedToTime.minute.toString().padLeft(2, '0')}:00';
    
    // Function to pick date
    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );
      if (picked != null && picked != selectedDate) {
        selectedDate = picked;
        dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      }
    }
    
    // Function to pick time
    Future<void> _selectTime(BuildContext context, TextEditingController controller, TimeOfDay initialTime) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );
      if (picked != null) {
        controller.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
      }
    }
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Event',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
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
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                // Date picker
                TextField(
                  controller: dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 16),
                // Time pickers
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: fromTimeController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Start Time',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.access_time),
                            onPressed: () => _selectTime(context, fromTimeController, selectedFromTime),
                          ),
                        ),
                        onTap: () => _selectTime(context, fromTimeController, selectedFromTime),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: toTimeController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'End Time',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.access_time),
                            onPressed: () => _selectTime(context, toTimeController, selectedToTime),
                          ),
                        ),
                        onTap: () => _selectTime(context, toTimeController, selectedToTime),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: bannerImageController,
                  decoration: const InputDecoration(
                    labelText: 'Banner Image URL (optional)',
                    hintText: 'Enter URL for event banner image',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.isEmpty || 
                            descriptionController.text.isEmpty || 
                            dateController.text.isEmpty || 
                            fromTimeController.text.isEmpty || 
                            toTimeController.text.isEmpty || 
                            locationController.text.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Please fill in all required fields',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.withOpacity(0.1),
                            colorText: Colors.red,
                          );
                          return;
                        }
                        
                        Get.back(); // Close the dialog
                        
                        // Show loading indicator
                        Get.dialog(
                          const Center(child: CircularProgressIndicator()),
                          barrierDismissible: false,
                        );
                        
                        try {
                          // Create ApiEvent object with banner image
                          final newEvent = ApiEvent(
                            id: '0',
                            title: titleController.text,
                            description: descriptionController.text,
                            date: dateController.text,
                            fromTime: fromTimeController.text,
                            toTime: toTimeController.text,
                            location: locationController.text,
                            imageUrl: bannerImageController.text.isNotEmpty 
                                ? bannerImageController.text 
                                : null,
                          );
                          
                          // Call API
                          final success = await _apiService.createEvent(newEvent);
                          
                          Get.back(); // Close loading dialog
                          
                          if (success) {
                            Get.snackbar(
                              'Success',
                              'Event created successfully',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green.withOpacity(0.1),
                              colorText: Colors.green,
                            );
                            _loadEvents(); // Refresh the list
                          } else {
                            Get.snackbar(
                              'Error',
                              'Failed to create event',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red.withOpacity(0.1),
                              colorText: Colors.red,
                            );
                          }
                        } catch (e) {
                          Get.back(); // Close loading dialog
                          Get.snackbar(
                            'Error',
                            'An error occurred: $e',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.withOpacity(0.1),
                            colorText: Colors.red,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Create'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
    ));
  }

  void _showEditEventDialog(Map<String, dynamic> event) {
    final titleController = TextEditingController(text: event['title']);
    final descriptionController = TextEditingController(text: event['description']);
    final dateController = TextEditingController(text: event['date']);
    final fromTimeController = TextEditingController(text: event['fromTime']);
    final toTimeController = TextEditingController(text: event['toTime']);
    final locationController = TextEditingController(text: event['location']);
    final bannerImageController = TextEditingController(text: event['imageUrl'] ?? ''); // Add controller for banner image
    
    DateTime selectedDate = DateTime.tryParse(event['date'] ?? '') ?? DateTime.now();
    TimeOfDay selectedFromTime = TimeOfDay(
      hour: int.tryParse(event['fromTime']?.split(':')[0] ?? '0') ?? 0,
      minute: int.tryParse(event['fromTime']?.split(':')[1] ?? '0') ?? 0,
    );
    TimeOfDay selectedToTime = TimeOfDay(
      hour: int.tryParse(event['toTime']?.split(':')[0] ?? '0') ?? 0,
      minute: int.tryParse(event['toTime']?.split(':')[1] ?? '0') ?? 0,
    );
    
    // Function to pick date
    Future<void> _selectDate(BuildContext context) async {
      final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );
      if (picked != null && picked != selectedDate) {
        selectedDate = picked;
        dateController.text = DateFormat('yyyy-MM-dd').format(selectedDate);
      }
    }
    
    // Function to pick time
    Future<void> _selectTime(BuildContext context, TextEditingController controller, TimeOfDay initialTime) async {
      final TimeOfDay? picked = await showTimePicker(
        context: context,
        initialTime: initialTime,
      );
      if (picked != null) {
        controller.text = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
      }
    }
    
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Edit Event',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
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
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                // Date picker
                TextField(
                  controller: dateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Date',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () => _selectDate(context),
                    ),
                  ),
                  onTap: () => _selectDate(context),
                ),
                const SizedBox(height: 16),
                // Time pickers
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: fromTimeController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'Start Time',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.access_time),
                            onPressed: () => _selectTime(context, fromTimeController, selectedFromTime),
                          ),
                        ),
                        onTap: () => _selectTime(context, fromTimeController, selectedFromTime),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: toTimeController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: 'End Time',
                          border: const OutlineInputBorder(),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.access_time),
                            onPressed: () => _selectTime(context, toTimeController, selectedToTime),
                          ),
                        ),
                        onTap: () => _selectTime(context, toTimeController, selectedToTime),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(
                    labelText: 'Location',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: bannerImageController,
                  decoration: const InputDecoration(
                    labelText: 'Banner Image URL (optional)',
                    hintText: 'Enter URL for event banner image',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.isEmpty || 
                            descriptionController.text.isEmpty || 
                            dateController.text.isEmpty || 
                            fromTimeController.text.isEmpty || 
                            toTimeController.text.isEmpty || 
                            locationController.text.isEmpty) {
                          Get.snackbar(
                            'Error',
                            'Please fill in all fields',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.withOpacity(0.1),
                            colorText: Colors.red,
                          );
                          return;
                        }
                        
                        Get.back(); // Close the dialog
                        
                        // Show loading indicator
                        Get.dialog(
                          const Center(child: CircularProgressIndicator()),
                          barrierDismissible: false,
                        );
                        
                        try {
                          // Update including banner_image
                          await _apiService.updateEvent(
                            event['id'].toString(),
                            titleController.text,
                            descriptionController.text,
                            dateController.text,
                            fromTimeController.text,
                            toTimeController.text,
                            locationController.text,
                            bannerImageController.text, // Pass banner image URL
                          );
                          
                          Get.back(); // Close loading dialog
                          
                          Get.snackbar(
                            'Success',
                            'Event updated successfully',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green.withOpacity(0.1),
                            colorText: Colors.green,
                          );
                          _loadEvents(); // Refresh the list
                        } catch (e) {
                          Get.back(); // Close loading dialog
                          Get.snackbar(
                            'Error',
                            'An error occurred: $e',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.withOpacity(0.1),
                            colorText: Colors.red,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Update'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
     ) );
  }

  void _showDeleteEventDialog(Map<String, dynamic> event) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Event'),
        content: Text('Are you sure you want to delete "${event['title']}"?\n\nThis action will hide the event but preserve records.'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back(); // Close dialog
              
              // Show loading indicator
              Get.dialog(
                const Center(child: CircularProgressIndicator()),
                barrierDismissible: false,
              );
              
              try {
                // Use soft delete instead of delete
                final success = await _apiService.softDeleteEvent(event['id'].toString());
                
                Get.back(); // Close loading dialog
                
                if (success) {
                  Get.snackbar(
                    'Success',
                    'Event deleted successfully',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green.withOpacity(0.1),
                    colorText: Colors.green,
                  );
                  _loadEvents(); // Refresh the list
                } else {
                  Get.snackbar(
                    'Error',
                    'Failed to delete event',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red.withOpacity(0.1),
                    colorText: Colors.red,
                  );
                }
              } catch (e) {
                Get.back(); // Close loading dialog
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
  
  // Add this method for hard delete with clear warnings
  void _showHardDeleteDialog(Map<String, dynamic> event) {
    Get.dialog(
      AlertDialog(
        title: const Text('Permanently Delete Event', style: TextStyle(color: Colors.red)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            const Text(
              'WARNING: IRREVERSIBLE ACTION',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text('You are about to permanently delete "${event['title']}".'),
            const SizedBox(height: 8),
            const Text(
              'This will permanently remove all data related to this event from the database, including attendance records and participation data.',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 16),
            const Text(
              'Recommendation: Only use hard delete at the end of the academic year for cleanup purposes.',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              // First confirmation
              Get.back();
              Get.dialog(
                AlertDialog(
                  title: const Text('Confirm Permanent Deletion'),
                  content: const Text('Please type "CONFIRM" to proceed with permanent deletion:'),
                  actions: [
                    TextButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Get.back();
                        
                        // Show loading indicator
                        Get.dialog(
                          const Center(child: CircularProgressIndicator()),
                          barrierDismissible: false,
                        );
                        
                        try {
                          final success = await _apiService.hardDeleteEvent(event['id'].toString());
                          
                          Get.back(); // Close loading dialog
                          
                          if (success) {
                            Get.snackbar(
                              'Success',
                              'Event permanently deleted',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.green.withOpacity(0.1),
                              colorText: Colors.green,
                            );
                            _loadEvents(); // Refresh the list
                          } else {
                            Get.snackbar(
                              'Error',
                              'Failed to permanently delete event',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red.withOpacity(0.1),
                              colorText: Colors.red,
                            );
                          }
                        } catch (e) {
                          Get.back(); // Close loading dialog
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
                      child: const Text('PERMANENTLY DELETE'),
                    ),
                  ],
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('I Understand, Proceed'),
          ),
        ],
      ),
    );
  }
}
