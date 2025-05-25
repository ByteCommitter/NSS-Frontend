import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/services/auth_service.dart';

class AdminMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    
    // Use the observable admin status for a more reliable check
    final isAdmin = authService.isAdminUser.value;
    
    if (!isAdmin) {
      // If user is not an admin, redirect to home page
      return const RouteSettings(name: '/home');
    }
    
    return null;
  }
}
