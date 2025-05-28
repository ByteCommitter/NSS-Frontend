import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/theme/app_colors.dart'; // Add theme import
import '../services/auth_service.dart';
import '../services/onboarding_screen.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class LoginScreen extends StatelessWidget {
  final AuthService _authService = AuthService();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // NSS Logo
              Image.asset(
                'assets/images/NSS.png',
                width: 120,
                height: 120,
              ),
              const SizedBox(height: 40),
              
              // Welcome text
              const Text(
                "Not Me but you",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              Text(
                "Sign in to access your dashboard and resources",
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              
              // Google Sign In Button (Dummy button)
              ElevatedButton(
                onPressed: () => Get.off(() => const OnboardingScreen()),
                style: ElevatedButton.styleFrom(
                  foregroundColor: AppColors.textPrimary, // Use theme color
                  backgroundColor: AppColors.white, // Use theme color
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: AppColors.divider), // Use theme color
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Google logo icon
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: FaIcon(
                        FontAwesomeIcons.google,
                        color: Colors.red,
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 16),
                    Text(
                      'Continue with Google',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Terms and privacy text
              Text(
                "By continuing, you agree to our Terms of Service and Privacy Policy",
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary, // Use theme color
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
