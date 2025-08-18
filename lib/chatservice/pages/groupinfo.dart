import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart';
import 'package:mentalsustainability/chatservice/Screens/homescreen.dart';
import 'package:mentalsustainability/chatservice/apiservices.dart';
import 'package:mentalsustainability/chatservice/pages/gen_chatpage.dart';
import 'package:mentalsustainability/pages/Community/community_page.dart';
import 'package:mentalsustainability/pages/Home/home_page.dart';
import 'package:mentalsustainability/routes/app_routes.dart';
import 'package:mentalsustainability/theme/app_colors.dart';

class groupinfo extends StatefulWidget {
  final String sessionId;
  final String roomName;
  groupinfo({super.key, required this.sessionId, required this.roomName});

  @override
  State<groupinfo> createState() => _groupinfoState();
}

class _groupinfoState extends State<groupinfo> {
  final ChatApiService _chatApiService = Get.find<ChatApiService>();
  Map<String, dynamic> rawData = {};
  List<dynamic> participants = [];
  bool isLoading = true;

  @override
  void initState() {
    _getMembers();
    super.initState();
  }

  Future<void> _getMembers() async {
    try {
      rawData = await _chatApiService.groupinfo(widget.sessionId);
      print("ur raw data $rawData");
      participants = rawData['participants'] ?? [];
      setState(() {});
    } catch (e) {
      print("Error fetching Groups $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> deleteGroup() async {
    Get.dialog(
      const AlertDialog(
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(width: 20),
            Text("Deleting group..."),
          ],
        ),
      ),
      barrierDismissible: false,
    );
    try {
      bool result = await _chatApiService.deleteGroup(widget.roomName);
      Get.back();
      if (result) {
        Get.back();
        Get.snackbar(
          "Success",
          "Group ${widget.roomName} deleted successfully.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        Get.snackbar(
          "Delete Failed",
          "Could not delete group '${widget.roomName}'. Please try again.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      Get.snackbar(
        "Error",
        "Network error occurred. Please check your connection.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.wifi_off, color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Group Info",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : participants.isEmpty
                ? const Center(
                    child: Text("Error fetching Group Info"),
                  )
                : Column(
                    children: [
                      Card(
                          margin: const EdgeInsets.all(20),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Name: ${widget.roomName}",
                                            style:
                                                const TextStyle(fontSize: 25),
                                          ),
                                          Text(
                                            "Members: ${participants.length}",
                                            style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 20),
                                          )
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      "Delete Group"),
                                                  content: const Text(
                                                      "Are you sure you want to delete this group?"),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Get.back();
                                                      },
                                                      child:
                                                          const Text("Cancel"),
                                                    ),
                                                    TextButton(
                                                      onPressed: deleteGroup,
                                                      child:
                                                          const Text("Delete"),
                                                    ),
                                                  ],
                                                );
                                              });
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 30,
                                        ))
                                  ],
                                ),
                              ),
                            ),
                          )),
                      Expanded(
                        child: ListView.builder(
                            itemCount: participants.length,
                            itemBuilder: (context, index) {
                              bool evenIndex = index % 2 == 0;
                              Map<String, dynamic> currentTile =
                                  participants[index];
                              return Container(
                                  height: 100,
                                  width: double.infinity,
                                  margin: const EdgeInsets.all(16),
                                  child: Card(
                                      color: evenIndex
                                          ? AppColors.primary
                                          : AppColors.primaryDark,
                                      elevation: 20,
                                      //shape: const OutlineInputBorder())),
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Row(
                                          children: [
                                            CircleAvatar(
                                              radius: 30,
                                              child: Text(
                                                currentTile['name'][0]
                                                    .toUpperCase(),
                                                style: const TextStyle(
                                                    fontSize: 25,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 15,
                                            ),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(currentTile['name'],
                                                    style: const TextStyle(
                                                      fontSize: 25,
                                                    )),
                                                Text("ID: ${currentTile['id']}",
                                                    style: const TextStyle(
                                                      fontSize: 15,
                                                    )),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )));
                            }),
                      ),
                    ],
                  ));
  }
}
