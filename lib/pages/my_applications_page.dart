import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_hire/repositories/app_repository.dart';
import '../models/job.dart';
import '../models/application.dart';

class MyApplicationsPage extends StatelessWidget {
  const MyApplicationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AppRepository>();
    final applications = repo.getApplicationsForCurrentSeeker();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: Text(
          'My Applications',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications),
            iconSize: 30,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person),
            iconSize: 30,
          ),
        ],
      ),
      body: applications.isEmpty
          ? const Center(child: Text("No applications yet."))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: applications.length,
              itemBuilder: (context, index) {
                final app = applications[index];
                final job = repo.jobs.firstWhere((j) => j.id == app.jobId);

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
                        // Title + Price
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              job.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1a4d8f),
                              ),
                            ),
                            Text(
                              "MKW ${job.price}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1a4d8f),
                              ),
                            ),
                          ],
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
                            color: Color(0xFFf59e0b),
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
