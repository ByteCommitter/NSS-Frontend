import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/chatservice/Screens/chatscreen.dart';
import 'package:mentalsustainability/theme/app_colors.dart';
import 'package:mentalsustainability/chatservice/apiservices.dart';

class gen_chatpage extends StatefulWidget {
  const gen_chatpage({super.key});

  @override
  State<gen_chatpage> createState() => _ChatpageState();
}

class _ChatpageState extends State<gen_chatpage> {
  final ChatApiService chatApiService = Get.find<ChatApiService>();
  List<ChatModel> roomData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRooms();
  }

  Future<void> loadRooms() async {
    try {
      final Map<String, dynamic> rawData = await chatApiService.getAllRooms();

      final List<dynamic> roomNames = rawData['roomNames'] ?? [];
      final List<dynamic> sessionIds = rawData['sessionIds'] ?? [];
      setState(() {
        roomData = [];
        for (int index = 0; index < roomNames.length; index++) {
          final roomName = roomNames[index];
          final sessionId = sessionIds.length > index ? sessionIds[index] : '';

          if (roomName != null && roomName.toString().trim().isNotEmpty) {
            roomData.add(ChatModel(
                name: roomName.toString(),
                sessionid: sessionId?.toString() ?? ''));
          }
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error if needed
      print('Error loading rooms: $e');
    }
  }

  Future<void> _pulldown() async {
    setState(() {
      isLoading = true;
    });
    await loadRooms();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : roomData.isEmpty
              ? Center(
                  child: Column(
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.24,
                    ),
                    const Icon(
                      Icons.chat_outlined,
                      size: 50,
                    ),
                    const Text(
                      "An Unexpected Error Occured.",
                      style: TextStyle(fontSize: 20),
                    )
                  ],
                ))
              : ListView.builder(
                  itemCount: roomData.length,
                  itemBuilder: (context, index) {
                    ChatModel currentchat = roomData[index];
                    return Column(
                      children: [
                        const Divider(thickness: 0.09),
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primaryDark,
                            radius: 25,
                            child: Text(
                              currentchat.name.isNotEmpty
                                  ? currentchat.name[0].toUpperCase()
                                  : '?',
                              style: TextStyle(
                                  color: AppColors.background,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          /*trailing: Text(
                  currentchat.time,
                  style: const TextStyle(fontSize: 12),
                ),*/
                          title: Text(
                            currentchat.name,
                            style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600),
                          ),
                          /*subtitle: Text(
                  currentchat.lastText,
                  overflow: TextOverflow.ellipsis,
                ),*/
                          onTap: () {
                            Get.to(() => ChatScreen(thischat: currentchat));
                          },
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}

class ChatModel {
  String name;
  //String time;
  String sessionid;
  ChatModel({required this.name, required this.sessionid});
}
