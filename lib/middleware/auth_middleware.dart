import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/services/auth_service.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    
    // Check if authenticated by verifying token exists
    final isAuthenticated = authService.isAuthenticated.value;
    
    if (!isAuthenticated) {
      // If user is not logged in, redirect to login page
      return const RouteSettings(name: '/login');
    }
    
    return null;
  }
}
