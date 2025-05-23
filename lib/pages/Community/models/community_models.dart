import 'package:flutter/material.dart';

// Community post model
class CommunityPost {
  final String id;
  final String username;
  final String content;
  final String timeAgo;
  final int likesCount;
  final int commentsCount;
  final String? imageUrl;
  final List<Comment> comments;

  CommunityPost({
    required this.id,
    required this.username,
    required this.content,
    required this.timeAgo,
    this.likesCount = 0,
    required this.commentsCount,
    this.imageUrl,
    this.comments = const [],
  });

  // Add copyWith method for updating post properties
  CommunityPost copyWith({
    String? id,
    String? username,
    String? content,
    String? timeAgo,
    int? likesCount,
    int? commentsCount,
    String? imageUrl,
    List<Comment>? comments,
  }) {
    return CommunityPost(
      id: id ?? this.id,
      username: username ?? this.username,
      content: content ?? this.content,
      timeAgo: timeAgo ?? this.timeAgo,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      imageUrl: imageUrl ?? this.imageUrl,
      comments: comments ?? this.comments,
    );
  }
}

// Comment model
class Comment {
  final String username;
  final String content;
  final String timeAgo;

  Comment({
    required this.username,
    required this.content,
    required this.timeAgo,
  });
}

// SA Team Member model
class SATeamMember {
  final String id;
  final String name;
  final String specialty;
  final String bio;
  final Color bookColor;
  final List<String> presetMessages;

  const SATeamMember({
    required this.id,
    required this.name,
    required this.specialty,
    required this.bio,
    required this.bookColor,
    required this.presetMessages,
  });
}

// Team member model
class TeamMember {
  final String name;
  final String role;
  final String specialty;
  final String? imageUrl;

  TeamMember({
    required this.name,
    required this.role,
    required this.specialty,
    this.imageUrl,
  });
}

// Resource item model
class ResourceItem {
  final String title;
  final String description;
  final String type;
  final String duration;
  
  ResourceItem({
    required this.title,
    required this.description,
    required this.type,
    required this.duration,
  });
}

// SA Team members data
final List<SATeamMember> _saTeamMembers = [
  const SATeamMember(
    id: 'sa1',
    name: 'Alisa',
    specialty: 'Anxiety & Stress',
    bio: 'Peer supporter with experience helping fellow students manage anxiety and stress.',
    bookColor: Colors.deepPurple,
    presetMessages: [
      "Hi there! I'm Alisa. How can I support you today?",
      "Remember that feeling anxious is a normal response to stress. Let's talk about it.",
      "Would you like to learn some breathing techniques that can help in moments of stress?",
    ],
  ),
  const SATeamMember(
    id: 'sa2',
    name: 'Rohan',
    specialty: 'Peer Support',
    bio: 'Student who has personal experience with overcoming depression and wants to help others.',
    bookColor: Colors.teal,
    presetMessages: [
      "Hey! I'm Rohan. I'm here to listen without judgment.",
      "As someone who's been through similar struggles, I understand how overwhelming things can get.",
      "Would you like to share what's been on your mind lately?",
    ],
  ),
  const SATeamMember(
    id: 'sa3',
    name: 'Misha',
    specialty: 'Academic Pressure',
    bio: 'Student mentor specializing in helping peers navigate academic stress and expectations.',
    bookColor: Colors.indigo,
    presetMessages: [
      "Hi, I'm Misha. Feeling overwhelmed with coursework?",
      "Let's discuss some strategies to balance your academic responsibilities.",
      "Remember that your worth isn't determined by your grades or achievements.",
    ],
  ),
  SATeamMember(
    id: 'sa4',
    name: 'Jorge',
    specialty: 'Grief & Loss',
    bio: 'Peer supporter trained to help individuals process grief and navigate significant life changes.',
    bookColor: Colors.amber.shade800,
    presetMessages: [
      "Hello, I'm Jorge. I create a safe space for discussing difficult emotions.",
      "Grief can come in many forms. How has your experience been?",
      "It's okay to not be okay. I'm here to support you through this process.",
    ],
  ),
  SATeamMember(
    id: 'sa5',
    name: 'Neela',
    specialty: 'Cultural Adaptation',
    bio: 'International student who helps peers navigate cultural transitions and identity challenges.',
    bookColor: Colors.pink.shade700,
    presetMessages: [
      "Hi, I'm Neela. Adjusting to a new environment can be challenging.",
      "I'd love to hear about your experiences and how you've been coping.",
      "What aspects of the transition have been most difficult for you?",
    ],
  ),
  SATeamMember(
    id: 'sa6',
    name: 'Danny',
    specialty: 'LGBTQ+ Support',
    bio: 'Student advocate for LGBTQ+ peers, focusing on identity, acceptance, and community building.',
    bookColor: Colors.blue.shade800,
    presetMessages: [
      "Hello! I'm Danny. This is a judgment-free zone where you can be yourself.",
      "How have you been feeling about your identity and place in the community?",
      "Would you like to discuss resources or support groups available on campus?",
    ],
  ),
  SATeamMember(
    id: 'sa7',
    name: 'Layla',
    specialty: 'Relationship Issues',
    bio: 'Peer supporter trained in interpersonal relationships, communication skills, and boundary setting.',
    bookColor: Colors.red.shade700,
    presetMessages: [
      "Hi, I'm Layla. Navigating relationships can be complex.",
      "How have your connections with others been affecting your well-being?",
      "Let's talk about healthy boundaries and communication strategies.",
    ],
  ),
  SATeamMember(
    id: 'sa8',
    name: 'Kevin',
    specialty: 'Substance Use',
    bio: 'Student who provides non-judgmental support for peers dealing with substance use concerns.',
    bookColor: Colors.green.shade800,
    presetMessages: [
      "Hey there, I'm Kevin. I'm here to listen and support, not to judge.",
      "Would you like to talk about how substance use has been impacting your life?",
      "There are many paths to wellness. Let's explore what might work for you.",
    ],
  ),
  SATeamMember(
    id: 'sa9',
    name: 'Sonia',
    specialty: 'Self-Esteem',
    bio: 'Peer mentor focused on building self-worth, resilience, and personal strengths.',
    bookColor: Colors.purple.shade800,
    presetMessages: [
      "Hello! I'm Sonia. I believe in your inherent worth and potential.",
      "How has your relationship with yourself been lately?",
      "Let's explore the unique strengths you possess that you might not fully recognize yet.",
    ],
  ),
];

