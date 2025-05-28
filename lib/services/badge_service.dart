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

  // Calculate badges based on user data
  List<AchievementBadge> calculateUserBadges() {
    print('Calculating user badges');
    final List<AchievementBadge> badges = [];
    
    try {
      // Try to access the auth service - might be null in early init
      AuthService? authService;
      try {
        authService = Get.find<AuthService>();
        print('Found AuthService for badge calculation');
      } catch (e) {
        print('AuthService not available for badge calculation: $e');
      }

      // Removed NSS Member Badge
    
      // Only calculate dynamic badges if we have auth service
      if (authService != null) {
        // 2. Volunteer Badge - based on volunteer status
        if (authService.isVolunteer) {
          badges.add(AchievementBadge(
            id: 'volunteer',
            name: 'NSS Volunteer',
            description: 'Registered as an NSS volunteer',
            icon: Icons.volunteer_activism,
            color: Colors.green,
            level: 1,
          ));
        } else if (authService.isWishVolunteer) {
          badges.add(AchievementBadge(
            id: 'volunteer_pending',
            name: 'Volunteer Applicant',
            description: 'Applied to become an NSS volunteer',
            icon: Icons.hourglass_top,
            color: Colors.orange,
            level: 1,
          ));
        }
        
        // 3. Points Badge - based on total points
        final int points = authService.points;
        print('User has $points points for badge calculation');
        if (points > 0) {
          int level = 1;
          String name = 'Point Collector';
          String description = 'Earned NSS points through participation';
          
          if (points >= 2500) {
            level = 5;
            name = 'Diamond Contributor';
            description = 'Earned 2500+ NSS points';
          } else if (points >= 1000) {
            level = 4;
            name = 'Platinum Contributor';
            description = 'Earned 1000-2499 NSS points';
          } else if (points >= 500) {
            level = 3;
            name = 'Gold Contributor';
            description = 'Earned 500-999 NSS points';
          } else if (points >= 200) {
            level = 2;
            name = 'Silver Contributor';
            description = 'Earned 200-499 NSS points';
          }
          
          badges.add(AchievementBadge(
            id: 'points_$level',
            name: name,
            description: description,
            icon: Icons.stars,
            color: Colors.amber,
            level: level,
          ));
        }
        
        // 4. Event Participation Badge - estimate based on points
        final int eventsAttended = (points / 50).floor(); // Assuming 50 points per event
        print('Estimated $eventsAttended events attended based on points');
        if (eventsAttended > 0) {
          int level = 1;
          String name = 'Event Participant';
          String description = 'Participated in NSS events';
          
          if (eventsAttended >= 15) {
            level = 5;
            name = 'Event Master';
            description = 'Participated in 15+ NSS events';
          } else if (eventsAttended >= 10) {
            level = 4;
            name = 'Event Expert';
            description = 'Participated in 10-14 NSS events';
          } else if (eventsAttended >= 5) {
            level = 3;
            name = 'Event Enthusiast';
            description = 'Participated in 5-9 NSS events';
          } else if (eventsAttended >= 3) {
            level = 2;
            name = 'Event Attendee';
            description = 'Participated in 3-4 NSS events';
          }
          
          badges.add(AchievementBadge(
            id: 'event_participation_$level',
            name: name,
            description: description,
            icon: Icons.event_available,
            color: Colors.blue,
            level: level,
          ));
        }
      }
    
      // 5. Community Badge - for all users
      badges.add(AchievementBadge(
        id: 'community_member',
        name: 'Community Member',
        description: 'Part of the NSS community',
        icon: Icons.people,
        color: Colors.purple,
        level: 1,
      ));
      
      // Update cached badges
      _cachedBadges.value = badges;
      print('Calculated ${badges.length} badges');
      
    } catch (e) {
      print('Error calculating badges: $e');
      // Return default badges if calculation fails
      if (badges.isEmpty) {
        _createDefaultBadges();
        return _cachedBadges;
      }
    }
    
    return badges;
  }
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
