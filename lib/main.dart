import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/pages/base_widget.dart';
import 'package:mentalsustainability/pages/guide_page.dart';
import 'package:mentalsustainability/theme/app_colors.dart';
import 'package:mentalsustainability/theme/theme_provider.dart';
import 'pages/auth_wrapper.dart';
import 'services/onboarding_screen.dart';
import 'services/auth_service.dart';
import 'services/api_service.dart';
import 'package:mentalsustainability/services/socket_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await initServices();
  
  runApp(const MyApp());
}

// Initialize all services
Future<void> initServices() async {
  print('Starting services initialization...');
  
  // Initialize other services first
  // Initialize providers
  Get.put(ThemeProvider());
  Get.put(AuthService());
  Get.put(ApiService());
  
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
        title: 'Sereine',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.primary,
            primary: AppColors.primary,
            secondary: AppColors.accent,
            background: AppColors.background,
            error: AppColors.error,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: AppColors.background,
          appBarTheme: AppBarTheme(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.primary,
            elevation: 0,
          ),
          cardTheme: CardTheme(
            color: AppColors.cardBackground,
          ),
          dividerTheme: DividerTheme.of(context).copyWith(
            color: AppColors.divider,
          ),
        ),
        home:SplashScreen(), // Use splash screen first, then it will navigate to login
        getPages: [
          GetPage(name: '/', page: () => SplashScreen()),
          GetPage(name: '/auth', page: () => AuthWrapper()),
          GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
          GetPage(name: '/home', page: () => const BaseScreen()),
          GetPage(name: '/guide', page: () => const GuidePage()),
        ],
      ),
    );
  }
}

// Splash screen with the Sereine logo
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeInAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    _fadeInAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutBack),
      ),
    );
    
    _controller.forward();
    
    // Navigate to the auth page after splash animation
    Future.delayed(const Duration(seconds: 2), () {
      Get.offAllNamed('/auth'); // Changed back to '/auth'
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
              // Logo image from assets (only showing the logo, no text)
              Image.asset(
                'assets/images/Sereine Logo with Brain and Leaf.png',
                width: 200,
                height: 200,
              ),
            ],
          ),
        ),
      ),
    );
  }
}