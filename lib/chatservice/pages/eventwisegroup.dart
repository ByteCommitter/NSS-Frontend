import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:mentalsustainability/chatservice/apiservices.dart';
import 'package:mentalsustainability/services/api_service.dart';
import 'package:mentalsustainability/theme/app_colors.dart';

class Eventwisegroup extends StatefulWidget {
  String id;
  Eventwisegroup({super.key, required this.id});

  @override
  State<Eventwisegroup> createState() => _EventwisegroupState();
}

class _EventwisegroupState extends State<Eventwisegroup> {
  final ApiService _apiService = Get.find<ApiService>();

  List<Map<String, dynamic>> registeredUsers = [];
  final List<String> selectedUsers = [];
  final ChatApiService _chatApiService = Get.find<ChatApiService>();
  void loadRegisteredUsers(String id) async {
    try {
      final users = await _apiService.getEventRegisteredUsers(id);
      setState(() {
        registeredUsers.clear();
        registeredUsers.addAll(users);
      });
    } catch (e) {
      // Handle error appropriately
      Get.snackbar(
        'Error',
        'Failed to load registered users',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
      );
    }
  }

  void selectAll() {
    // TODO: Implement select all functionality
    // This method should handle selecting all registered users
  }
  @override
  void initState() {
    loadRegisteredUsers(widget.id);
    super.initState();
  }

  final TextEditingController groupname = TextEditingController();
  @override
  void dispose() {
    groupname.dispose();
    super.dispose();
  }

  void toggleUserSelection(String userId) {
    setState(() {
      if (selectedUsers.contains(userId)) {
        selectedUsers.remove(userId);
      } else {
        selectedUsers.add(userId);
      }
    });
  }

  void createGroup() async {
    if (groupname.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a group name')),
      );
      return;
    }
    if (selectedUsers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one user')),
      );
      return;
    }
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()));
    try {
      final participants = registeredUsers
          .where((user) => selectedUsers.contains(user['username']))
          .map(
              (user) => {"id": user["university_id"], "name": user["username"]})
          .toList();
      final requestBody = {
        "roomName": groupname.text.trim(),
        "participants": participants,
      };

      final response = await _chatApiService.createRoom(requestBody);

      Get.back();

      if (response != null) {
        showDialog(
            context: context,
            builder: (context) => AlertDialog(
                    title: const Text("Success"),
                    content: Text(
                        'Group "${groupname.text.trim()}" created successfully!'),
                    actions: [
                      TextButton(
                          onPressed: () {
                            Get.offAllNamed('/home');
                          },
                          child: const Text("OK"))
                    ]));
      } else {
        print(response);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Failed to create Room, please Try again.")));
      }
    } catch (e) {
      Get.back();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating group: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Registered & Verified Users',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.select_all),
            onPressed: () {
              selectAll();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: groupname,
              decoration: InputDecoration(
                labelText: 'Group Name',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(80)),
                prefixIcon: const Icon(Icons.group),
              ),
            ),
          ),

          // Selected users count
          if (selectedUsers.isNotEmpty)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              color: AppColors.primary,
              child: Text(
                '${selectedUsers.length} user${selectedUsers.length == 1 ? '' : 's'} selected',
                style: const TextStyle(
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Select Users:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: registeredUsers.length,
              itemBuilder: (context, index) {
                final user = registeredUsers[index];
                final bool isVerified = user['isParticipated'] == true ||
                    user['isParticipated'] == 1;
                final isSelected = selectedUsers.contains(user["user_id"]);
                return isVerified
                    ? InkWell(
                        onTap: () => toggleUserSelection(user["user_id"]),
                        child: Container(
                            padding: const EdgeInsets.all(10),
                            height: 70,
                            margin: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary.withOpacity(0.1)
                                  : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: Colors.green),
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.primary,
                                  child: const Text(
                                    'U',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                    child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user["name"] ?? "Unknown",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user["user_id"] ?? "No User ID",
                                      style: const TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                )),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle,
                                    color: Colors.teal,
                                  )
                                else
                                  Icon(
                                    Icons.radio_button_unchecked,
                                    color: Colors.grey.shade400,
                                  ),
                              ],
                            )),
                      )
                    : const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: selectedUsers.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: createGroup,
              backgroundColor: Colors.teal,
              icon: const Icon(Icons.group_add, color: Colors.white),
              label: const Text(
                'Create Group',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }
}
