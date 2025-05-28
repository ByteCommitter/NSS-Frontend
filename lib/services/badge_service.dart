import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/services/auth_service.dart';
import 'package:mentalsustainability/theme/app_colors.dart';

class BadgeService extends GetxService {
  final AuthService _authService = Get.find<AuthService>();
  
  // Calculate badges based on user data
  List<AchievementBadge> calculateUserBadges() {
    final List<AchievementBadge> badges = [];
    
    // 1. Volunteer Status Badge
    if (_authService.isVolunteer) {
      badges.add(AchievementBadge(
        id: 'volunteer',
        name: 'NSS Volunteer',
        description: 'Registered as an NSS volunteer',
        icon: Icons.volunteer_activism,
        color: Colors.green,
        level: 1,
      ));
    }
    
    // 2. Event Participation Badge
    final int eventsAttended = _calculateEventsAttended();
    if (eventsAttended > 0) {
      int level = 1;
      String description = 'Participated in NSS events';
      
      if (eventsAttended >= 21) {
        level = 5;
        description = 'Participated in 21+ NSS events';
      } else if (eventsAttended >= 11) {
        level = 4;
        description = 'Participated in 11-20 NSS events';
      } else if (eventsAttended >= 6) {
        level = 3;
        description = 'Participated in 6-10 NSS events';
      } else if (eventsAttended >= 3) {
        level = 2;
        description = 'Participated in 3-5 NSS events';
      }
      
      badges.add(AchievementBadge(
        id: 'event_participant',
        name: 'Event Participant',
        description: description,
        icon: Icons.event_available,
        color: Colors.blue,
        level: level,
      ));
    }
    
    // 3. Points Badge
    final int points = _authService.points;
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
        id: 'points',
        name: name,
        description: description,
        icon: Icons.stars,
        color: Colors.amber,
        level: level,
      ));
    }
    
    // 4. Simplified specialized badges (no backend required)
    
    // Community Leader badge - based on points threshold
    if (points >= 300) {
      badges.add(AchievementBadge(
        id: 'community_leader',
        name: 'Community Leader',
        description: 'Recognized for community impact and leadership',
        icon: Icons.people,
        color: Colors.purple,
        level: points >= 1000 ? 3 : (points >= 600 ? 2 : 1),
      ));
    }
    
    // Environmental Champion - based on participation count
    if (eventsAttended >= 2) {
      badges.add(AchievementBadge(
        id: 'eco_champion',
        name: 'Environmental Champion',
        description: 'Contributed to environmental sustainability initiatives',
        icon: Icons.eco,
        color: Colors.green[800]!,
        level: eventsAttended >= 10 ? 3 : (eventsAttended >= 5 ? 2 : 1),
      ));
    }
    
    // Social Impact badge - based on total experience
    if (points > 100 && eventsAttended >= 1) {
      badges.add(AchievementBadge(
        id: 'social_impact',
        name: 'Social Impact',
        description: 'Made a positive difference in your community',
        icon: Icons.handshake,
        color: Colors.blue[700]!,
        level: (points / 200).floor().clamp(1, 3),
      ));
    }
    
    return badges;
  }
  
  // Helper method to calculate events attended (placeholder)
  int _calculateEventsAttended() {
    // In a real implementation, this would fetch from API or local storage
    // For now, use points as a proxy
    return (_authService.points / 50).floor();
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
