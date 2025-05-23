import 'package:get/get.dart';
import 'app_colors.dart';

class ThemeProvider extends GetxController {
  // Observable to track current theme name
  final Rx<String> _currentThemeName = AppColors.currentTheme.name.obs;
  
  // Getter for current theme name
  String get currentThemeName => _currentThemeName.value;
  
  // List of available themes
  final List<AppTheme> availableThemes = [
    AppColors.purpleTheme,
    AppColors.tealTheme,
    AppColors.indigoTheme,
  ];
  
  // Switch to a specific theme by name
  void switchToTheme(String themeName) {
    final theme = availableThemes.firstWhere(
      (theme) => theme.name == themeName,
      orElse: () => AppColors.purpleTheme,
    );
    
    AppColors.setTheme(theme);
    _currentThemeName.value = theme.name;
    
    // Refresh UI
    update();
    Get.forceAppUpdate();
  }
  
  // Switch to the next theme in the list
  void switchToNextTheme() {
    final currentIndex = availableThemes.indexWhere((theme) => theme.name == currentThemeName);
    final nextIndex = (currentIndex + 1) % availableThemes.length;
    switchToTheme(availableThemes[nextIndex].name);
  }
}
