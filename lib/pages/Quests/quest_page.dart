import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/theme/app_colors.dart'; // Add theme import
import 'package:mentalsustainability/pages/Community/community_page.dart';

class QuestPage extends StatefulWidget {
  const QuestPage({super.key});

  @override
  State<QuestPage> createState() => _QuestPageState();
}

class _QuestPageState extends State<QuestPage> {
  // Controller for adding new quests
  final TextEditingController _questController = TextEditingController();
  
  // List of active quests
  final List<Quest> _activeQuests = [
    Quest(
      id: '1',
      title: 'Meditate for 10 minutes',
      description: 'Find a quiet place and practice mindfulness meditation',
      points: 50,
      isCompleted: false,
    ),
    Quest(
      id: '2',
      title: 'Take a nature walk',
      description: 'Spend at least 20 minutes walking outdoors',
      points: 40,
      isCompleted: false,
    ),
    Quest(
      id: '3',
      title: 'Journal your thoughts',
      description: 'Write down your feelings and reflections for the day',
      points: 30,
      isCompleted: false,
    ),
  ];
  
  // List of personalized quest suggestions
  final List<Quest> _personalizedQuests = [
    Quest(
      id: 'p1',
      title: 'Practice deep breathing exercises',
      description: 'Take 5 minutes to practice deep breathing techniques',
      points: 25,
      isCompleted: false,
      isSuggestion: true,
    ),
    Quest(
      id: 'p2',
      title: 'Reduce screen time before bed',
      description: 'Avoid screens for 30 minutes before sleeping',
      points: 35,
      isCompleted: false,
      isSuggestion: true,
    ),
    Quest(
      id: 'p3',
      title: 'Stay hydrated',
      description: 'Drink at least 8 glasses of water today',
      points: 20,
      isCompleted: false,
      isSuggestion: true,
    ),
  ];

