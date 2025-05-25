import 'package:get/get.dart';
import 'package:mentalsustainability/pages/Home/home_page.dart';
import 'package:mentalsustainability/pages/Development/socket_test_page.dart';

/// This class contains all the application routes and navigation pages
/// It centralizes navigation to make it easier to maintain and update
class AppRoutes {
  // Main app routes
  static const String initial = '/';
  static const String home = '/home';
  
  // Development routes
  static const String socketDebug = '/socket-debug';
  
  /// Define all application routes here
  static final routes = [
    // Main routes
    GetPage(
      name: initial,
      page: () => const HomePage(),
      transition: Transition.fadeIn,
    ),
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