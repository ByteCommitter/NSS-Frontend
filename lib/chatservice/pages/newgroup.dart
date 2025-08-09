import 'package:flutter/material.dart';

class newgroup extends StatefulWidget {
  const newgroup({super.key});

  @override
  State<newgroup> createState() => _newgroupState();
}

class _newgroupState extends State<newgroup> {
  final List<ChatUsers> userlist = [
    ChatUsers(id: 'f2023', username: 'Satvik'),
    ChatUsers(id: 'f2022', username: 'guru'),
    ChatUsers(id: 'f2020', username: 'nss'),
    ChatUsers(id: 'f0000', username: 'random'),
  ];
  final List<String> selectedUsers = [];
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

  void createGroup() {
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

    // Handle group creation logic here
    final selectedUserNames = userlist
        .where((user) => selectedUsers.contains(user.id))
        .map((user) => user.username)
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Group Created'),
        content: Text(
          'Group "${groupname.text}" created with members: ${selectedUserNames.join(', ')}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Group'),
        backgroundColor: Colors.teal,
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
              color: Colors.teal.withOpacity(0.1),
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
                final isSelected = selectedUsers.contains(user.id);

                return InkWell(
                  onTap: () => toggleUserSelection(user.id),
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
                            user.username[0].toUpperCase(),
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
                                user.username,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              Text(
                                'ID: ${user.id}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
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

class ChatUsers {
  final String id;
  final String username;

  ChatUsers({required this.id, required this.username});
}
