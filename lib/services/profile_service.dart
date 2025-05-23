
import '../models/profile_model.dart';

class ProfileService {
  // Get current user profile - HARDCODED VERSION
  Future<ProfileModel> getUserProfile() async {
    // Simply return hardcoded profile data without checking authentication
    return _getHardcodedProfile();
  }

  // Update anonymous username
  Future<bool> updateAnonymousUsername(String newUsername) async {
    // Just return true to simulate successful update
    print('Updated anonymous username to: $newUsername');
    return true;
  }

  // Hardcoded profile data 
  ProfileModel _getHardcodedProfile() {
    final now = DateTime.now();
    
    return ProfileModel(
      id: 'user123',
      displayName: 'Alex Johnson',
      email: 'alex.j@example.com',
      photoURL: null,
      age: 21,
      anonymousUsername: 'MindfulSoul42',
      lastAnonymousUsernameChange: now.subtract(const Duration(days: 10)),
      lifetimePoints: 1780,
      badges: [
        UserBadge(
          id: 'badge1',
          name: 'Early Adopter',
          description: 'Joined during app launch period',
          iconPath: 'assets/images/badges/early_adopter.png',
          earnedDate: now.subtract(const Duration(days: 45)),
        ),
        UserBadge(
          id: 'badge2',
          name: 'Mindfulness Master',
          description: 'Completed 10 mindfulness sessions',
          iconPath: 'assets/images/badges/mindfulness.png',
          earnedDate: now.subtract(const Duration(days: 20)),
        ),
        UserBadge(
          id: 'badge3',
          name: 'Community Contributor',
          description: 'Made 5 supportive comments in the community',
          iconPath: 'assets/images/badges/community.png',
          earnedDate: now.subtract(const Duration(days: 12)),
        ),
        UserBadge(
          id: 'badge4',
          name: 'Streak Keeper',
          description: 'Maintained a 7-day streak',
          iconPath: 'assets/images/badges/streak.png',
          earnedDate: now.subtract(const Duration(days: 5)),
        ),
        UserBadge(
          id: 'badge5',
          name: 'Reflection Pro',
          description: 'Completed 5 journal entries',
          iconPath: 'assets/images/badges/journal.png',
          earnedDate: now.subtract(const Duration(days: 3)),
        ),
        UserBadge(
          id: 'badge6',
          name: 'Resource Explorer',
          description: 'Viewed 10 different resources',
          iconPath: 'assets/images/badges/explorer.png',
          earnedDate: now.subtract(const Duration(days: 1)),
        ),
      ],
    );
  }

  // Former mock profile method kept for reference
  ProfileModel _getMockProfile(String userId) {
    // ...existing code...
    return _getHardcodedProfile(); // Just use our hardcoded profile now
  }
}
