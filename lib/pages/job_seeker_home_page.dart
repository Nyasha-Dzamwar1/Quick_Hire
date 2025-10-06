import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_hire/pages/categories_jobs_page.dart';
import 'package:quick_hire/pages/seeker_notifications_page.dart';
import 'package:quick_hire/pages/seeker_profile_page.dart';
import 'package:quick_hire/repositories/app_repository.dart';
import 'package:quick_hire/widgets/category_cards.dart';
import 'package:quick_hire/job_details.dart';
import '../models/job.dart';

class JobSeekerHomePage extends StatefulWidget {
  const JobSeekerHomePage({super.key});

  @override
  State<JobSeekerHomePage> createState() => _JobSeekerHomePageState();
}

class _JobSeekerHomePageState extends State<JobSeekerHomePage> {
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

      if (doc.exists) {
        setState(() {
          userName = doc.data()?['name'] ?? 'Seeker';
          isLoading = false;
        });
      } else {
        setState(() {
          userName = 'Seeker';
          isLoading = false;
        });
      }
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
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'All Categories',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: GridView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: categoryImages.length,
                itemBuilder: (context, index) {
                  final category = categoryImages.keys.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CategoryJobsPage(
                            categoryName: category,
                            categoryImage: categoryImages[category]!,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        image: DecorationImage(
                          image: AssetImage(categoryImages[category]!),
                          fit: BoxFit.cover,
                          colorFilter: ColorFilter.mode(
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
                            category,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black45,
                                  blurRadius: 4,
                                  offset: Offset(1, 1),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AppRepository>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        toolbarHeight: 130,
        title: isLoading
            ? const Text("Loading...")
            : Text(
                'Hello, ${userName ?? "Seeker"} 👋',
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
            iconSize: 40,
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

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              // 🔍 Search Bar
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

              // Categories Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  GestureDetector(
                    onTap: _showAllCategories,
                    child: const Text(
                      'See all',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF1a4d8f),
                        fontWeight: FontWeight.w500,
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
                    final category = categoryImages.keys.elementAt(index);
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: CategoryCards(
                        title: category,
                        image: categoryImages[category]!,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryJobsPage(
                                categoryName: category,
                                categoryImage: categoryImages[category]!,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),

              // Job List
              const Text(
                'Available Jobs',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),

              ListView.builder(
                itemCount: jobs.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => JobDetails(
                              job: job,
                              categoryImage:
                                  categoryImages[job.category] ??
                                  'assets/images/placeholder.jpg',
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                const SizedBox(width: 12),
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
            ],
          );
        },
      ),
    );
  }
}

class CategoryCards extends StatelessWidget {
  final String title;
  final String image;
  final VoidCallback onTap;

  const CategoryCards({
    Key? key,
    required this.title,
    required this.image,
    required this.onTap,
  }) : super(key: key);

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
            colorFilter: ColorFilter.mode(Colors.black26, BlendMode.darken),
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
                shadows: [
                  Shadow(
                    color: Colors.black45,
                    blurRadius: 4,
                    offset: Offset(1, 1),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
