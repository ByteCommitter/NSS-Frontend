import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/services/auth_service.dart';
import 'package:mentalsustainability/theme/app_colors.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = Get.find<AuthService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('NSS Admin Panel'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, semanticLabel: 'Logout'),
            onPressed: () => authService.logout(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Use a simple Material icon with explicit size and color
            Icon(
              Icons.admin_panel_settings,
              size: 80,
              color: AppColors.primary.withOpacity(0.8),
            ),
            const SizedBox(height: 24),
            const Text(
              'Welcome to Admin Panel',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Admin features will be implemented soon',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
              child: const Text('Back to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
