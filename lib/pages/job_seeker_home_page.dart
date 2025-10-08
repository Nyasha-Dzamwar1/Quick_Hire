import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_hire/pages/categories_jobs_page.dart';
import 'package:quick_hire/pages/seeker_notifications_page.dart';
import 'package:quick_hire/pages/seeker_profile_page.dart';
import 'package:quick_hire/repositories/app_repository.dart';
import '../models/job.dart';
import '../job_details.dart';

class JobSeekerHomePage extends StatefulWidget {
  const JobSeekerHomePage({super.key});

  @override
  State<JobSeekerHomePage> createState() => _JobSeekerHomePageState();
}

class _JobSeekerHomePageState extends State<JobSeekerHomePage>
    with AutomaticKeepAliveClientMixin {
  // ✅ Keeps the page alive when switching tabs
  @override
  bool get wantKeepAlive => true;

  final Map<String, String> categoryImages = const {
    'Agriculture': 'assets/images/agriculture.jpg',
    'Hospitality': 'assets/images/hospitality.jpg',
    'Gardening & Landscaping': 'assets/images/gardening.jpg',
    'Construction & Labor': 'assets/images/construction.jpg',
    'Retail & Sales': 'assets/images/retail.jpg',
    'Cleaning & Maintenance': 'assets/images/cleaning.jpg',
    'Delivery & Transport': 'assets/images/delivery.jpg',
  };

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
          .collection('seekers')
          .doc(user.uid)
          .get();

      setState(() {
        userName = doc.data()?['name'] ?? 'Seeker';
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching user name: $e');
      setState(() {
        userName = 'Seeker';
        isLoading = false;
      });
    }
  }

  void _showAllCategories() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            controller: scrollController,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 items per row
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6, // adjust for card height
            ),
            itemCount: categoryImages.length,
            itemBuilder: (context, index) {
              final entry = categoryImages.entries.elementAt(index);
              return GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CategoryJobsPage(
                        categoryName: entry.key,
                        categoryImage: entry.value,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: AssetImage(entry.value),
                      fit: BoxFit.cover,
                      colorFilter: const ColorFilter.mode(
                        Colors.black26,
                        BlendMode.darken,
                      ),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Needed when using AutomaticKeepAliveClientMixin
    final repo = context.watch<AppRepository>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        toolbarHeight: 120,
        title: isLoading
            ? const Text("Loading...")
            : Text(
                'Hello, ${userName ?? "Seeker"} 👋',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1a4d8f),
                ),
              ),
        actions: [
          StreamBuilder<int>(
            stream: repo.unreadNotificationCountStream(),
            builder: (context, snapshot) {
              bool hasUnread = (snapshot.data ?? 0) > 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, size: 30),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const SeekerNotificationsPage(),
                        ),
                      );
                    },
                  ),
                  if (hasUnread)
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
            icon: const Icon(Icons.person, size: 35),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SeekerProfilePage()),
              );
            },
          ),
        ],
      ),

      body: StreamBuilder<List<Job>>(
        stream: repo.jobsStream(),
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
                'No jobs available right now.\nCheck back later!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Categories section
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Categories',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: _showAllCategories,
                            child: const Text(
                              'See all',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xFF1a4d8f),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 150,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: categoryImages.length,
                          itemBuilder: (context, index) {
                            final category = categoryImages.keys.elementAt(
                              index,
                            );
                            return Padding(
                              padding: const EdgeInsets.only(right: 12),
                              child: _CategoryCard(
                                title: category,
                                image: categoryImages[category]!,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CategoryJobsPage(
                                        categoryName: category,
                                        categoryImage:
                                            categoryImages[category]!,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        'Available Jobs',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                    ],
                  ),
                ),
              ),
              SliverList.builder(
                itemCount: jobs.length,
                itemBuilder: (context, index) {
                  final job = jobs[index];
                  return _JobCard(job: job, imageMap: categoryImages);
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.title,
    required this.image,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: AssetImage(image),
            fit: BoxFit.cover,
            colorFilter: const ColorFilter.mode(
              Colors.black26,
              BlendMode.darken,
            ),
          ),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final Job job;
  final Map<String, String> imageMap;

  const _JobCard({required this.job, required this.imageMap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => JobDetails(
                job: job,
                categoryImage:
                    imageMap[job.category] ?? 'assets/images/placeholder.jpg',
              ),
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
