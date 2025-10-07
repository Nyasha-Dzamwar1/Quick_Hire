import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_hire/pages/poster_notifications_page.dart';
import 'package:quick_hire/pages/poster_profile_page.dart';
import 'package:quick_hire/repositories/app_repository.dart';

class MyJobsPage extends StatelessWidget {
  const MyJobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appRepo = Provider.of<AppRepository>(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 130,
        title: Text('My Jobs', style: Theme.of(context).textTheme.titleLarge),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PosterNotificationsPage(),
                ),
              );
            },
            icon: const Icon(Icons.notifications),
            iconSize: 30,
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PosterProfilePage(),
                ),
              );
            },
            icon: const Icon(Icons.person),
            iconSize: 30,
          ),
        ],
      ),

      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: appRepo.posterJobsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No jobs posted yet.'));
          }

          final jobs = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobs.length,
            itemBuilder: (context, index) => JobCard(jobData: jobs[index]),
          );
        },
      ),
    );
  }
}

class JobCard extends StatelessWidget {
  final Map<String, dynamic> jobData;
  const JobCard({super.key, required this.jobData});

  Color _statusBg(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green.shade100;
      case 'denied':
        return Colors.red.shade100;
      default:
        return Colors.yellow.shade100;
    }
  }

  Color _statusFg(String status) {
    switch (status) {
      case 'accepted':
        return Colors.green.shade800;
      case 'denied':
        return Colors.red.shade800;
      default:
        return Colors.orange.shade800;
    }
  }

  void _showDeleteConfirmation(BuildContext context, AppRepository appRepo) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Job'),
          content: const Text(
            'Are you sure you want to delete this job? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                appRepo.deleteJob(jobData['id'] ?? '');
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Job deleted successfully')),
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
    final appRepo = Provider.of<AppRepository>(context, listen: false);

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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    jobData['title'] ?? 'No Title',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1a4d8f),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _showDeleteConfirmation(context, appRepo),
                  tooltip: 'Delete Job',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              jobData['description'] ?? 'No description',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            Text(
              'MKW ${jobData['price'] ?? 0}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(255, 193, 7, 1),
              ),
            ),
            const SizedBox(height: 20),

            StreamBuilder<List<Map<String, dynamic>>>(
              stream: appRepo.getJobApplicants(jobData['id'] ?? ''),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Text('No applicants yet.');
                }

                final applicants = snapshot.data!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Applicants',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...applicants.map((applicant) {
                      final status = applicant['status'] ?? 'pending';
                      final isPending = status == 'pending';
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _statusBg(status),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _statusFg(status).withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        applicant['name'] ?? 'Applicant',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        applicant['phone'] ?? 'N/A',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            // Add experience section
                            if (applicant['experience'] != null &&
                                applicant['experience']
                                    .toString()
                                    .isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.7),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.work_outline,
                                          size: 14,
                                          color: Colors.grey.shade700,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Experience',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.grey.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      applicant['experience'],
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade800,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusFg(status).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    status.toUpperCase(),
                                    style: TextStyle(
                                      color: _statusFg(status),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                if (isPending) ...[
                                  SizedBox(
                                    height: 32,
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          appRepo.updateApplicationStatus(
                                            applicant['applicationId'],
                                            'accepted',
                                          ),
                                      icon: const Icon(Icons.check, size: 16),
                                      label: const Text('Accept'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green.shade600,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  SizedBox(
                                    height: 32,
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          appRepo.updateApplicationStatus(
                                            applicant['applicationId'],
                                            'denied',
                                          ),
                                      icon: const Icon(Icons.close, size: 16),
                                      label: const Text('Deny'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red.shade600,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
