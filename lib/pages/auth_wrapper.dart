import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/services/auth_service.dart';
import 'package:mentalsustainability/theme/app_colors.dart';

class AuthWrapper extends StatelessWidget {
  final AuthService authService = Get.put(AuthService());

  AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Building AuthWrapper. Auth state: ${authService.isAuthenticated.value}');

    return Obx(() {
      if (authService.isAuthenticated.value) {
        print('User is authenticated. Admin: ${authService.isAdminUser.value}');

        // Schedule navigation for next frame to avoid navigation during build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Add additional check to prevent multiple navigations
          if (Get.currentRoute == '/login' || Get.currentRoute == '/') {
            if (authService.isAdminUser.value) {
              print('Navigating to admin panel');
              Get.offAllNamed('/admin');
            } else {
              print('Navigating to home');
              Get.offAllNamed('/home');
            }
          }
        });

        return const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Loading your dashboard...'),
              ],
            ),
          ),
        );
      } else {
        print('User is not authenticated. Showing login screen.');
        return const LoginScreen();
      }
    });
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = Get.find<AuthService>();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await _authService.login(
          _usernameController.text,
          _passwordController.text,
        );

        print('Login response: $response');

        // Check if login was successful
        if (response != null && response['success'] == true) {
          print('Login successful, setting authenticated to true');

          // Ensure authentication state is set
          _authService.isAuthenticated.value = true;

          // Wait a bit longer and check if widget is still mounted
          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted) {
            // Force a complete navigation reset to home route
            print('Navigating to home after login');
            Get.offAllNamed('/');
          }
        } else {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }

          print('Login failed: ${response}');
          Get.snackbar(
            'Error',
            'Invalid username or password',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: AppColors.error.withOpacity(0.8),
            colorText: Colors.white,
          );
        }
      } catch (e) {
        print('Login error exception: $e');

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }

        Get.snackbar(
          'Error',
          'An error occurred during login: $e',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.error.withOpacity(0.8),
          colorText: Colors.white,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/Sereine Logo with Brain and Leaf.png',
                width: 100,
                height: 100,
              ),
              const SizedBox(height: 30),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Login'),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Get.toNamed('/register');
                    },
                    child: const Text('Sign Up'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
