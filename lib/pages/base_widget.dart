import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/pages/Home/home_page.dart';
import 'package:mentalsustainability/theme/app_colors.dart';
import 'package:mentalsustainability/theme/theme_provider.dart';
import '../services/auth_service.dart';
import 'Profile/profile_page.dart';
import 'Community/community_page.dart';
import 'package:mentalsustainability/pages/guide_page.dart';
import 'package:mentalsustainability/pages/Dashboard/dashboard_page.dart'; // New import for Dashboard page

class BaseScreen extends StatefulWidget{
  const BaseScreen({super.key});

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> with SingleTickerProviderStateMixin {
  final AuthService _authService = Get.find<AuthService>();
  bool _isDarkMode = false;
  bool _notificationsEnabled = true;
  late AnimationController _animationController;
  
  // Get the theme provider
  final ThemeProvider _themeProvider = Get.find<ThemeProvider>();
  
  @override
  void initState(){
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Default selected index is Home (0)
  int _selectedIndex = 0;
  
  void _onItemTapped(int index) {
    // Limit index to 0-3
    if (index > 3) return;
    
    setState(() {
      _selectedIndex = index;
    });
    
    // Add animation for bottom nav selection
    _animationController.reset();
    _animationController.forward();
  }

  void _toggleDarkMode(bool value) {
    setState(() {
      _isDarkMode = value;
    });
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isDarkMode 
          ? 'Dark mode enabled' 
          : 'Light mode enabled'),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // TODO: Implement actual dark mode theme switching
  }
  
  void _toggleNotifications(bool value) {
    setState(() {
      _notificationsEnabled = value;
    });
    
    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_notificationsEnabled 
          ? 'Notifications enabled' 
          : 'Notifications disabled'),
        duration: const Duration(seconds: 2),
      ),
    );
    
    // TODO: Implement actual notification preference saving
  }
  
  void _retakeOnboardingQuiz() {
    // TODO: Implement navigation to onboarding quiz
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Starting onboarding quiz...'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  // Handle logout
  Future<void> _handleLogout() async {
    // Show loading indicator
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(),
      ),
      barrierDismissible: false,
    );
    
    try {
      // Clear the token and user data
      await _authService.clearToken();
      await _authService.clearUserId();
      
      // Close the loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      // Show success message
      Get.snackbar(
        'Logout Successful',
        'You have been signed out',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withOpacity(0.1),
        colorText: AppColors.success,
      );
      
      // Navigate to auth page
      Get.offAllNamed('/auth');
    } catch (e) {
      // Close loading dialog if open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      
      print('Error during logout: $e');
      
      // Show error message
      Get.snackbar(
        'Logout Error',
        'An error occurred while signing out',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.error.withOpacity(0.1),
        colorText: AppColors.error,
      );
    }
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: AppColors.background,
      
      // Modern, minimal AppBar with subtle shadow
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        scrolledUnderElevation: 0,
        toolbarHeight: 60, // Reduced from 70 to 60
        leadingWidth: 65, // Reduced from 70 to 65
        leading: Builder(
          builder: (BuildContext context) {
            return Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: IconButton(
                icon: Icon(
                  Icons.menu_rounded,
                  color: AppColors.primary,
                  size: 28,
                ),
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            );
          },
        ),
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/sereine_logo.png', // Replace with actual path to your logo
              width: 75,
              height: 75,
              fit: BoxFit.contain,
            ),
            // const SizedBox(width: 8),
            // Text(
            //   'Sereine',
            //   style: TextStyle(
            //     color: AppColors.primary,
            //     fontWeight: FontWeight.bold,
            //     fontSize: 20,
            //   ),
            // ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(
                Icons.help_outline_rounded,
                color: AppColors.primary,
                size: 28,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const GuidePage())
                );
              },
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          )
        ],
      ),
      
      // Enhanced drawer with the specified features
      drawer: _buildModernDrawer(),

      // Body with extra bottom padding for the floating navigation bar
      body: Container(
        margin: const EdgeInsets.only(bottom: 60), // Space for floating navbar
        child: IndexedStack(
          index: _selectedIndex,
          children: const <Widget>[ // Removed the 'const' keyword here
            HomePage(),
            DashboardPage(), 
            CommunityPage(),
            ProfilePage(),
          ],
        ),
      ),
      
      // Remove default bottom navigation to replace with custom floating one
      bottomNavigationBar: null,
      
      // Floating bottom navigation bar using a positioned container
      extendBody: true, // Important to allow content to flow under the nav bar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      
      // Custom bottom navigation bar as a floating element
      bottomSheet: Container(
        height: 85, // Increased from 80 to 85
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            // The actual navigation bar
            Positioned(
              bottom: 20, // Positioned from bottom to create floating effect
              child: Container(
                height: 65, // Increased from 60 to 65
                width: MediaQuery.of(context).size.width - 32, // Smaller than screen width for floating effect
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black,
                      blurRadius: 10,
                      spreadRadius: 3,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildNavItem(Icons.home_rounded, Icons.home_outlined, 'Home', 0),
                    _buildNavItem(Icons.dashboard_rounded, Icons.dashboard_outlined, 'Dashboard', 1), // Changed from Events to Dashboard
                    _buildNavItem(Icons.people_rounded, Icons.people_outline_rounded, 'Community', 2),
                    _buildNavItem(Icons.person_rounded, Icons.person_outline_rounded, 'Profile', 3),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Custom navigation item builder with animations
  Widget _buildNavItem(IconData activeIcon, IconData inactiveIcon, String label, int index) {
    final bool isSelected = _selectedIndex == index;
    
    return InkWell(
      onTap: () => _onItemTapped(index),
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: isSelected ? BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(24),
        ) : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: Icon(
                isSelected ? activeIcon : inactiveIcon,
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                size: isSelected ? 22 : 20,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            )
          ],
        ),
      ),
    );
  }
  
  Widget _buildModernDrawer() {
    return Drawer(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      backgroundColor: AppColors.white,
      child: Column(
        children: [
          // Modern stylish header
          Container(
            height: 150,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.drawerHeaderStart, AppColors.drawerHeaderEnd],
              ),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(30),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.psychology,
                          color: Colors.white,
                          size: 32,
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sereine',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          // Add admin status indicator
                          Obx(() => _authService.isAdminUser.value
                              ? Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.withOpacity(0.8),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    'ADMIN',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink()),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Mental wellness, simplified',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          
          // Content in a scrollable list
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                // Add admin panel access if user is admin
                Obx(() => _authService.isAdminUser.value
                    ? Column(
                        children: [
                          _buildDrawerMenuItem(
                            icon: Icons.admin_panel_settings,
                            iconColor: Colors.orange,
                            title: 'Admin Panel',
                            subtitle: 'Manage events, users, and notifications',
                            onTap: () {
                              Navigator.pop(context);
                              Get.toNamed('/admin');
                            },
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Divider(height: 32),
                          ),
                        ],
                      )
                    : const SizedBox.shrink()),
                
                // Take Personalised Quiz
                _buildDrawerMenuItem(
                  icon: Icons.quiz,
                  iconColor: AppColors.warning,
                  title: 'Take Personalised Quiz',
                  subtitle: 'Customize your experience',
                  onTap: () {
                    Navigator.pop(context); // Close the drawer first
                    _retakeOnboardingQuiz();
                  },
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(height: 32),
                ),
                
                // Theme selector with modern styling
                _buildDrawerMenuItem(
                  icon: Icons.color_lens,
                  iconColor: AppColors.primary,
                  title: 'App Theme',
                  trailingWidget: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Obx(() => Text(
                      _themeProvider.currentThemeName,
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    )),
                  ),
                  onTap: () {
                    _themeProvider.switchToNextTheme();
                    Navigator.pop(context); // Close drawer
                  },
                ),
                
                // Modern toggle switches
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Row(
                    children: [
                      // Mode toggle
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.purple.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _isDarkMode ? Icons.dark_mode : Icons.light_mode,
                                color: Colors.purple,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Dark Mode',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const Spacer(),
                              Switch(
                                value: _isDarkMode,
                                onChanged: _toggleDarkMode,
                                activeColor: Colors.purple,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Notifications toggle
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _notificationsEnabled ? Icons.notifications_active : Icons.notifications_off,
                          color: Colors.blue,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Notifications',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        Switch(
                          value: _notificationsEnabled,
                          onChanged: _toggleNotifications,
                          activeColor: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(height: 32),
                ),
                
                // Section header with modern styling
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Text(
                    'HELP & INFORMATION',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                
                // Help and Information menu items
                _buildDrawerMenuItem(
                  icon: Icons.menu_book,
                  iconColor: Colors.green,
                  title: 'User Guide',
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const GuidePage())
                    );
                  },
                ),
                
                _buildDrawerMenuItem(
                  icon: Icons.privacy_tip,
                  iconColor: Colors.indigo,
                  title: 'Privacy Policy',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening privacy policy...')),
                    );
                  },
                ),
                
                _buildDrawerMenuItem(
                  icon: Icons.info,
                  iconColor: Colors.teal,
                  title: 'About Sereine',
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Opening about page...')),
                    );
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Sign out button with modern styling
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.logout, size: 18),
                    label: const Text('Sign Out'),
                    onPressed: () {
                      Navigator.pop(context); // Close the drawer
                      _handleLogout(); // Call our logout function
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.red[700],
                      backgroundColor: Colors.red[50],
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Divider(height: 32),
                ),
                
                // Developer options
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Text(
                    'DEVELOPER OPTIONS',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                
                _buildDrawerMenuItem(
                  icon: Icons.admin_panel_settings,
                  iconColor: Colors.red,
                  title: 'Moderator Mode (Demo)',
                  subtitle: 'View community with moderator permissions',
                  onTap: () {
                    Navigator.pop(context); // Close drawer
                    //Get.to(() => const CommunityPage(isModerator: true));
                  },
                ),
                
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  // Reusable drawer menu item
  Widget _buildDrawerMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailingWidget,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              if (trailingWidget != null) trailingWidget,
            ],
          ),
        ),
      ),
    );
  }
}


