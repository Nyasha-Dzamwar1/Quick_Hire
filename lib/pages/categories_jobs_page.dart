import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job.dart';
import '../job_details.dart';

class CategoryJobsPage extends StatelessWidget {
  final String categoryName;
  final String categoryImage;

  const CategoryJobsPage({
    Key? key,
    required this.categoryName,
    required this.categoryImage,
  }) : super(key: key);

  Stream<List<Job>> get _jobsStream {
    return FirebaseFirestore.instance
        .collection('jobs')
        .where('category', isEqualTo: categoryName)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(Job.fromFirestore).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: StreamBuilder<List<Job>>(
        stream: _jobsStream,
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
              return const Center(child: CircularProgressIndicator());
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error loading jobs: ${snapshot.error}',
                    style: const TextStyle(color: Colors.redAccent),
                  ),
                );
              }

              final jobs = snapshot.data ?? [];

              if (jobs.isEmpty) {
                return const Center(
                  child: Text(
                    'No jobs available in this category.',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: jobs.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final job = jobs[index];
                  return _JobCard(job: job, categoryImage: categoryImage);
                },
              );
          }
        },
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final Job job;
  final String categoryImage;

  const _JobCard({required this.job, required this.categoryImage});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  JobDetails(job: job, categoryImage: categoryImage),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      job.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1a4d8f),
                      ),
                    ),
                  ),
                  Text(
                    'MKW ${job.price.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1a4d8f),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                job.company,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFFFFA726),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                job.description,
                style: const TextStyle(fontSize: 15, color: Colors.black87),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
