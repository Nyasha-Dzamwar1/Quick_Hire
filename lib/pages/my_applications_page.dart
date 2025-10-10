import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.red[700],
                    size: 32,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Delete Application',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Text(
                  'Are you sure you want to delete this application? This action cannot be undone.',
                  style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          repo.deleteApplication(applicationId);
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text(
                                    'Application deleted successfully',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: Colors.green[600],
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Delete',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<AppRepository>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        toolbarHeight: 100,
        backgroundColor: const Color.fromRGBO(0, 45, 114, 1.0),
        elevation: 0,
        title: const Text(
          'My Applications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.w700,
          ),
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
                    icon: const Icon(Icons.notifications_outlined),
                    iconSize: 26,
                    color: Colors.white,
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.red[600],
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          unreadCount > 9 ? '9+' : '$unreadCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
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
            icon: const Icon(Icons.person_outline),
            iconSize: 26,
            color: Colors.white,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder<List<Application>>(
        stream: repo.applicationsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              height: MediaQuery.of(context).size.height - 150,
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF002D72)),
              ),
            );
          }

          final applications = snapshot.data ?? [];

          if (applications.isEmpty) {
            return SizedBox(
              height: MediaQuery.of(context).size.height - 150,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.work_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'No applications yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start applying to jobs to see them here',
                      style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            );
          }

          return StreamBuilder<List<Job>>(
            stream: repo.jobsStream(),
            builder: (context, jobSnapshot) {
              final jobs = jobSnapshot.data ?? [];

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 4, bottom: 16),
                      child: Text(
                        '${applications.length} ${applications.length == 1 ? 'Application' : 'Applications'}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
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

                          return ApplicationCard(
                            app: app,
                            job: job,
                            onDelete: () =>
                                _showDeleteConfirmation(context, repo, app.id),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ApplicationCard extends StatelessWidget {
  final Application app;
  final Job job;
  final VoidCallback onDelete;

  const ApplicationCard({
    super.key,
    required this.app,
    required this.job,
    required this.onDelete,
  });

  Color _statusBg(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green.shade50;
      case 'denied':
        return Colors.red.shade50;
      default:
        return Colors.orange.shade50;
    }
  }

  Color _statusFg(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green.shade700;
      case 'denied':
        return Colors.red.shade700;
      default:
        return Colors.orange.shade700;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'accepted':
        return Icons.check_circle;
      case 'denied':
        return Icons.cancel;
      default:
        return Icons.access_time;
    }
  }

  Future<void> _launchEmail(
    BuildContext context,
    String email,
    String jobTitle,
  ) async {
    try {
      final subject = Uri.encodeComponent(
        'Regarding your job posting: $jobTitle',
      );
      final body = Uri.encodeComponent(
        'Hello,\n\n'
        'I recently applied for your "$jobTitle" job on QuickHire. '
        'I\'d like to follow up and discuss more about the opportunity.\n\n'
        'Thank you,\n[Your Name]',
      );

      final emailUri = Uri.parse('mailto:$email?subject=$subject&body=$body');

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
      //Clean the number: remove spaces, brackets, dashes, etc.
      String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');

      // If the number starts with +, assume it’s already in international format.
      if (!cleanPhone.startsWith('+')) {
        // Remove leading zeros before prefixing country code
        cleanPhone = cleanPhone.replaceFirst(RegExp(r'^0+'), '');
        cleanPhone = '+265$cleanPhone';
      }

      // Prepare your message
      final message =
          "Hello! I'm following up regarding your '$jobTitle' job posting on QuickHire. Is it still available?";

      //Create the WhatsApp link
      final Uri whatsappUri = Uri.parse(
        'https://wa.me/${cleanPhone.replaceAll('+', '')}?text=${Uri.encodeComponent(message)}',
      );

      //Launch WhatsApp
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
      // Remove spaces, dashes, etc.
      String cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');

      // Handle Malawi local numbers like 0999418157
      if (!cleanPhone.startsWith('+')) {
        cleanPhone = cleanPhone.replaceFirst(RegExp(r'^0+'), '');
        cleanPhone = '+265$cleanPhone';
      }

      // Encode the phone number properly
      final encodedPhone = Uri.encodeComponent(cleanPhone);

      final Uri phoneUri = Uri.parse('tel:$encodedPhone');

      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri, mode: LaunchMode.externalApplication);
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

  @override
  Widget build(BuildContext context) {
    final formattedPrice = NumberFormat('#,##0', 'en_US').format(job.price);
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF002D72), Color(0xFF004190)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.work_outline,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF002D72),
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        job.company,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.delete_outline, color: Colors.red[600]),
                  onPressed: onDelete,
                  tooltip: 'Delete Application',
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.08),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              job.description,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 255, 193, 7),
                    Color.fromARGB(255, 255, 214, 64),
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.payments,
                    size: 18,
                    color: Color(0xFF002D72),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'K $formattedPrice',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF002D72),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _statusBg(app.status),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _statusFg(app.status).withOpacity(0.2),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _statusIcon(app.status),
                      color: _statusFg(app.status),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Status:',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _statusFg(app.status),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      app.status.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (app.status == 'accepted') ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFF002D72).withOpacity(0.2),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 18,
                          color: const Color(0xFF002D72),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Contact Employer',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF002D72),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _ContactButton(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            color: const Color(0xFF002D72),
                            onPressed: () => _launchEmail(
                              context,
                              job.posterEmail,
                              job.title,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ContactButton(
                            icon: FontAwesomeIcons.whatsapp,
                            label: 'WhatsApp',
                            color: const Color(0xFF25D366),
                            onPressed: () => _launchWhatsApp(
                              context,
                              job.posterPhone,
                              job.title,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ContactButton(
                            icon: Icons.phone,
                            label: 'Call',
                            color: const Color(0xFFf59e0b),
                            onPressed: () =>
                                _launchPhone(context, job.posterPhone),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 22),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
