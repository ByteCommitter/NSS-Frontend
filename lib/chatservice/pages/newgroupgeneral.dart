import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:mentalsustainability/chatservice/apiservices.dart';
import 'package:mentalsustainability/chatservice/pages/gen_chatpage.dart';
import 'package:mentalsustainability/services/api_service.dart';
import 'package:mentalsustainability/theme/app_colors.dart';

class newgroupgeneral extends StatefulWidget {
  const newgroupgeneral({super.key});

  @override
  State<newgroupgeneral> createState() => _newgroupgeneralState();
}

class _newgroupgeneralState extends State<newgroupgeneral> {
  final ApiService _apiService = Get.find<ApiService>();
  List<Map<String, dynamic>> userlist = [];
  final List<String> selectedUsers = [];
  final ChatApiService _chatApiService = Get.find<ChatApiService>();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    userlist = await _apiService.getAllUsers();
    setState(() {});
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
      final participants = userlist
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
        title: const Text('New Group'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: selectedUsers.isNotEmpty ? createGroup : null,
            icon: const Icon(Icons.check),
          ),
        ],
      ),
      body: Column(
        children: [
          // Group name input
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
              color: Colors.teal.withValues(),
              child: Text(
                '${selectedUsers.length} user${selectedUsers.length == 1 ? '' : 's'} selected',
                style: TextStyle(
                  color: Colors.teal.shade700,
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

          // User list
          Expanded(
            child: ListView.builder(
              itemCount: userlist.length,
              itemBuilder: (context, index) {
                final user = userlist[index];
                final isSelected = selectedUsers.contains(user["username"]);

                return InkWell(
                  onTap: () => toggleUserSelection(user["username"]),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.teal.withOpacity(0.1) : null,
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.shade300,
                          width: 0.5,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.teal,
                          child: Text(
                            user["username"][0].toUpperCase(),
                            style: const TextStyle(
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
                                user["username"] ?? "Unknown",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'ID: ${user["university_id"]}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
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
                    ),
                  ),
                );
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
