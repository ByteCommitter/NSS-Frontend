import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/theme/app_colors.dart';
import 'post_thread_page.dart';
import 'package:mentalsustainability/pages/Community/moderator_dashboard.dart';

// Import the new tab files
import 'community_threads_tab.dart';
import 'community_sereine_team_tab.dart';
import 'community_seremate_tab.dart';
import 'models/community_models.dart';

class CommunityPage extends StatefulWidget {
  final String? prefilledPost;
  final bool isModerator;
  
  const CommunityPage({
    super.key, 
    this.prefilledPost,
    this.isModerator = false, // Default to false,
  });

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> with SingleTickerProviderStateMixin {
  // Add TabController for managing tabs
  late TabController _tabController;
  
  // Add text controller for post content
  late TextEditingController _postController;
  
  // Add a map to track posts that the user has already liked
  final Map<String, bool> _likedPosts = {};
  
  // Add a map to track posts that the user has saved
  final Map<String, bool> _savedPosts = {};
  
  // Track total user points
  final int _userPoints = 0;

  final List<CommunityPost> _posts = [
    CommunityPost(
      id: '1',
      username: 'DuckMyHeader42',
      content: 'Just completed a 7-day mindfulness streak. Feeling much more centered and focused!',
      timeAgo: '2h ago',
      likesCount: 15,
      commentsCount: 3,
      comments: [
        Comment(
          username: 'MindfulnessFan',
          content: 'That\'s awesome! Did you notice any specific improvements?',
          timeAgo: '1h ago',
        ),
        Comment(
          username: 'ZenMaster',
          content: 'I\'ve been wanting to try this. Any tips for beginners?',
          timeAgo: '45m ago',
        ),
        Comment(
          username: 'DuckMyHeader42',
          content: 'Start small with just 5 minutes a day. Consistency is key!',
          timeAgo: '30m ago',
        ),
      ],
    ),
    CommunityPost(
      id: '2',
      username: 'CalmMind88',
      content: 'Completed my Quests for the Week - planter project using repurposed plastic bottles. Small steps toward sustainability!',
      timeAgo: '5h ago',
      likesCount: 24,
      commentsCount: 4,
      imageUrl: 'assets/images/repurposed_plastic.png',
      comments: [
        Comment(
          username: 'GreenThumb',
          content: 'This looks amazing! What kind of plants did you put in them?',
          timeAgo: '4h ago',
        ),
        Comment(
          username: 'EcoWarrior',
          content: 'Great job repurposing! Did you have any issues with drainage?',
          timeAgo: '3h ago',
        ),
        Comment(
          username: 'CalmMind88',
          content: 'Thanks! I used herbs for the kitchen and added small holes at the bottom for drainage.',
          timeAgo: '2h ago',
        ),
        Comment(
          username: 'PlantLover22',
          content: 'I\'m totally going to try this over the weekend!',
          timeAgo: '1h ago',
        ),
      ],
    ),
    CommunityPost(
      id: '3',
      username: 'SerenitySeeker',
      content: 'I found this amazing resource for free guided meditations. Highly recommend for anyone looking to start meditation: https://example.com/meditations',
      timeAgo: '1d ago',
      likesCount: 42,
      commentsCount: 5,
      comments: [
        Comment(
          username: 'MeditationNewbie',
          content: 'Thanks for sharing! Just tried the beginner one and it was perfect.',
          timeAgo: '20h ago',
        ),
        Comment(
          username: 'AnxietyFighter',
          content: 'Do they have any specific ones for anxiety?',
          timeAgo: '18h ago',
        ),
        Comment(
          username: 'SerenitySeeker',
          content: 'Yes! Check the "Anxiety Relief" section. There are 5-minute quick ones and longer sessions.',
          timeAgo: '17h ago',
        ),
        Comment(
          username: 'AnxietyFighter',
          content: 'Found them, thank you so much!',
          timeAgo: '16h ago',
        ),
        Comment(
          username: 'SleepStruggler',
          content: 'The sleep meditations changed my life. I\'ve been sleeping better for the first time in years.',
          timeAgo: '12h ago',
        ),
      ],
    ),
    CommunityPost(
      id: '4',
      username: 'MentalHealthMatters',
      content: 'Reminder: It\'s okay to take breaks. Sometimes the most productive thing you can do is rest.',
      timeAgo: '2d ago',
      likesCount: 0,
      commentsCount: 15,
      comments: [],
    ),
    CommunityPost(
      id: '5',
      username: 'WellnessJourney',
      content: 'Just had a great therapy session today. If you\'ve been thinking about trying therapy, this is your sign to give it a shot!',
      timeAgo: '3d ago',
      likesCount: 0,
      commentsCount: 6,
      comments: [],
    ),
  ];

  // Current user identifier - in a real app this would come from authentication
  final String currentUser = 'You';
  
  // Banned users set
  final Set<String> _bannedUsers = {};

  @override
  void initState() {
    super.initState();
    // Initialize tab controller with 3 tabs
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialize controller with prefilled text if available
    _postController = TextEditingController(text: widget.prefilledPost);
    
    // If post is prefilled, ensure we start on the Threads tab
    if (widget.prefilledPost != null && widget.prefilledPost!.isNotEmpty) {
      _tabController.animateTo(0); // Switch to Threads tab
    }

    // If user is a moderator, show an indication
    if (widget.isModerator) {
      Future.delayed(const Duration(milliseconds: 300), () {
        Get.snackbar(
          'Moderator Mode',
          'You have elevated permissions to manage community content.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.orange.withOpacity(0.9),
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 3),
          icon: const Icon(Icons.shield, color: Colors.white),
        );
      });
    }
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _postController.dispose();
    super.dispose();
  }

