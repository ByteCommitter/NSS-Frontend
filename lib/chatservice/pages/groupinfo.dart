import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart';
import 'package:mentalsustainability/chatservice/apiservices.dart';
import 'package:mentalsustainability/theme/app_colors.dart';

class groupinfo extends StatefulWidget {
  String sessionId;
  String roomName;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Group Info",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
        ),
        body: isLoading
            ? const Center(child: CircleAvatar())
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Name: ${widget.roomName}",
                                    style: const TextStyle(fontSize: 25),
                                  ),
                                  const Text(
                                    "Members",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 20),
                                  )
                                ],
                              ),
                            ),
                          )),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        width: MediaQuery.of(context).size.width * 0.99,
                        child: ListView.builder(
                            itemCount: participants.length,
                            itemBuilder: (context, index) {
                              bool evenIndex = index % 2 == 0;
                              Map<String, dynamic> currentTile =
                                  participants[index];
                              return Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.1,
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