  // Add a new quest to active quests
  void _addQuest(String title) {
    if (title.isNotEmpty) {
      setState(() {
        _activeQuests.add(
          Quest(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: title,
            description: 'User-added quest',
            points: 30, // Default points for user-added quests
            isCompleted: false,
          ),
        );
      });
      _questController.clear();
      
      // Show success message with solid background for better visibility
      Get.snackbar(
        'Quest Added',
        'Your quest has been added successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.success.withOpacity(0.1), // Use theme color
        colorText: AppColors.success, // Use theme color
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 3),
      );
    }
  }
  
  // Add suggested quest to active quests
  void _addSuggestedQuest(Quest quest) {
    setState(() {
      // Remove from suggestions
      _personalizedQuests.removeWhere((q) => q.id == quest.id);
      
      // Add to active quests (with a new ID to avoid confusion)
      _activeQuests.add(
        Quest(
          id: 'a${quest.id}',
          title: quest.title,
          description: quest.description,
          points: quest.points,
          isCompleted: false,
          isSuggestion: false,
        ),
      );
    });
    
    // Show success message with solid background
    Get.snackbar(
      'Quest Added',
      'The suggested quest has been added to your active quests!',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.success.withOpacity(0.1), // Use theme color
      colorText: AppColors.success, // Use theme color
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }
  
  // Delete a quest
  void _deleteQuest(String id) {
    setState(() {
      _activeQuests.removeWhere((quest) => quest.id == id);
    });
    
    // Show success message with solid background
    Get.snackbar(
      'Quest Deleted',
      'Quest has been removed from your list',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.error.withOpacity(0.1), // Use theme color
      colorText: AppColors.error, // Use theme color
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }
  
  // Verify a quest (mark as completed)
  void _verifyQuest(String id) {
    final questIndex = _activeQuests.indexWhere((quest) => quest.id == id);
    if (questIndex != -1) {
      final completedQuest = _activeQuests[questIndex];
      
      // Show dialog instead of directly navigating
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Quest Completed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Congratulations on completing "${completedQuest.title}"!'),
              const SizedBox(height: 8),
              const Text('Would you like to share your achievement with the community to verify and gain points?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Just mark as complete without sharing
                setState(() {
                  _activeQuests[questIndex] = _activeQuests[questIndex].copyWith(isCompleted: true);
                });
                Navigator.pop(context); // Close dialog
                
                Get.snackbar(
                  'Quest Completed',
                  'Well done! You\'ve earned 10 points!',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.info.withOpacity(0.1), // Use theme color
                  colorText: AppColors.info, // Use theme color
                  margin: const EdgeInsets.all(16),
                  borderRadius: 8,
                  duration: const Duration(seconds: 3),
                );
              },
              child: const Text('Just Complete'),
            ),
            ElevatedButton(  
              onPressed: () {
                // Mark as complete and share
                setState(() {
                  _activeQuests[questIndex] = _activeQuests[questIndex].copyWith(isCompleted: true);
                });
                Navigator.pop(context); // Close dialog
                
                // Navigate to community page to share accomplishment
                Get.to(() => CommunityPage(
                  prefilledPost: "I just completed the quest: ${completedQuest.title}! Share your thoughts and verify my achievement. 🎉",
                ));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, // Use theme color
                foregroundColor: AppColors.white, // Use theme color
              ),
              child: const Text('Share & Complete'),
            ),
          ],
        ),
      );
    }
  }

  // Show dialog to create a new quest
  void _showAddQuestDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Create New Quest',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: _questController,
          decoration: InputDecoration(
            hintText: 'Enter your quest title',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
            ),
            filled: true,
            fillColor: AppColors.cardBackground,
            contentPadding: const EdgeInsets.all(16),
          ),
          maxLines: 2,
          textCapitalization: TextCapitalization.sentences,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel', 
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _addQuest(_questController.text);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Add Quest'),
          ),
        ],
      ),
    );
  }
  
  // Show suggestions dialog
  void _showSuggestionsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.warning,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.warning.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.lightbulb,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Quest Suggestions',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: _personalizedQuests.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.notifications_off,
                        size: 60,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'No suggestions available',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Check back later for personalized quests!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: _personalizedQuests.length,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemBuilder: (context, index) {
                  final quest = _personalizedQuests[index];
                  
                  // Select a theme color based on quest type
                  Color themeColor = (quest.title.contains('Meditate') || 
                                   quest.title.contains('breathing'))
                    ? Colors.blue.shade700 
                    : (quest.title.contains('screen time'))
                      ? Colors.purple.shade600
                      : (quest.title.contains('hydrated') || 
                         quest.title.contains('water'))
                        ? Colors.cyan.shade600
                        : AppColors.primary;
                  
                  // Select appropriate icon based on quest content
                  IconData questIcon = Icons.lightbulb;
                  if (quest.title.toLowerCase().contains('breathing')) {
                    questIcon = Icons.self_improvement;
                  } else if (quest.title.toLowerCase().contains('screen time')) {
                    questIcon = Icons.devices;
                  } else if (quest.title.toLowerCase().contains('hydrated')) {
                    questIcon = Icons.water_drop;
                  }
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.white,
                      border: Border.all(
                        color: themeColor.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: themeColor.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Quest Icon with solid color (no gradient)
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: themeColor,
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: themeColor.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  questIcon,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              
                              // Quest details
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      quest.title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: themeColor,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      quest.description,
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: themeColor,
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.bolt,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${quest.points} points',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Add button section
                        Container(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(15.5),
                              bottomRight: Radius.circular(15.5),
                            ),
                          ),
                          padding: const EdgeInsets.all(12),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _addSuggestedQuest(quest);
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.add_circle_outline, size: 18),
                            label: const Text('Add to My Quests'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: themeColor,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
        ),
        actions: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[200],
                foregroundColor: AppColors.textSecondary,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _questController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Calculate progress of completed quests
    final int totalQuests = _activeQuests.length;
    final int completedQuests = _activeQuests.where((quest) => quest.isCompleted).length;
    final double progressPercentage = totalQuests > 0 ? completedQuests / totalQuests : 0.0;
    
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0), // Reduced bottom padding here
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header section with progress
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'My Quests',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Progress text and bar
                      Row(
                        children: [
                          Text(
                            '$completedQuests of $totalQuests completed',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${(progressPercentage * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Suggestions button - replaces the large box at the bottom
                OutlinedButton.icon(
                  onPressed: _showSuggestionsDialog,
                  icon: Icon(Icons.lightbulb_outline, color: AppColors.warning),
                  label: const Text("View Suggestions"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Progress bar
            LinearProgressIndicator(
              value: progressPercentage,
              backgroundColor: AppColors.cardBackground,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            
            const SizedBox(height: 16),
            
            // List of active quests
            Expanded(
              child: _activeQuests.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.hourglass_empty, 
                          size: 64, 
                          color: AppColors.textSecondary.withOpacity(0.5)
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'No active quests yet',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add a new quest using the + button\nor check out our suggestions',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                        const SizedBox(height: 32),
                        OutlinedButton.icon(
                          onPressed: _showSuggestionsDialog,
                          icon: Icon(Icons.lightbulb_outline, color: AppColors.warning),
                          label: const Text("Browse Quest Suggestions"),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.primary,
                            side: BorderSide(color: AppColors.primary),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _activeQuests.length,
                    padding: const EdgeInsets.only(bottom: 8),
                    itemBuilder: (context, index) {
                      final quest = _activeQuests[index];
                      return _buildQuestCard(
                        quest,
                        onVerify: () => _verifyQuest(quest.id),
                        onDelete: () => _deleteQuest(quest.id),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
      
      // Position floating action button to avoid bottom nav bar
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 16), // Add extra bottom padding to float above nav bar
        child: FloatingActionButton(
          onPressed: _showAddQuestDialog,
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          tooltip: 'Create New Quest',
          elevation: 5, // Increased elevation for better visibility
          child: const Icon(Icons.add),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // Build a quest card for active quests
  Widget _buildQuestCard(Quest quest, {required Function onVerify, required Function onDelete}) {
    // Select a theme color based on quest type or completion status
    Color themeColor = quest.isCompleted 
        ? AppColors.success 
        : (quest.title.contains('Meditate') || quest.title.contains('Journal') || quest.title.contains('breathing'))
          ? Colors.blue.shade700 
          : (quest.title.contains('nature') || quest.title.contains('walk') || quest.title.contains('hydrated'))
            ? Colors.green.shade600
            : AppColors.primary;
            
    Color backgroundColor = quest.isCompleted
        ? AppColors.cardBackground
        : AppColors.white;
        
    // Icon selection based on quest content
    IconData questIcon = Icons.task_alt;
    if (quest.title.toLowerCase().contains('meditate') || quest.title.toLowerCase().contains('breathing')) {
      questIcon = Icons.self_improvement;
    } else if (quest.title.toLowerCase().contains('walk') || quest.title.toLowerCase().contains('nature')) {
      questIcon = Icons.park;
    } else if (quest.title.toLowerCase().contains('journal') || quest.title.toLowerCase().contains('write')) {
      questIcon = Icons.edit_note;
    } else if (quest.title.toLowerCase().contains('hydrated') || quest.title.toLowerCase().contains('water')) {
      questIcon = Icons.water_drop;
    } else if (quest.title.toLowerCase().contains('screen time')) {
      questIcon = Icons.devices;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: quest.isCompleted ? AppColors.cardBackground : Colors.white,
          boxShadow: quest.isCompleted
              ? []
              : [
                  BoxShadow(
                    color: themeColor.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
          border: Border.all(
            color: quest.isCompleted
                ? Colors.grey.shade300
                : themeColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top part with icon and title
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: quest.isCompleted
                    ? Colors.grey.shade50
                    : themeColor.withOpacity(0.08),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14.5),
                  topRight: Radius.circular(14.5),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quest Icon with solid color (no gradient)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: themeColor,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: quest.isCompleted
                          ? []
                          : [
                              BoxShadow(
                                color: themeColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                    ),
                    child: Icon(
                      questIcon,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Quest details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quest.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            decoration: quest.isCompleted ? TextDecoration.lineThrough : null,
                            color: quest.isCompleted ? AppColors.textSecondary : themeColor,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          quest.description,
                          style: TextStyle(
                            color: quest.isCompleted ? AppColors.textSecondary : AppColors.textPrimary,
                            fontSize: 14,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            // Points badge with solid color (no gradient)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: themeColor,
                                borderRadius: BorderRadius.circular(30),
                                boxShadow: quest.isCompleted
                                    ? []
                                    : [
                                        BoxShadow(
                                          color: themeColor.withOpacity(0.2),
                                          blurRadius: 4,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.bolt,
                                    color: Colors.white,
                                    size: 14,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${quest.points} points',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Completed badge (text only version)
                            if (quest.isCompleted)
                              Container(
                                margin: const EdgeInsets.only(left: 12),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.check_circle_outline, 
                                      size: 14, 
                                      color: AppColors.success,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Completed',
                                      style: TextStyle(
                                        color: AppColors.success,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Current date or completion date indicator
                              const Spacer(),
                              if (quest.isCompleted)
                                Text(
                                  'Today',
                                  style: TextStyle(
                                    color: AppColors.success,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Action buttons with animated hover effect
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(14.5),
                  bottomRight: Radius.circular(14.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Complete button (renamed from Verify) - styled like Remove button but with green text
                  if (!quest.isCompleted)
                    OutlinedButton.icon(
                      onPressed: () => onVerify(),
                      icon: Icon(Icons.check_circle, size: 18, color: AppColors.success),
                      label: Text('Complete', style: TextStyle(color: AppColors.success)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.success,
                        side: BorderSide(color: AppColors.success.withOpacity(0.5)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                    
                  const SizedBox(width: 12),
                  
                  // Delete button
                  OutlinedButton.icon(
                    onPressed: () => onDelete(),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Remove'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: BorderSide(color: AppColors.error.withOpacity(0.5)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Quest model
class Quest {
  final String id;
  final String title;
  final String description;
  final int points;
  final bool isCompleted;
  final bool isSuggestion;

  Quest({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.isCompleted,
    this.isSuggestion = false,
  });

  // Copy with method to create new instances with modified properties
  Quest copyWith({
    String? id,
    String? title,
    String? description,
    int? points,
    bool? isCompleted,
    bool? isSuggestion,
  }) {
    return Quest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      points: points ?? this.points,
      isCompleted: isCompleted ?? this.isCompleted,
      isSuggestion: isSuggestion ?? this.isSuggestion,
    );
  }
}