  // void _navigateToSALibrary() {
  //   Get.to(() => const SALibraryPage());
  // }

  void _handleLike(String postId) {
    // Toggle like status
    if (_likedPosts[postId] ?? false) {
      _likedPosts[postId] = false;
      setState(() {
        final postIndex = _posts.indexWhere((post) => post.id == postId);
        if (postIndex != -1) {
          _posts[postIndex] = _posts[postIndex].copyWith(
            likesCount: _posts[postIndex].likesCount - 1
          );
        }
      });
    } else {
      _likedPosts[postId] = true;
      setState(() {
        final postIndex = _posts.indexWhere((post) => post.id == postId);
        if (postIndex != -1) {
          _posts[postIndex] = _posts[postIndex].copyWith(
            likesCount: _posts[postIndex].likesCount + 1
          );
        }
      });
      
      // Show appreciation message for likes
      Get.snackbar(
        'Thanks for the Love!',
        'Your support means a lot to the community.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.accent.withOpacity(0.1),
        colorText: Colors.pink[800],
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 2),
      );
    }
  }
  
  void _toggleSavePost(String postId) {
    setState(() {
      _savedPosts[postId] = !(_savedPosts[postId] ?? false);
    });
    
    // Show confirmation for saved/unsaved
    Get.snackbar(
      _savedPosts[postId]! ? 'Post Saved' : 'Post Unsaved',
      _savedPosts[postId]! 
        ? 'You can find this post in your saved collection.'
        : 'This post has been removed from your saved collection.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: _savedPosts[postId]! ? AppColors.info.withOpacity(0.1) : Colors.grey[200],
      colorText: _savedPosts[postId]! ? AppColors.info : Colors.grey[800],
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
    );
  }
  
  void _openPostThread(CommunityPost post) {
    Get.to(() => PostThreadPage(post: post));
  }
  
  // New method to delete your own post
  void _deletePost(CommunityPost post) {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _posts.removeWhere((p) => p.id == post.id);
              });
              
              Get.snackbar(
                'Post Deleted',
                'Your post has been removed.',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.grey[100],
                colorText: Colors.grey[800],
                margin: const EdgeInsets.all(16),
                borderRadius: 8,
                duration: const Duration(seconds: 2),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
  
  // Moderator action to delete any post
  void _deletePostAsModerator(CommunityPost post) {
    // Show confirmation dialog with reason field
    showDialog(
      context: context,
      builder: (context) {
        final reasonController = TextEditingController();
        
        return AlertDialog(
          title: const Text('Delete Post as Moderator'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('This action cannot be undone.'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for deletion',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _posts.removeWhere((p) => p.id == post.id);
                });
                
                Get.snackbar(
                  'Moderator Action',
                  'Post by ${post.username} has been removed',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.orange[100],
                  colorText: Colors.orange[900],
                  margin: const EdgeInsets.all(16),
                  borderRadius: 8,
                  duration: const Duration(seconds: 2),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('DELETE'),
            ),
          ],
        );
      },
    );
  }
  
  // Moderator action to ban a user
  void _banUser(String username) {
    // Show confirmation dialog with reason field
    showDialog(
      context: context,
      builder: (context) {
        final reasonController = TextEditingController();
        
        return AlertDialog(
          title: const Text('Ban User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Ban $username from posting in the community?'),
              const SizedBox(height: 16),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason for ban',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('CANCEL'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _bannedUsers.add(username);
                });
                
                Get.snackbar(
                  'Moderator Action',
                  'User $username has been banned',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red[100],
                  colorText: Colors.red[900],
                  margin: const EdgeInsets.all(16),
                  borderRadius: 8,
                  duration: const Duration(seconds: 2),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('BAN USER'),
            ),
          ],
        );
      },
    );
  }
  
  // Moderator action to unban a user
  void _unbanUser(String username) {
    setState(() {
      _bannedUsers.remove(username);
    });
    
    Get.snackbar(
      'Moderator Action',
      'User $username has been unbanned',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green[100],
      colorText: Colors.green[900],
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
    );
  }

  // Add a new method to handle post reporting
  void _reportPost(CommunityPost post) {
    // Show report dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Post'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Why are you reporting this post?'),
            const SizedBox(height: 16),
            _buildReportOption('Inappropriate content'),
            _buildReportOption('Harassment or bullying'),
            _buildReportOption('False information'),
            _buildReportOption('Spam'),
            _buildReportOption('Something else'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
        ],
      ),
    );
  }

  // Helper method to build report options
  Widget _buildReportOption(String reason) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop(); // Close dialog
        
        // Show confirmation
        Get.snackbar(
          'Report submitted',
          'Thank you for helping keep our community safe. We\'ll review this post.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.info.withOpacity(0.1),
          colorText: AppColors.info,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 3),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(Icons.radio_button_unchecked, size: 18, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(reason),
          ],
        ),
      ),
    );
  }

  // Add a new method to handle posting
  void _handlePost(String content) {
    if (content.isNotEmpty) {
      setState(() {
        _posts.insert(0, CommunityPost(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          username: 'You',
          content: content,
          timeAgo: 'Just now',
          likesCount: 0,
          commentsCount: 0,
          comments: [],
        ));
        _postController.clear();
      });
      
      // Show success message
      Get.snackbar(
        'Success',
        'Your post has been shared with the community!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withOpacity(0.1),
        colorText: AppColors.success,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Community header with tabs
          Container(
            color: AppColors.white,
            child: Column(
              children: [
                // App bar with title and moderator access if applicable
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Community",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Moderator dashboard button (only visible for moderators)
                      if (widget.isModerator)
                        ElevatedButton.icon(
                          onPressed: () {
                            Get.to(() => const ModeratorDashboard());
                          },
                          icon: const Icon(Icons.admin_panel_settings),
                          label: const Text('Mod Panel'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: AppColors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          ),
                        ),
                    ],
                  ),
                ),
                
                // Tab bar
                TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: AppColors.primary,
                  tabs: const [
                    Tab(text: "Threads"),
                    Tab(text: "Sereine Team"),
                    Tab(text: "Seremate"),
                  ],
                ),
              ],
            ),
          ),
          
          // Tab content - Using the separate tab files
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Threads Tab
                CommunityThreadsTab(
                  postController: _postController,
                  likedPosts: _likedPosts,
                  savedPosts: _savedPosts,
                  posts: _posts,
                  currentUser: currentUser,
                  bannedUsers: _bannedUsers,
                  isModerator: widget.isModerator,
                  handleLike: _handleLike,
                  toggleSavePost: _toggleSavePost,
                  openPostThread: _openPostThread,
                  deletePost: _deletePost,
                  deletePostAsModerator: _deletePostAsModerator,
                  banUser: _banUser,
                  unbanUser: _unbanUser,
                  reportPost: _reportPost,
                  handlePost: _handlePost, // Add this parameter
                ),
                
                // Sereine Team Tab
                CommunitySeireineTeamTab(
                  saTeamMembers: _saTeamMembers,
                ),
                
                // Seremate Tab
                const CommunitySeremateTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
