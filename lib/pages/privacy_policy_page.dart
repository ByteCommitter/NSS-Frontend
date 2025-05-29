import 'package:flutter/material.dart';
import 'package:mentalsustainability/theme/app_colors.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.privacy_tip,
                      color: AppColors.primary,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Privacy Policy',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Last updated: ${DateTime.now().year}',
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
              ),
              
              const SizedBox(height: 24),
              
              // Information Collection
              _buildSection(
                title: '1. Information We Collect',
                content: [
                  'Personal Information: We collect your university ID, name, and email address when you register for the NSS app.',
                  'Activity Data: We track your participation in NSS events and activities to calculate points and achievements.',
                  'Usage Data: We collect information about how you use the app to improve our services.',
                ],
              ),
              
              // How We Use Information
              _buildSection(
                title: '2. How We Use Your Information',
                content: [
                  'To provide and maintain the NSS app services',
                  'To track your participation in NSS activities and events',
                  'To calculate and display your achievement points and badges',
                  'To communicate with you about NSS events and activities',
                  'To improve our app and services',
                ],
              ),
              
              // Information Sharing
              _buildSection(
                title: '3. Information Sharing',
                content: [
                  'We do not sell, trade, or otherwise transfer your personal information to third parties.',
                  'We may share anonymized data for research and improvement purposes.',
                  'Your participation records may be shared with NSS coordinators for verification purposes.',
                  'We may disclose information if required by law or to protect our rights.',
                ],
              ),
              
              // Data Security
              _buildSection(
                title: '4. Data Security',
                content: [
                  'We implement appropriate security measures to protect your personal information.',
                  'Your data is stored securely on our servers with encryption.',
                  'We regularly review our security practices to ensure data protection.',
                  'However, no method of transmission over the internet is 100% secure.',
                ],
              ),
              
              // Your Rights
              _buildSection(
                title: '5. Your Rights',
                content: [
                  'You have the right to access your personal data stored in the app.',
                  'You can request correction of inaccurate personal information.',
                  'You can request deletion of your account and associated data.',
                  'You can opt out of non-essential communications.',
                ],
              ),
              
              // Data Retention
              _buildSection(
                title: '6. Data Retention',
                content: [
                  'We retain your personal information for as long as your account is active.',
                  'Participation records may be retained for historical and verification purposes.',
                  'You can request deletion of your data at any time by contacting us.',
                ],
              ),
              
              // Children\'s Privacy
              _buildSection(
                title: '7. Children\'s Privacy',
                content: [
                  'Our app is designed for college students and is not intended for children under 13.',
                  'We do not knowingly collect personal information from children under 13.',
                  'If we become aware of such collection, we will take steps to delete the information.',
                ],
              ),
              
              // Changes to Privacy Policy
              _buildSection(
                title: '8. Changes to This Privacy Policy',
                content: [
                  'We may update this privacy policy from time to time.',
                  'We will notify you of any changes by posting the new policy in the app.',
                  'Changes are effective immediately upon posting.',
                ],
              ),
              
              // Contact Information
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.info.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.info.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.contact_support,
                          color: AppColors.info,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Contact Us',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.info,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'If you have any questions about this Privacy Policy, please contact us at:',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Email: nss@hyderabad.bits-pilani.ac.in',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Text(
                      'Website: www.nssbphc.com',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSection({
    required String title,
    required List<String> content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          ...content.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
          )).toList(),
        ],
      ),
    );
  }
}
