import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mentalsustainability/chatservice/apiservices.dart';
import 'package:mentalsustainability/chatservice/pages/dms.dart';
import 'package:mentalsustainability/chatservice/pages/gen_chatpage.dart';
import 'package:mentalsustainability/chatservice/pages/newgroup.dart';
import 'package:mentalsustainability/chatservice/pages/organisers.dart';
import 'package:mentalsustainability/services/api_service.dart';
import 'package:mentalsustainability/services/auth_service.dart';
import 'package:mentalsustainability/theme/app_colors.dart';

class HomeController extends GetxController
    with GetSingleTickerProviderStateMixin {
  late TabController tabController;

  @override
  void onInit() {
    tabController = TabController(length: 1, vsync: this);
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
  Homescreen({super.key});
  //final ChatApiService _chatApiService = Get.find<ChatApiService>();
  //final ApiService _apiService = Get.find<ApiService>();
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
          Obx(() {
            final authService = Get.find<AuthService>();
            if (!authService.isAdminUser.value) return const SizedBox.shrink();

            return GestureDetector(
              onTap: () {
                Get.to(() => const newgroup());
              },
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(80),
                    color: AppColors.primary),
                child: Row(
                  children: [
                    Text('New Group',
                        style: TextStyle(color: AppColors.background)),
                    Icon(
                      Icons.add,
                      color: AppColors.background,
                    ),
                  ],
                ),
              ),
            );
          })
        ],
        bottom: TabBar(
          controller: _tabcontroller.tabController,
          tabs: const [
            Tab(text: 'General'),
            //Tab(text: 'DMs'),    ------> include in a future release
            //Tab(text: 'Organisers'),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: TabBarView(
          controller: _tabcontroller.tabController,
          children: const [gen_chatpage()],
        ),
      ),
    );
  }
}
