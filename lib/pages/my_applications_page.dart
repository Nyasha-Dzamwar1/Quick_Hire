import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_hire/pages/seeker_notifications_page.dart';
import 'package:quick_hire/pages/seeker_profile_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../repositories/app_repository.dart';
import '../models/job.dart';
import '../models/application.dart';

class MyApplicationsPage extends StatelessWidget {
  const MyApplicationsPage({super.key});

  void _showDeleteConfirmation(
    BuildContext context,
    AppRepository repo,
    String applicationId,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Application'),
          content: const Text(
            'Are you sure you want to delete this application? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                repo.deleteApplication(applicationId);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Application deleted successfully'),
                  ),
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<AppRepository>();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Text(
          'My Applications',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          StreamBuilder<int>(
            stream: context
                .read<AppRepository>()
                .unreadNotificationCountStream(),
            builder: (context, snapshot) {
              int unreadCount = snapshot.data ?? 0;

              return Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SeekerNotificationsPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.notifications),
                    iconSize: 30,
                  ),
                  if (unreadCount > 0)
                    const Positioned(
                      right: 8,
                      top: 8,
                      child: CircleAvatar(
                        radius: 5,
                        backgroundColor: Colors.red,
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SeekerProfilePage(),
                ),
              );
            },
            icon: const Icon(Icons.person),
            iconSize: 30,
          ),
        ],
      ),
      body: StreamBuilder<List<Application>>(
        stream: repo.applicationsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final applications = snapshot.data ?? [];

          if (applications.isEmpty) {
            return const Center(child: Text("No applications yet."));
          }

          return StreamBuilder<List<Job>>(
            stream: repo.jobsStream(),
            builder: (context, jobSnapshot) {
              final jobs = jobSnapshot.data ?? [];

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: applications.length,
                itemBuilder: (context, index) {
                  final app = applications[index];
                  final job = jobs.firstWhere(
                    (j) => j.id == app.jobId,
                    orElse: () => Job(
                      id: '',
                      title: 'Unknown Job',
                      company: '-',
                      price: 0,
                      description: '-',
                      imageUrl: '',
                      category: '',
                      posterEmail: '',
                      posterPhone: '',
                    ),
                  );

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          // Title + Delete Icon
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  job.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1a4d8f),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () => _showDeleteConfirmation(
                                  context,
                                  repo,
                                  app.id,
                                ),
                                tooltip: 'Delete Application',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // Price
                          Text(
                            "MKW ${job.price}",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFf59e0b),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            job.description,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[700],
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            job.company,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF1a4d8f),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Status
                          Row(
                            children: [
                              const Text(
                                'Status:',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: _statusBg(app.status),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  app.status.toUpperCase(),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: _statusFg(app.status),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          if (app.status == 'accepted') ...[
                            const SizedBox(height: 20),
                            const Divider(height: 1),
                            const SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                _ContactButton(
                                  icon: Icons.email_outlined,
                                  label: 'Email',
                                  color: const Color(0xFF1a4d8f),
                                  onPressed: () => _launchEmail(
                                    context,
                                    job.posterEmail,
                                    job.title,
                                  ),
                                ),
                                _ContactButton(
                                  icon: FontAwesomeIcons.whatsapp,
                                  label: 'WhatsApp',
                                  color: const Color(0xFF25D366),
                                  onPressed: () => _launchWhatsApp(
                                    context,
                                    job.posterPhone,
                                    job.title,
                                  ),
                                ),
                                _ContactButton(
                                  icon: Icons.phone,
                                  label: 'Call',
                                  color: const Color(0xFFf59e0b),
                                  onPressed: () =>
                                      _launchPhone(context, job.posterPhone),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // --- Helper functions to style status
  Color _statusBg(String status) {
    switch (status) {
      case "accepted":
        return const Color(0xFFd1fae5);
      case "denied":
        return const Color(0xFFfee2e2);
      default: // pending
        return const Color(0xFFfef9c3);
    }
  }

  Color _statusFg(String status) {
    switch (status) {
      case "accepted":
        return const Color(0xFF065f46);
      case "denied":
        return const Color(0xFF991b1b);
      default: // pending
        return const Color(0xFF92400e);
    }
  }

  Future<void> _launchEmail(
    BuildContext context,
    String email,
    String jobTitle,
  ) async {
    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: email,
        queryParameters: {
          'subject': 'Regarding your job posting: $jobTitle',
          'body':
              'Hello,\n\nI recently applied for your "$jobTitle" job on QuickHire. I\'d like to follow up and discuss more about the opportunity.\n\nThank you,\n[Your Name]',
        },
      );

      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open email app'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening email: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchWhatsApp(
    BuildContext context,
    String phone,
    String jobTitle,
  ) async {
    try {
      // Clean phone number (remove spaces, dashes, etc.)
      String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');

      // Ensure phone has country code
      if (!cleanPhone.startsWith('+')) {
        // Add Malawi country code if not present
        cleanPhone = '+265$cleanPhone';
      }

      final message =
          "Hello! I'm following up regarding your '$jobTitle' job posting on QuickHire. Is it still available?";

      final Uri whatsappUri = Uri.parse(
        'https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}',
      );

      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open WhatsApp'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening WhatsApp: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _launchPhone(BuildContext context, String phone) async {
    try {
      // Clean phone number
      String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');

      final Uri phoneUri = Uri(scheme: 'tel', path: cleanPhone);

      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open phone dialer'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening phone: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

// Custom Contact Button Widget with tap feedback
class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        splashColor: color.withOpacity(0.2),
        highlightColor: color.withOpacity(0.1),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
