import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/theme/app_colors.dart'; // Add theme import

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '🧭 App Guide',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary, // Use theme color
          ),
        ),
        backgroundColor: AppColors.background, // Use theme color
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary), // Use theme color
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Introduction
          _buildHeader(),
          const SizedBox(height: 24),
          
          // App Features
          _buildSection(
            title: 'App Navigation',
            icon: Icons.tablet_android,
            content: _buildTabInformation(),
          ),
          
          _buildSection(
            title: 'Seremate Explained',
            icon: Icons.people,
            content: _buildSeremateExplanation(),
          ),
          
          _buildSection(
            title: 'Connecting with Sereine Team',
            icon: Icons.support_agent,
            content: _buildSATeamExplanation(),
          ),
          
          _buildSection(
            title: 'Privacy & Anonymity',
            icon: Icons.privacy_tip,
            content: _buildPrivacyInformation(),
          ),
          
          _buildSection(
            title: 'Achievements & Points',
            icon: Icons.emoji_events,
            content: _buildGamificationExplanation(),
          ),
          
          // Contact support
          const SizedBox(height: 24),
          _buildContactSupport(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome to Sereine',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary, // Use theme color
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This guide will help you navigate the app and make the most of its features.',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary, // Use theme color
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.primary.withOpacity(0.1), // Use theme color
            child: Row(
              children: [
                Icon(
                  Icons.tips_and_updates,
                  color: AppColors.primary, // Use theme color
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tap on any section below to learn more about that feature',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: AppColors.primary, // Use theme color
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget content,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Icon(icon, color: AppColors.primary), // Use theme color
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        collapsedBackgroundColor: AppColors.cardBackground, // Use theme color
        backgroundColor: AppColors.primary.withOpacity(0.05), // Use theme color
        childrenPadding: const EdgeInsets.all(16),
        children: [content],
      ),
    );
  }

  Widget _buildTabInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFeatureItem(
          icon: Icons.home,
          title: 'Home Tab',
          description: 'Your dashboard for daily wellness activities, mood tracking, and personalized recommendations.',
        ),
        const Divider(),
        _buildFeatureItem(
          icon: Icons.assignment,
          title: 'Quests Tab',
          description: 'Complete challenges to improve your mental health and sustainability habits, earning points and badges.',
        ),
        const Divider(),
        _buildFeatureItem(
          icon: Icons.people,
          title: 'Community Tab',
          description: 'Connect with peers through discussion threads, chat with support team members, or find activities with fellow students via Seremate.',
        ),
        const Divider(),
        _buildFeatureItem(
          icon: Icons.person,
          title: 'Profile Tab',
          description: 'View your achievements, statistics, and customize your personal preferences.',
        ),
      ],
    );
  }

  Widget _buildSeremateExplanation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Seremate connects you with fellow students who share similar interests or are looking for companions for various activities.',
          style: TextStyle(fontSize: 15, color: AppColors.textPrimary), // Use theme color
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.info.withOpacity(0.1), // Use theme color
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Available Activities:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                _buildBulletPoint('Have casual conversations with peers'),
                _buildBulletPoint('Find walking buddies around campus'),
                _buildBulletPoint('Share meals with fellow students'),
                _buildBulletPoint('Form study groups in the library'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Your identity remains anonymous until you choose to share more information with your matched peers.',
          style: TextStyle(fontSize: 15, color: AppColors.textPrimary), // Use theme color
        ),
      ],
    );
  }

  Widget _buildSATeamExplanation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The Sereine Team consists of trained peer supporters who can help with various challenges you might face.',
          style: TextStyle(fontSize: 15, color: AppColors.textPrimary), // Use theme color
        ),
        const SizedBox(height: 16),
        const Text(
          'How to Connect:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 8),
        _buildNumberedStep(
          number: 1,
          text: 'Go to the Community tab',
        ),
        _buildNumberedStep(
          number: 2,
          text: 'Select the "Sereine Team" section',
        ),
        _buildNumberedStep(
          number: 3,
          text: 'Browse the Human Library and click on a support team member who specializes in your area of concern',
        ),
        _buildNumberedStep(
          number: 4,
          text: 'Start a chat session - all conversations are confidential',
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.primary.withOpacity(0.1), // Use theme color
            child: Row(
              children: [
                Icon(Icons.lightbulb, color: AppColors.warning), // Use theme color
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Team members have expertise in areas like anxiety, academic pressure, grief, relationships, and more.',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your privacy is our priority. Sereine is designed to provide support while protecting your personal information.',
          style: TextStyle(fontSize: 15, color: AppColors.textPrimary), // Use theme color
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(
          icon: Icons.person_outline,
          title: 'Anonymous Username',
          description: 'You can use any username without revealing your real identity.',
        ),
        const Divider(),
        _buildFeatureItem(
          icon: Icons.chat_bubble_outline,
          title: 'Confidential Chats',
          description: 'Conversations with the Sereine Team and Seremate peers are confidential.',
        ),
        const Divider(),
        _buildFeatureItem(
          icon: Icons.settings_outlined,
          title: 'Privacy Controls',
          description: 'Control what information is shared with the community through your profile settings.',
        ),
        const Divider(),
        _buildFeatureItem(
          icon: Icons.delete_outline,
          title: 'Data Management',
          description: 'You can delete your account and associated data at any time through settings.',
        ),
      ],
    );
  }

  Widget _buildGamificationExplanation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sereine uses gamification to make your wellness journey more engaging and rewarding.',
          style: TextStyle(fontSize: 15, color: AppColors.textPrimary), // Use theme color
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(
          icon: Icons.stars,
          title: 'Points',
          description: 'Earn points by completing quests, engaging with the community, and tracking your daily habits.',
        ),
        const Divider(),
        _buildFeatureItem(
          icon: Icons.emoji_events,
          title: 'Achievements',
          description: 'Unlock badges as you hit milestones in your wellness journey, like meditation streaks or sustainability goals.',
        ),
        const Divider(),
        _buildFeatureItem(
          icon: Icons.leaderboard,
          title: 'Progress Tracking',
          description: 'Monitor your growth and development through visual progress indicators on your profile.',
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            color: Colors.amber.withOpacity(0.1),
            child: const Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Achievement levels increase as you continue to engage with different aspects of wellness and sustainability!',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactSupport() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.primary.withOpacity(0.3)), // Use theme color
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.support_agent, color: AppColors.primary), // Use theme color
                const SizedBox(width: 12),
                Text(
                  'Still Need Help?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary, // Use theme color
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'If you have any questions or need assistance navigating the app, our support team is here to help.',
              style: TextStyle(fontSize: 15, color: AppColors.textPrimary), // Use theme color
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.email),
              label: const Text('Contact Support'),
              onPressed: () {
                // TODO: Implement contact support functionality
                Get.snackbar(
                  'Contact Support',
                  'Support email: support@sereine.app',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: AppColors.primary.withOpacity(0.1), // Use theme color
                  colorText: AppColors.primary, // Use theme color
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, // Use theme color
                foregroundColor: AppColors.white, // Use theme color
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 20), // Use theme color
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary, // Use theme color
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•  ',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: AppColors.info, // Use theme color
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberedStep({required int number, required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: AppColors.primary, // Use theme color
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary, // Use theme color
              ),
            ),
          ),
        ],
      ),
    );
  }
}
