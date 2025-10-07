import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class SeekerHelpPage extends StatelessWidget {
  const SeekerHelpPage({super.key});

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
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
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
                    question: 'How do I apply for a job?',
                    answer:
                        'Browse available jobs on the home page, tap on a job card to view details, and click the "Apply" button to submit your application.',
                  ),
                  const SizedBox(height: 16),
                  _buildFAQItem(
                    question: 'How do I check my application status?',
                    answer:
                        'Go to your profile and tap "My Applications" to see all your submitted applications and their current status (Pending, Accepted, or Denied).',
                  ),
                  const SizedBox(height: 16),
                  _buildFAQItem(
                    question: 'Can I cancel my application?',
                    answer:
                        'Once submitted, applications cannot be cancelled. However, you can contact the job poster directly if needed.',
                  ),
                  const SizedBox(height: 16),
                  _buildFAQItem(
                    question: 'How do I update my profile?',
                    answer:
                        'Your profile information is set during registration. To update details, please contact support for assistance.',
                  ),
                  const SizedBox(height: 16),
                  _buildFAQItem(
                    question: 'What happens after my application is accepted?',
                    answer:
                        'You will receive a notification when your application is accepted. The job poster will have access to your contact information to reach out to you.',
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
                        'Tips for Success',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTipItem(
                    '• Make sure your profile information is accurate and up-to-date',
                  ),
                  _buildTipItem(
                    '• Apply to jobs that match your skills and experience',
                  ),
                  _buildTipItem(
                    '• Check your notifications regularly for application updates',
                  ),
                  _buildTipItem('• Be responsive when job posters contact you'),
                  _buildTipItem(
                    '• Read job descriptions carefully before applying',
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
