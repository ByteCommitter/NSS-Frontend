import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/chatservice/Screens/chatscreen.dart';

class gen_chatpage extends StatefulWidget {
  const gen_chatpage({super.key});

  @override
  State<gen_chatpage> createState() => _ChatpageState();
}

class _ChatpageState extends State<gen_chatpage> {
  final List<ChatModel> alltexts = [
    ChatModel(
      name: 'GuruMurthy',
      lastText: 'yoyoyo just trying the elipsis thing',
      time: '10:11',
    ),
    ChatModel(
      name: 'Group 1',
      lastText: 'yoyoyo just trying the elipsis thing',
      time: '10:11',
    ),
    ChatModel(
      name: 'Group2',
      lastText: 'yoyoyo just trying the elipsis thing',
      time: '10:11',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: 3,
        itemBuilder: (context, index) {
          ChatModel currentchat = alltexts[index];
          return Column(
            children: [
              const Divider(thickness: 0.09),
              ListTile(
                leading: CircleAvatar(
                  radius: 25,
                  child: Text(currentchat.name[0]),
                ),
                trailing: Text(
                  currentchat.time,
                  style: const TextStyle(fontSize: 12),
                ),
                title: Text(currentchat.name),
                subtitle: Text(
                  currentchat.lastText,
                  overflow: TextOverflow.ellipsis,
                ),
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
  String time;
  String lastText;
  ChatModel({required this.name, required this.time, required this.lastText});
}
