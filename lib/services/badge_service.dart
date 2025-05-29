import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  // REMOVE the old calculateUserBadges method - replace with getSharedBadges call
  List<AchievementBadge> calculateUserBadges() {
    print('=== BadgeService: calculateUserBadges redirecting to SHARED method ===');
    return getSharedBadges();
  }

  // SHARED METHOD - Both pages use this EXACT same function
  static List<AchievementBadge> getSharedBadges() {
    print('=== SHARED: getSharedBadges START ===');
    
    final List<AchievementBadge> badges = [];
    
    try {
      AuthService? authService;
      try {
        authService = Get.find<AuthService>();
        print('SHARED: Found AuthService - isVolunteer=${authService.isVolunteer}, points=${authService.points}');
      } catch (e) {
        print('SHARED: AuthService not available: $e');
        return [];
      }

      // 1. Volunteer Badge - ONLY for active volunteers
      if (authService.isVolunteer) {
        print('SHARED: Adding NSS Volunteer badge');
        badges.add(AchievementBadge(
          id: 'volunteer',
          name: 'NSS Volunteer',
          description: 'Registered as an NSS volunteer',
          icon: Icons.volunteer_activism,
          color: Colors.green,
          level: 1,
        ));
      }
      
      // 2. Points Badge System
      final int points = authService.points;
      print('SHARED: User has $points points');
      
      if (points >= 50) {
        String badgeName = 'Bronze Starter';
        String badgeDescription = 'Getting started with NSS activities';
        Color badgeColor = Colors.brown;
        int badgeLevel = 1;
        
        if (points >= 2500) {
          badgeName = 'Diamond Legend';
          badgeDescription = 'Elite NSS contributor with 2500+ points';
          badgeColor = Colors.cyan;
          badgeLevel = 50 + ((points - 2500) / 100).floor();
        } else if (points >= 1000) {
          badgeName = 'Platinum Champion';
          badgeDescription = 'Outstanding contributor with 1000+ points';
          badgeColor = Colors.blueGrey;
          badgeLevel = 20 + ((points - 1000) / 50).floor();
        } else if (points >= 500) {
          badgeName = 'Gold Star';
          badgeDescription = 'Exceptional contributor with 500+ points';
          badgeColor = Colors.amber;
          badgeLevel = 10 + ((points - 500) / 50).floor();
        } else if (points >= 200) {
          badgeName = 'Silver Achiever';
          badgeDescription = 'Active contributor with 200+ points';
          badgeColor = Colors.grey.shade600;
          badgeLevel = 4 + ((points - 200) / 50).floor();
        } else if (points >= 50) {
          badgeLevel = 1 + ((points - 50) / 50).floor();
        }
        
        print('SHARED: Adding $badgeName badge (Level $badgeLevel)');
        badges.add(AchievementBadge(
          id: 'points_tier',
          name: badgeName,
          description: badgeDescription,
          icon: Icons.stars,
          color: badgeColor,
          level: badgeLevel,
        ));
      }
      
      // 3. Event Participation Badge
      final int estimatedEvents = (points / 50).floor();
      if (estimatedEvents >= 1) {
        String eventBadgeName = 'First Steps';
        String eventDescription = 'Started participating in NSS events';
        Color eventColor = Colors.teal;
        int eventLevel = 1;
        
        if (estimatedEvents >= 20) {
          eventBadgeName = 'Event Master';
          eventDescription = 'Participated in 20+ NSS events';
          eventColor = Colors.deepPurple;
          eventLevel = 5;
        } else if (estimatedEvents >= 10) {
          eventBadgeName = 'Event Expert';
          eventDescription = 'Participated in 10+ NSS events';
          eventColor = Colors.indigo;
          eventLevel = 4;
        } else if (estimatedEvents >= 5) {
          eventBadgeName = 'Event Enthusiast';
          eventDescription = 'Participated in 5+ NSS events';
          eventColor = Colors.blue;
          eventLevel = 3;
        } else if (estimatedEvents >= 3) {
          eventBadgeName = 'Regular Participant';
          eventDescription = 'Participated in 3+ NSS events';
          eventColor = Colors.lightBlue;
          eventLevel = 2;
        }
        
        print('SHARED: Adding $eventBadgeName badge (Level $eventLevel)');
        badges.add(AchievementBadge(
          id: 'events',
          name: eventBadgeName,
          description: eventDescription,
          icon: Icons.event_available,
          color: eventColor,
          level: eventLevel,
        ));
      }
      
      // 4. Community Badge - for ALL users
      print('SHARED: Adding Community Member badge');
      badges.add(AchievementBadge(
        id: 'community',
        name: 'Community Member',
        description: 'Welcome to the NSS community!',
        icon: Icons.people,
        color: Colors.purple,
        level: 1,
      ));
      
      // 5. Top Performer Badge
      if (points >= 1000) {
        print('SHARED: Adding Top Performer badge');
        badges.add(AchievementBadge(
          id: 'top_performer',
          name: 'Top Performer',
          description: 'Among the top contributors in NSS',
          icon: Icons.emoji_events,
          color: Colors.orange,
          level: (points / 500).floor(),
        ));
      }
      
      print('SHARED: FINAL RESULT - ${badges.length} badges: ${badges.map((b) => '${b.name} (L${b.level})').join(', ')}');
    } catch (e) {
      print('SHARED: Error calculating badges: $e');
    }
    
    print('=== SHARED: getSharedBadges END (${badges.length} badges) ===');
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
