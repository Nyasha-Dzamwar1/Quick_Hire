import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_hire/pages/seeker_notifications_page.dart';
import 'package:quick_hire/pages/seeker_profile_page.dart';
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
                        children: [
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
                              ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _statusBg(app.status),
                                  foregroundColor: _statusFg(app.status),
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  app.status.toUpperCase(),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
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
}
