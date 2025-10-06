import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_hire/pages/job_posting_page.dart';
import 'package:quick_hire/pages/poster_notifications_page.dart';
import 'package:quick_hire/pages/poster_profile_page.dart';
import 'package:quick_hire/repositories/app_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JobPosterHomePage extends StatefulWidget {
  const JobPosterHomePage({super.key});

  @override
  State<JobPosterHomePage> createState() => _JobPosterHomePageState();
}

class _JobPosterHomePageState extends State<JobPosterHomePage> {
  String? userName;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('posters')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        setState(() {
          userName = doc.data()?['name'] ?? 'Poster';
          isLoading = false;
        });
      } else {
        setState(() {
          userName = 'Poster';
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching user name: $e');
      setState(() {
        userName = 'Poster';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<AppRepository>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        toolbarHeight: 130,
        title: isLoading
            ? const Text("Loading...")
            : Text(
                'Hello, ${userName ?? "Poster"} 👋',
                style: Theme.of(context).textTheme.titleLarge,
              ),
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
            iconSize: 40,
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: repo.posterJobsStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final myJobs = snapshot.data ?? [];

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search jobs',
                  prefixIcon: const Icon(Icons.search, size: 28),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
              const SizedBox(height: 30),

              // My Jobs Heading
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text(
                    'My Jobs',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'See all',
                    style: TextStyle(fontSize: 16, color: Color(0xFF1a4d8f)),
                  ),
                ],
              ),
              const SizedBox(height: 15),

              // Job Cards
              if (myJobs.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      "You haven't posted any jobs yet.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ),
              if (myJobs.isNotEmpty)
                ListView.builder(
                  itemCount: myJobs.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    final job = myJobs[index];
                    return Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () {
                          // Add navigation to job details if needed
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      job['title'] ?? '',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1a4d8f),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'MKW ${job['price']?.toString() ?? '0'}',
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
                                job['company'] ?? '',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFFFA726),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                job['description'] ?? '',
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black87,
                                  height: 1.4,
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
                ),
              const SizedBox(height: 30),

              // Post Job Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const JobPostingPage(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF002D72),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    'Post a Job',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
