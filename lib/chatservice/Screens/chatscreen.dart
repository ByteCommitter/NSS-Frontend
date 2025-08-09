import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/chatservice/apiservices.dart';
import 'package:mentalsustainability/chatservice/pages/gen_chatpage.dart';
import 'package:mentalsustainability/chatservice/pages/groupinfo.dart';
import 'package:mentalsustainability/theme/app_colors.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.thischat, this.chatApiService});
  final ChatModel thischat;
  final ChatApiService? chatApiService;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
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
          IconButton(
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
          ),
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
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Stack(
          children: [
            ListView(),
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
                        onPressed: () {}, icon: const Icon(Icons.send)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
