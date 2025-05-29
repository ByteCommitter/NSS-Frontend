import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/theme/app_colors.dart';
import 'package:mentalsustainability/services/auth_service.dart';
import 'package:mentalsustainability/services/api_service.dart';

class BadgeService extends GetxService {
  // Services
  late final AuthService _authService;
  late final ApiService _apiService;
  
  // Cache for badges
  final RxList<AchievementBadge> _cachedBadges = RxList<AchievementBadge>([]);
  
  // Add a timestamp to track when badges were last calculated
  DateTime? _lastCalculated;
  
  // Initialize with services
  BadgeService() {
    print('BadgeService constructor called');
    try {
      _authService = Get.find<AuthService>();
      _apiService = Get.find<ApiService>();
      print('BadgeService found required services');
    } catch (e) {
      print('Warning: BadgeService initialized without required services: $e');
    }
    
    // Create default badges
    _createDefaultBadges();
  }

  // Create default badges for initial state
  void _createDefaultBadges() {
    print('Creating default badges');
    final List<AchievementBadge> defaultBadges = [
      // Removed NSS Member badge
      AchievementBadge(
        id: 'event_participant',
        name: 'Event Participant',
        description: 'Participated in NSS events',
        icon: Icons.event_available,
        color: Colors.blue,
        level: 1,
      ),
    ];
    
    _cachedBadges.value = defaultBadges;
    print('Default badges created: ${_cachedBadges.length}');
  }
  
  // Get the latest badges (from cache or recalculate)
  List<AchievementBadge> getBadges({bool forceRefresh = false}) {
    print('getBadges called with forceRefresh=$forceRefresh');
    if (forceRefresh || _cachedBadges.isEmpty) {
      print('Forcing badge recalculation');
      return calculateUserBadges();
    }
    print('Returning ${_cachedBadges.length} cached badges');
    return _cachedBadges.toList();
  }

  // FIXED: Add method to force refresh and clear cache
  void refreshBadges() {
    print('BadgeService: Force refreshing badges and clearing cache');
    _cachedBadges.clear();
    _lastCalculated = null;
    // Trigger recalculation on next access
    calculateUserBadges();
  }

  // Calculate badges based on user data
  List<AchievementBadge> calculateUserBadges() {
    print('=== BadgeService: calculateUserBadges START ===');
    
    final List<AchievementBadge> badges = [];
    
    try {
      AuthService? authService;
      try {
        authService = Get.find<AuthService>();
        print('BadgeService: Found AuthService - isVolunteer=${authService.isVolunteer}, points=${authService.points}');
      } catch (e) {
        print('BadgeService: AuthService not available: $e');
        return [];
      }

      // 1. Volunteer Badge - ONLY for active volunteers (not wishVolunteers)
      if (authService.isVolunteer) {
        print('BadgeService: Adding NSS Volunteer badge (isVolunteer=true)');
        badges.add(AchievementBadge(
          id: 'volunteer',
          name: 'NSS Volunteer',
          description: 'Registered as an NSS volunteer',
          icon: Icons.volunteer_activism,
          color: Colors.green,
          level: 1,
        ));
      } else {
        print('BadgeService: NOT adding NSS Volunteer badge (isVolunteer=false)');
      }
      
      // 2. Points Badge - based on total points
      final int points = authService.points;
      print('BadgeService: User has $points points');
      if (points > 0) {
        print('BadgeService: Adding points badge for $points points');
        badges.add(AchievementBadge(
          id: 'points',
          name: points >= 100 ? 'Star Contributor' : 'Point Collector',
          description: 'Earned $points NSS points',
          icon: Icons.stars,
          color: points >= 100 ? Colors.amber : Colors.orange,
          level: (points / 50).floor() + 1,
        ));
      } else {
        print('BadgeService: NOT adding points badge (points=0)');
      }
      
      // 3. Community Badge - for ALL users (always)
      print('BadgeService: Adding Community Member badge (always added)');
      badges.add(AchievementBadge(
        id: 'community',
        name: 'Community Member',
        description: 'Part of the NSS community',
        icon: Icons.people,
        color: Colors.purple,
        level: 1,
      ));
      
      // Update cache
      _cachedBadges.clear();
      _cachedBadges.addAll(badges);
      _lastCalculated = DateTime.now();
      
      print('BadgeService: FINAL RESULT - ${badges.length} badges: ${badges.map((b) => b.name).join(', ')}');
    } catch (e) {
      print('BadgeService: Error calculating badges: $e');
    }
    
    print('=== BadgeService: calculateUserBadges END (${badges.length} badges) ===');
    return badges;
  }
  
  // Force refresh badges when user status changes
}

// Badge model class
class AchievementBadge {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final int level;
  
  AchievementBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.level,
  });
}
