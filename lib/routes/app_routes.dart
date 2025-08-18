import 'package:get/get.dart';
import 'package:mentalsustainability/chatservice/pages/gen_chatpage.dart';
import 'package:mentalsustainability/main.dart';
import 'package:mentalsustainability/pages/Community/community_page.dart';
import 'package:mentalsustainability/pages/Home/home_page.dart';
import 'package:mentalsustainability/pages/Development/socket_test_page.dart';
import 'package:mentalsustainability/pages/login_screen.dart';
import 'package:mentalsustainability/pages/auth/registration_screen.dart';
import 'package:mentalsustainability/pages/auth/forgot_password_screen.dart';

/// This class contains all the application routes and navigation pages
/// It centralizes navigation to make it easier to maintain and update
class AppRoutes {
  // Main app routes
  static const String initial = '/';
  static const String home = '/home';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String otpVerification = '/otp-verification';
  static const String splash = '/splash';
  static const String chats = '/chats';
  // Development routes
  static const String socketDebug = '/socket-debug';

  /// Define all application routes here
  static final routes = [
    // Authentication routes
    GetPage(
      name: initial,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
        name: splash,
        page: () => const SplashScreen(),
        transition: Transition.fadeIn),
    GetPage(
      name: login,
      page: () => const LoginScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: register,
      page: () => const RegistrationScreen(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
      name: forgotPassword,
      page: () => const ForgotPasswordScreen(),
      transition: Transition.rightToLeft,
    ),

    // Main routes
    GetPage(
      name: home,
      page: () => const HomePage(),
      transition: Transition.fadeIn,
    ),

    // Development routes
    GetPage(
      name: socketDebug,
      page: () => const SocketTestPage(),
      transition: Transition.rightToLeft,
    ),
    GetPage(
        name: chats,
        page: () => const CommunityPage(),
        transition: Transition.rightToLeft)
  ];

  /// Navigate to a named route
  static void navigateTo(String routeName) {
    Get.toNamed(routeName);
  }

  /// Navigate to a named route and remove previous route from stack
  static void navigateOffTo(String routeName) {
    Get.offNamed(routeName);
  }

  /// Navigate to a named route and remove all previous routes from stack
  static void navigateOffAllTo(String routeName) {
    Get.offAllNamed(routeName);
  }

  /// Go back to previous route
  static void goBack() {
    Get.back();
  }
}
