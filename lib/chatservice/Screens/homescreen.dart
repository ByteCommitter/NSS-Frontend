import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/chatservice/pages/dms.dart';
import 'package:mentalsustainability/chatservice/pages/gen_chatpage.dart';
import 'package:mentalsustainability/chatservice/pages/newgroup.dart';
import 'package:mentalsustainability/chatservice/pages/organisers.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void onInit() {
    tabController = TabController(length: 3, vsync: this);
    super.onInit();
  }

  void changeTab(int index) {
    tabController.animateTo(index);
  }

  @override
  void onClose() {
    tabController.dispose();
    super.onClose();
  }
}

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _Homescreen();
}

class _Homescreen extends State<Homescreen>
    with SingleTickerProviderStateMixin {
  final _tabcontroller = Get.put(HomeController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats@NSS',
            style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () {
              Get.to(() => const newgroup());
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () {
              showMenu(
                context: context,
                position: const RelativeRect.fromLTRB(100, 100, 0, 0),
                items: [
                  const PopupMenuItem(
                      child: Text('Settings'), value: 'settings'),
                  const PopupMenuItem(child: Text('Profile'), value: 'profile'),
                  const PopupMenuItem(child: Text('Logout'), value: 'logout'),
                ],
              );
            },
            icon: const Icon(Icons.menu),
          ),
        ],
        bottom: TabBar(
          controller: _tabcontroller.tabController,
          tabs: const [
            Tab(text: 'General'),
            Tab(text: 'DMs'),
            Tab(text: 'Organisers'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TabBarView(
          controller: _tabcontroller.tabController,
          children: const [gen_chatpage(), dms(), organisers()],
        ),
      ),
    );
  }
}
