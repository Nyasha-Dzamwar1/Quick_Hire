import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_hire/repositories/app_repository.dart';
import '../models/job.dart';

class JobDetails extends StatelessWidget {
  final Job job;

  const JobDetails({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AppRepository>();
    final hasApplied = repo.hasApplied(job.id);

    return Scaffold(
      appBar: AppBar(title: const Center(child: Text('Details'))),
      body: SingleChildScrollView(
        child: Card(
          margin: const EdgeInsets.all(15),
          color: Colors.white,
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.85,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Job image
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 0,
                    vertical: 0,
                  ),
                  child: Image.asset(
                    job.imageUrl.isNotEmpty
                        ? job.imageUrl
                        : 'assets/images/placeholder.png',
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.title,
                        style: const TextStyle(
                          fontSize: 35,
                          fontWeight: FontWeight.bold,
                          color: Color.fromRGBO(0, 45, 114, 1),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        job.company,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'K${job.price}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color.fromRGBO(255, 193, 7, 1.0),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Job Description',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        job.description,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                // Apply button
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 25,
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 20),
                        padding: const EdgeInsets.all(15),
                        backgroundColor: hasApplied ? Colors.grey : null,
                      ),
                      onPressed: hasApplied
                          ? null
                          : () async {
                              final success = await repo.applyToJob(job.id);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Application Submitted!"),
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      "Could not apply. Maybe already applied?",
                                    ),
                                  ),
                                );
                              }
                            },
                      child: Text(hasApplied ? 'Already Applied' : 'Apply Now'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
