import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/theme/app_colors.dart';

class CommunitySeremateTab extends StatelessWidget {
  const CommunitySeremateTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Header with info button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Connect with Fellow Students",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            IconButton(
              icon: Icon(Icons.info_outline, color: AppColors.primary),
              onPressed: () => _showSeremateInfoDialog(context),
              tooltip: "About Seremate",
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        // Activity-based connection options
        const Text(
          "How would you like to connect?",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // Grid of activity cards
        GridView.count(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.85,
          children: [
            _buildActivityCard(
              "Let's Chat",
              "Have a casual conversation about anything",
              Icons.chat_bubble_outline,
              Colors.blue,
            ),
            _buildActivityCard(
              "Go for a Walk",
              "Find a walking buddy around campus",
              Icons.directions_walk,
              Colors.green,
            ),
            _buildActivityCard(
              "Meal Together",
              "Share a meal at the cafeteria or nearby",
              Icons.restaurant,
              Colors.orange,
            ),
            _buildActivityCard(
              "Study Session",
              "Find someone to study with in the library",
              Icons.book,
              Colors.purple,
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Active Seremates - modified to show ongoing connections
        const Text(
          "Your Active Connections",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        // Sample connection in progress
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.teal.withOpacity(0.2),
                      child: const Text(
                        "A",
                        style: TextStyle(
                          color: Colors.teal,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "BlueMango",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "Studying: Computer Science",
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.circle, size: 8, color: Colors.green[700]),
                          const SizedBox(width: 4),
                          Text(
                            "Online",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.restaurant, size: 16, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    const Text(
                      "Lunch at University Cafeteria",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    const Text(
                      "Today at 1:00 PM",
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.chat_bubble_outline, size: 16),
                      label: const Text("Chat"),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.deepPurple,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        Get.snackbar(
                          'Meeting Confirmed',
                          'Your meetup has been confirmed. Enjoy!',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: Colors.green[100],
                          colorText: Colors.green[800],
                          margin: const EdgeInsets.all(16),
                          borderRadius: 8,
                          duration: const Duration(seconds: 3),
                        );
                      },
                      icon: const Icon(Icons.check_circle, size: 16),
                      label: const Text("Confirm Meeting"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        
        // Placeholder for when no active connections
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(Icons.people_outline, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                "No other active connections",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Try joining an activity to meet more students",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // User preferences section - MOVED HERE as requested
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Your Connection Preferences",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Available times
                const Text(
                  "I'm usually available:",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildTimeChip("Mornings", false),
                    _buildTimeChip("Afternoons", true),
                    _buildTimeChip("Evenings", true),
                    _buildTimeChip("Weekends", true),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Conversation topics
                const Text(
                  "Topics I enjoy discussing:",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildInterestChip("Movies & TV", Colors.indigo),
                    _buildInterestChip("Music", Colors.pink),
                    _buildInterestChip("Sports", Colors.amber),
                    _buildInterestChip("Technology", Colors.blue),
                    _buildInterestChip("Art", Colors.teal),
                    _buildInterestChip("+ Add more", Colors.grey),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                // Update preferences button
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.snackbar(
                        'Preferences Updated',
                        'Your connection preferences have been saved',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green[100],
                        colorText: Colors.green[800],
                        margin: const EdgeInsets.all(16),
                        borderRadius: 8,
                        duration: const Duration(seconds: 2),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                    child: const Text('Update Preferences'),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Safety tips footer with added report button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.05),
            border: Border.all(color: Colors.blue.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.shield, color: Colors.blue[700], size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        "Safety Tips",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  // ADDED Report button
                  TextButton.icon(
                    onPressed: () {
                      Get.snackbar(
                        'Report Concern',
                        'Thank you for helping keep our community safe. We\'ll review your report promptly.',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red[100],
                        colorText: Colors.red[800],
                        margin: const EdgeInsets.all(16),
                        borderRadius: 8,
                        duration: const Duration(seconds: 3),
                      );
                    },
                    icon: const Icon(Icons.flag, size: 16),
                    label: const Text("Report Concern"),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.red[700],
                      backgroundColor: Colors.red[50],
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                "• Always meet in public, campus locations during daytime",
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 4),
              const Text(
                "• Share your meetup details with a trusted friend",
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 4),
              const Text(
                "• Report any concerns through the app immediately",
                style: TextStyle(fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Show information dialog about Seremate
  void _showSeremateInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  "Finding connection in a sea of people",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Description
                const Text(
                  "Many students feel lonely despite being surrounded by others. Seremate helps you connect anonymously with fellow students for walks, meals, study sessions, or just conversations.",
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                
                // Benefits
                Row(
                  children: [
                    Icon(Icons.check_circle, 
                      size: 16, 
                      color: Colors.green[700]
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Start anonymously, share contact info only when comfortable",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.check_circle, 
                      size: 16, 
                      color: Colors.green[700]
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Connect based on activities and shared interests",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.check_circle, 
                      size: 16, 
                      color: Colors.green[700]
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        "Meet in safe campus locations for peace of mind",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Close button
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                    child: const Text("Got it"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method for building activity cards
  Widget _buildActivityCard(String title, String description, IconData icon, Color color) {
    return GestureDetector(
      onTap: () {
        Get.snackbar(
          'Looking for Matches',
          'We\'ll notify you when we find someone for: $title',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: color.withOpacity(0.1),
          colorText: color,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 3),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method for building time preference chips
  Widget _buildTimeChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {},
      backgroundColor: Colors.grey[100],
      selectedColor: AppColors.primary.withOpacity(0.15),
      checkmarkColor: AppColors.primary,
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : Colors.grey[800],
        fontSize: 12,
      ),
    );
  }

  // Helper method for building interest chips
  Widget _buildInterestChip(String label, Color color) {
    return Chip(
      label: Text(label),
      labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }
}
