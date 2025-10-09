import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class PosterHelpPage extends StatelessWidget {
  const PosterHelpPage({super.key});

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: 'support@quickhire.com',
      query: 'subject=QuickHire Support Request',
    );

    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '+265888123456');

    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 45, 114, 1.0),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromRGBO(0, 45, 114, 1.0),
        toolbarHeight: 100,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Help & Support',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(00)),
        ),
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // Contact Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Us',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildContactItem(
                    icon: Icons.email_outlined,
                    title: 'Email Support',
                    subtitle: 'support@quickhire.com',
                    onTap: _launchEmail,
                  ),
                  const Divider(height: 32),
                  _buildContactItem(
                    icon: Icons.phone_outlined,
                    title: 'Phone Support',
                    subtitle: '+265 888 123 456',
                    onTap: _launchPhone,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // FAQ Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Frequently Asked Questions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildFAQItem(
                    question: 'How do I post a job?',
                    answer:
                        'Tap the "Post a Job" button on your dashboard, fill in all the required details, and submit. Your job will be visible to seekers immediately.',
                  ),
                  const SizedBox(height: 16),
                  _buildFAQItem(
                    question: 'How do I manage applicants?',
                    answer:
                        'Go to "My Jobs", select a job, and view all applicants. You can accept or deny applications based on their profiles and experience.',
                  ),
                  const SizedBox(height: 16),
                  _buildFAQItem(
                    question: 'How do I update job details?',
                    answer:
                        'Open the job from "My Jobs" and tap the edit icon to modify the title, description, or payment details. Changes will be reflected immediately.',
                  ),
                  const SizedBox(height: 16),
                  _buildFAQItem(
                    question: 'How do I contact applicants?',
                    answer:
                        'Once an application is accepted, you can contact the seeker using the contact details provided in their application.',
                  ),
                  const SizedBox(height: 16),
                  _buildFAQItem(
                    question: 'Can I delete a job?',
                    answer:
                        'Yes, tap the delete icon on the job card. Deleting a job is permanent and will remove all related applications.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Tips Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(255, 193, 7, 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline,
                          size: 24,
                          color: Color.fromRGBO(255, 193, 7, 1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Tips for Posting Jobs',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTipItem('• Write clear and detailed job descriptions.'),
                  _buildTipItem('• Set realistic compensation and timelines.'),
                  _buildTipItem(
                    '• Review applicant profiles carefully before accepting.',
                  ),
                  _buildTipItem('• Respond promptly to accepted applicants.'),
                  _buildTipItem(
                    '• Keep your dashboard organized by managing jobs regularly.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // App Info
            Center(
              child: Column(
                children: [
                  Text(
                    'QuickHire v1.0.0',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© 2024 QuickHire. All rights reserved.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(0, 45, 114, 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: const Color.fromRGBO(0, 45, 114, 1.0),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem({required String question, required String answer}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          question,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          answer,
          style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4),
        ),
      ],
    );
  }

  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        tip,
        style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
      ),
    );
  }
}
