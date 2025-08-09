import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/chatservice/Screens/homescreen.dart';
import 'package:mentalsustainability/chatservice/apiservices.dart';
import 'package:mentalsustainability/pages/guide_page.dart';
import 'package:mentalsustainability/pages/admin/admin_panel.dart';
import 'package:mentalsustainability/pages/auth/registration_screen.dart';
import 'package:mentalsustainability/pages/auth/forgot_password_screen.dart';
import 'package:mentalsustainability/services/badge_service.dart';
import 'package:mentalsustainability/theme/app_colors.dart';
import 'package:mentalsustainability/theme/theme_provider.dart';
// Add this import
import 'pages/auth_wrapper.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'package:mentalsustainability/services/socket_notification_service.dart';
import 'package:mentalsustainability/middleware/auth_middleware.dart';
import 'package:mentalsustainability/middleware/admin_middleware.dart';
import 'package:mentalsustainability/pages/base_widget.dart';

void main() async {
  // Ensure Flutter widgets are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Preserve the native splash screen until app is ready

  // Initialize services
  await initServices();

  // DEBUG: Print info about the initialized services
  print('Auth service initialized: ${Get.isRegistered<AuthService>()}');
  print('API service initialized: ${Get.isRegistered<ApiService>()}');
  print('Badge service initialized: ${Get.isRegistered<BadgeService>()}');

  // Remove the native splash screen once services are initialized

  runApp(const MyApp());
}

// Initialize all services
Future<void> initServices() async {
  print('Starting services initialization...');

  // Initialize providers in correct order
  final authService = Get.put(AuthService());
  Get.put(ThemeProvider());
  Get.put(ApiService());

  // Initialize BadgeService after auth service is available
  try {
    Get.put(BadgeService(), permanent: true);
    print('BadgeService initialized successfully in initServices');
  } catch (e) {
    print('Error initializing BadgeService in initServices: $e');
  }

  // Verify auth status on startup
  await authService.checkAndSetAuthStatus();
  print('Auth status: ${authService.isAuthenticated.value}');

  Get.put(ChatApiService(), permanent: true);
  // Initialize SocketNotificationService - but don't connect immediately
  print('Initializing SocketNotificationService...');
  await Get.putAsync(() => SocketNotificationService().init());
  print('SocketNotificationService initialized');

  print('All services initialized');
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ThemeProvider>(
      builder: (themeProvider) => GetMaterialApp(
        title: 'NSS',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.accent,
            surface: AppColors.background,
            error: AppColors.error,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.primary,
            elevation: 0,
          ),
          cardTheme: CardThemeData(
            color: AppColors.cardBackground,
          ),
          dividerTheme: DividerTheme.of(context).copyWith(
            color: AppColors.divider,
          ),
        ),
        // CHANGED: Start with custom splash screen route
        initialRoute: '/splash',
        getPages: [
          // Re-added the custom SplashScreen route
          GetPage(
            name: '/splash',
            page: () => const SplashScreen(),
            transition: Transition.fade,
          ),
          GetPage(
            name: '/',
            page: () => AuthWrapper(),
            transition: Transition.fade,
          ),
          GetPage(
            name: '/login',
            page: () =>
                AuthWrapper(), // AuthWrapper handles login/home redirection
            transition: Transition.fadeIn,
          ),
          GetPage(
            name: '/register',
            page: () => const RegistrationScreen(),
            transition: Transition.fadeIn,
          ),
          GetPage(
            name: '/forgot-password',
            page: () => const ForgotPasswordScreen(),
            transition: Transition.fadeIn,
          ),
          GetPage(
            name: '/home',
            page: () => const BaseScreen(),
            middlewares: [AuthMiddleware()],
            transition: Transition.fadeIn,
          ),
          GetPage(name: '/guide', page: () => const GuidePage()),
          GetPage(
            name: '/admin',
            page: () => const AdminPanel(),
            middlewares: [
              AuthMiddleware(),
              AdminMiddleware(),
            ],
          ),
          // Add the chat route
          GetPage(
            name: '/chat',
            page: () => const Homescreen(),
            middlewares: [
              AuthMiddleware()
            ], // Assuming chat requires authentication
            transition: Transition.rightToLeft,
          ),
        ],
      ),
    );
  }
}

// Improved Splash screen with the NSS logo (retained)
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.8, curve: Curves.easeOutBack),
      ),
    );

    // Pulse animation for the logo
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );

    _controller.forward().then((_) {
      // Add a slight delay before navigation
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Get.offAllNamed('/');
        }
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeInAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // NSS Logo with pulse animation
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(80),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(2),
                        child: Image.asset(
                          'assets/images/NSS.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 30),

              // NSS Title
              Text(
                'NSS',
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 12),

              // Subtitle
              Text(
                'National Service Scheme',
                style: TextStyle(
                  fontSize: 18,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Tagline
              Text(
                'Not Me, But You',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.primary.withOpacity(0.8),
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 60),

              // Loading indicator with fade-in
              AnimatedBuilder(
                animation: _fadeInAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeInAnimation.value,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.primary),
                        strokeWidth: 3,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
