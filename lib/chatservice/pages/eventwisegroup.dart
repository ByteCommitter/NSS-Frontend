import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/utils.dart';
import 'package:mentalsustainability/services/api_service.dart';

class Eventwisegroup extends StatefulWidget {
  String id;
  Eventwisegroup({super.key, required this.id});

  @override
  State<Eventwisegroup> createState() => _EventwisegroupState();
}

class _EventwisegroupState extends State<Eventwisegroup> {
  final ApiService _apiService = Get.find<ApiService>();

  List<Map<String, dynamic>> registeredUsers = [];
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
      body: ListView.builder(
        itemCount: registeredUsers.length,
        itemBuilder: (context, index) {
          final user = registeredUsers[index];
          final bool isVerified =
              user['isParticipated'] == true || user['isParticipated'] == 1;
          return isVerified
              ? ListTile(
                  title: Text(user['user_id'] ?? 'Unknown User'),
                  subtitle: Text(user['username'] ?? 'Unknown Username'),
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }
}
