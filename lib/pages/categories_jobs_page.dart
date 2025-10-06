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

  Stream<List<Job>> getJobsByCategory() {
    return FirebaseFirestore.instance
        .collection('jobs')
        .where('category', isEqualTo: categoryName)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Job.fromFirestore(doc)).toList(),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(categoryName)),
      body: StreamBuilder<List<Job>>(
        stream: getJobsByCategory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading jobs: ${snapshot.error}'));
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

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.only(bottom: 16),
                child: InkWell(
                  onTap: () {
                    print("🖼️ Category image: ${categoryImage}");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            JobDetails(job: job, categoryImage: categoryImage),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
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
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
