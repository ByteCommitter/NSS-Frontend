import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/chatservice/apiservices.dart';
import 'package:mentalsustainability/chatservice/pages/gen_chatpage.dart';
import 'package:mentalsustainability/chatservice/pages/groupinfo.dart';
import 'package:mentalsustainability/theme/app_colors.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.thischat, this.chatApiService});
  final ChatModel thischat;
  final ChatApiService? chatApiService;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late TextEditingController _textEditingController;
  final ChatApiService chatApiService = Get.find<ChatApiService>();
  late final String sessionID;
  List<dynamic> allTexts = [];

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    sessionID = widget.thischat.sessionid;
    getTexts(sessionID).then((value) {
      setState(() {
        allTexts = value;
      });
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  Future<List<dynamic>> getTexts(String s) async {
    final Map<String, dynamic> rawData =
        await chatApiService.getRoomMessages(s);
    final List<dynamic> allTexts = rawData['messages']
        .where((msg) => msg['text'] is String && msg['text'].isNotEmpty)
        .toList();
    return allTexts;
  }

  String formatDateTime(String timestamp) {
    DateTime messageTime = DateTime.parse(timestamp).toLocal();
    DateTime now = DateTime.now();

    // Check if it's today
    if (messageTime.year == now.year &&
        messageTime.month == now.month &&
        messageTime.day == now.day) {
      return DateFormat('HH:mm').format(messageTime); // Only time for today
    } else {
      return DateFormat('MMM dd, HH:mm')
          .format(messageTime); // Date + time for other days
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => const groupinfo());
            },
            icon: const Icon(Icons.info_outline),
          ),

          // This should be implemented to add/ remove members to an existing group.
          /*IconButton(
            onPressed: () {
              showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(100, 100, 0, 0),
                items: const [
                  PopupMenuItem(child: Text('Add Members'), value: 'settings'),
                  PopupMenuItem(
                    child: Text('Remove members'),
                    value: 'profile',
                  ),
                ],
              );
            },
            icon: const Icon(Icons.menu),
          ),*/
        ],
        title: Text(
          widget.thischat.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        toolbarHeight: 70,

        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () {
                Get.back();
              },
              icon: const Icon(Icons.arrow_back),
            ),
            //const CircleAvatar(radius: 15),
          ],
        ),
        //leadingWidth: 100, // Give more space for the Row
      ),
      body: Stack(
        children: [
          ListView.builder(
              padding: const EdgeInsets.only(bottom: 80),
              itemCount: allTexts.length,
              itemBuilder: (context, index) {
                final currentText = allTexts[index];
                print(currentText);
                return Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8, top: 10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width - 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primaryDark,
                              foregroundColor: AppColors.primaryLight,
                              child: Text(
                                currentText['name'][0],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 17),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              currentText["name"],
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 17),
                            ),
                          ]),
                          Card(
                            elevation: 10,
                            color: AppColors.primary,
                            shadowColor: AppColors.primaryDark,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    currentText["text"],
                                    style: TextStyle(
                                        color: AppColors.primaryLight),
                                  ),
                                  Text(formatDateTime(currentText["time"]))
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - 65,
                  child: Card(
                    margin: const EdgeInsets.all(8),
                    color: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80),
                    ),
                    child: TextFormField(
                      controller: _textEditingController,
                      style: const TextStyle(color: Colors.black),
                      textAlignVertical: TextAlignVertical.center,
                      decoration: InputDecoration(
                        hintText: "Type a text",
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(80),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(80),
                          borderSide: const BorderSide(color: Colors.white),
                        ),
                        hintStyle: const TextStyle(color: Colors.white70),
                      ),
                    ),
                  ),
                ),
                CircleAvatar(
                  backgroundColor: AppColors.primaryDark,
                  foregroundColor: AppColors.primaryLight,
                  radius: 30,
                  child: IconButton(
                      onPressed: () async {
                        String message = _textEditingController.text.trim();
                        if (message.isNotEmpty) {
                          bool success =
                              await chatApiService.sendText(message, sessionID);
                          _textEditingController.clear();

                          if (success) {
                            getTexts(sessionID).then((value) {
                              setState(() {
                                allTexts = value;
                              });
                            });
                          } else {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text(
                                  "Oops! Failed to send message. Please try again."),
                              backgroundColor: Colors.red,
                            ));
                          }
                        }
                      },
                      icon: const Icon(Icons.send)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
