import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mentalsustainability/theme/app_colors.dart';

class GuidePage extends StatelessWidget {
  const GuidePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '📘 App Guide',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.primary),
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
            icon: Icons.navigation,
            content: _buildTabInformation(),
          ),

          _buildSection(
            title: 'NSS Events & Participation',
            icon: Icons.event,
            content: _buildEventsExplanation(),
          ),

          _buildSection(
            title: 'Becoming a Volunteer',
            icon: Icons.volunteer_activism,
            content: _buildVolunteerExplanation(),
          ),

          _buildSection(
            title: 'Points & Achievements',
            icon: Icons.emoji_events,
            content: _buildPointsExplanation(),
          ),

          _buildSection(
            title: 'Community Features',
            icon: Icons.people,
            content: _buildCommunityExplanation(),
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
          'Welcome to NSS App',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'National Service Scheme - "Not Me But You"',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'This guide will help you navigate the app and understand how to participate in NSS activities.',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.primary.withOpacity(0.1),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'To participate in NSS events, you need to register as a volunteer first',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary,
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
            Icon(icon, color: AppColors.primary),
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
        collapsedBackgroundColor: AppColors.cardBackground,
        backgroundColor: AppColors.primary.withOpacity(0.05),
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
          description:
              'View upcoming NSS events, register for events, and see recent announcements from the NSS team.',
        ),
        const Divider(),
        _buildFeatureItem(
          icon: Icons.dashboard,
          title: 'Dashboard Tab',
          description:
              'Track your participation points, view your achievements, see leaderboard of top volunteers, and monitor your NSS journey.',
        ),
        const Divider(),
        _buildFeatureItem(
          icon: Icons.people,
          title: 'Community Tab',
          description:
              'Access mental health support features including anonymous teams, finding counselors, and connecting with potential seremates for student wellbeing.',
        ),
        const Divider(),
        _buildFeatureItem(
          icon: Icons.person,
          title: 'Profile Tab',
          description:
              'Manage your volunteer status, view your achievements and statistics, and register as a volunteer.',
        ),
      ],
    );
  }

  Widget _buildEventsExplanation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'NSS organizes various community service events throughout the academic year. Here\'s how to participate:',
          style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        _buildNumberedStep(
          number: 1,
          text: 'Browse upcoming events on the Home tab',
        ),
        _buildNumberedStep(
          number: 2,
          text: 'Register as a volunteer (required for event participation)',
        ),
        _buildNumberedStep(
          number: 3,
          text: 'Register for specific events you want to attend',
        ),
        _buildNumberedStep(
          number: 4,
          text: 'Attend the event and participate actively',
        ),
        _buildNumberedStep(
          number: 5,
          text: 'Your participation will be verified by event coordinators',
        ),
        _buildNumberedStep(
          number: 6,
          text: 'Earn points and achievements based on your participation',
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.info.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Types of NSS Events:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                _buildBulletPoint('Community service projects'),
                _buildBulletPoint('Educational workshops'),
                _buildBulletPoint('Environmental conservation activities'),
                _buildBulletPoint('Health and hygiene campaigns'),
                _buildBulletPoint('Rural development programs'),
                _buildBulletPoint('Social awareness drives'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVolunteerExplanation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'To participate in NSS events, you must first register as a volunteer. Here\'s the process:',
          style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        const Text(
          'How to Register as a Volunteer:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 12),
        _buildNumberedStep(
          number: 1,
          text: 'Go to your Profile tab',
        ),
        _buildNumberedStep(
          number: 2,
          text: 'Click on "Register as Volunteer" button',
        ),
        _buildNumberedStep(
          number: 3,
          text: 'Your application will be submitted for review',
        ),
        _buildNumberedStep(
          number: 4,
          text: 'Wait for admin approval (status will show as "Pending")',
        ),
        _buildNumberedStep(
          number: 5,
          text: 'Once approved, you can register for and participate in events',
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.success.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success),
                    const SizedBox(width: 8),
                    const Text(
                      'Volunteer Benefits:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildBulletPoint('Access to all NSS events'),
                _buildBulletPoint('Earn points for participation'),
                _buildBulletPoint('Get special volunteer achievements'),
                _buildBulletPoint('Contribute to community development'),
                _buildBulletPoint('Develop leadership skills'),
                _buildBulletPoint('NSS certificate upon completion'),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPointsExplanation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The NSS app uses a points system to track and reward your participation in various activities.',
          style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        _buildFeatureItem(
          icon: Icons.stars,
          title: 'Earning Points',
          description:
              'Participate in NSS events to earn points. Points are awarded after your participation is verified by event coordinators.',
        ),
        const Divider(),
        _buildFeatureItem(
          icon: Icons.emoji_events,
          title: 'Achievement Badges',
          description:
              'Unlock various badges based on your point milestones: Bronze Starter (50+ pts), Silver Achiever (200+ pts), Gold Star (500+ pts), and more.',
        ),
        const Divider(),
        _buildFeatureItem(
          icon: Icons.leaderboard,
          title: 'Leaderboard',
          description:
              'See how you rank among other volunteers in the dashboard. Top contributors are recognized for their service.',
        ),
        const Divider(),
        _buildFeatureItem(
          icon: Icons.volunteer_activism,
          title: 'Volunteer Badge',
          description:
              'Get a special NSS Volunteer badge once your volunteer application is approved.',
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
                    'Points and achievements are updated within 24 hours after event participation is verified.',
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

  Widget _buildCommunityExplanation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'The Community tab focuses on mental health and student wellbeing support through various features.',
          style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.info.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Community Features:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                _buildBulletPoint(
                    'Anonymous Teams - Connect with peers for support'),
                _buildBulletPoint(
                    'Seremate Matching - Find compatible study/life partners'),
                _buildBulletPoint(
                    'Mental Health Resources - Access counseling services'),
                _buildBulletPoint(
                    'Student Wellbeing Support - Campus mental health initiatives'),
                _buildBulletPoint(
                    'Anonymous Communication - Safe space for sharing'),
                _buildBulletPoint(
                    'Peer Support Networks - Connect with like-minded students'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(12),
            color: AppColors.success.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.psychology, color: AppColors.success),
                    const SizedBox(width: 8),
                    const Text(
                      'Mental Health Focus:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _buildBulletPoint('Anonymous support for sensitive topics'),
                _buildBulletPoint('Professional counselor connections'),
                _buildBulletPoint('Peer-to-peer mental health support'),
                _buildBulletPoint('Safe and confidential environment'),
                _buildBulletPoint('Campus-wide wellness initiatives'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'These features help create a supportive campus environment where students can find help, connect with peers, and access mental health resources in a safe and anonymous way.',
          style: TextStyle(
            fontSize: 14,
            fontStyle: FontStyle.italic,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildContactSupport() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.support_agent, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  'Need Help?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'If you have questions about NSS activities, volunteer registration, or need technical support with the app, contact us:',
              style: TextStyle(fontSize: 15, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.email),
                    label: const Text('Email Support'),
                    onPressed: () {
                      Get.snackbar(
                        'Contact NSS',
                        'Email: nss@hyderabad.bits-pilani.ac.in',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.primary.withOpacity(0.1),
                        colorText: AppColors.primary,
                        duration: const Duration(seconds: 4),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.language),
                    label: const Text('Visit Website'),
                    onPressed: () {
                      Get.snackbar(
                        'NSS Website',
                        'Visit: www.nssbphc.in',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: AppColors.info.withOpacity(0.1),
                        colorText: AppColors.info,
                        duration: const Duration(seconds: 4),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.info,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
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
          Icon(icon, color: AppColors.primary, size: 20),
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
                    color: AppColors.textSecondary,
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
              color: AppColors.primary,
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
              color: AppColors.primary,
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
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
