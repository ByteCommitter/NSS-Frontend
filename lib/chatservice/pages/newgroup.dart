import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/instance_manager.dart';
import 'package:mentalsustainability/chatservice/pages/newgroupgeneral.dart';
import 'package:mentalsustainability/services/api_service.dart';
import 'package:mentalsustainability/theme/app_colors.dart';

class newgroup extends StatefulWidget {
  const newgroup({super.key});

  @override
  State<newgroup> createState() => _newgroupState();
}

class _newgroupState extends State<newgroup> {
  List<ApiEvent> allEvents = <ApiEvent>[];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEvents(); // Fixed: Added parentheses to actually call the function
  }

  Future<void> _loadEvents() async {
    try {
      final events = await ApiService().getEvents();
      setState(() {
        allEvents = events;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error appropriately
      print('Error loading events: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Events',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => Get.to(() => const newgroupgeneral()),
            child: Card(
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              margin: const EdgeInsets.all(8),
              elevation: 10,
              shadowColor: AppColors.primary,
              child: const SizedBox(
                width: double.infinity,
                child: Padding(
                  padding:
                      EdgeInsets.only(left: 8, right: 8, top: 16, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "General",
                        style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Select any user from any event",
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : allEvents.isEmpty
                  ? const Center(child: Text('No events available'))
                  : Expanded(
                      child: ListView.builder(
                        itemCount: allEvents.length, // Fixed: Specify itemCount
                        itemBuilder: (context, index) {
                          // Fixed: Don't reassign index, use it as the list index
                          return InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () {
                              // Add your onTap functionality here
                            },
                            child: Card(
                              shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.all(
                                      const Radius.circular(10))),
                              margin: const EdgeInsets.all(8),
                              elevation: 10,
                              shadowColor: AppColors.primary,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 8, right: 8, top: 16, bottom: 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      allEvents[index].title,
                                      style: const TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      "Event ID: ${allEvents[index].id}",
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_pin,
                                          color: Colors.grey,
                                        ),
                                        Text(
                                          "${allEvents[index].location}",
                                          style: const TextStyle(
                                              fontSize: 14, color: Colors.grey),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
          const Divider(),
          const SizedBox(height: 50),
        ],
      ),
    );
  }
}
