

import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileModel {
  String id;
  String displayName;
  String email;
  String? photoURL;
  int age;
  String anonymousUsername;
  DateTime? lastAnonymousUsernameChange;
  int lifetimePoints;
  List<UserBadge> badges;

  ProfileModel({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoURL,
    required this.age,
    required this.anonymousUsername,
    this.lastAnonymousUsernameChange,
    this.lifetimePoints = 0,
    this.badges = const [],
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'] ?? '',
      displayName: map['displayName'] ?? 'User',
      email: map['email'] ?? '',
      photoURL: map['photoURL'],
      age: map['age'] ?? 0,
      anonymousUsername: map['anonymousUsername'] ?? 'Anonymous',
      lastAnonymousUsernameChange: map['lastAnonymousUsernameChange'] != null
          ? (map['lastAnonymousUsernameChange'] as Timestamp).toDate()
          : null,
      lifetimePoints: map['lifetimePoints'] ?? 0,
      badges: map['badges'] != null
          ? List<UserBadge>.from(
              (map['badges'] as List).map((x) => UserBadge.fromMap(x)))
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'photoURL': photoURL,
      'age': age,
      'anonymousUsername': anonymousUsername,
      'lastAnonymousUsernameChange': lastAnonymousUsernameChange,
      'lifetimePoints': lifetimePoints,
      'badges': badges.map((x) => x.toMap()).toList(),
    };
  }

  // Check if user can change anonymous username
  bool canChangeAnonymousUsername() {
    if (lastAnonymousUsernameChange == null) return true;
    
    final now = DateTime.now();
    final difference = now.difference(lastAnonymousUsernameChange!);
    return difference.inDays >= 7;
  }

  // Days remaining until anonymous username can be changed again
  int daysUntilUsernameChangeAllowed() {
    if (lastAnonymousUsernameChange == null) return 0;
    
    final now = DateTime.now();
    final difference = now.difference(lastAnonymousUsernameChange!);
    final daysRemaining = 7 - difference.inDays;
    return daysRemaining > 0 ? daysRemaining : 0;
  }
}

class UserBadge {
  String id;
  String name;
  String description;
  String iconPath;
  DateTime earnedDate;

  UserBadge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    required this.earnedDate,
  });

  factory UserBadge.fromMap(Map<String, dynamic> map) {
    return UserBadge(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      iconPath: map['iconPath'] ?? '',
      earnedDate: (map['earnedDate'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconPath': iconPath,
      'earnedDate': earnedDate,
    };
  }
}
