import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quick_hire/models/job.dart';
import 'package:quick_hire/repositories/app_repository.dart';
import 'package:quick_hire/widgets/category_cards.dart';
import 'package:quick_hire/job_details.dart';

class JobSeekerHomePage extends StatefulWidget {
  const JobSeekerHomePage({super.key});

  @override
  State<JobSeekerHomePage> createState() => _JobSeekerHomePageState();
}

class _JobSeekerHomePageState extends State<JobSeekerHomePage> {
  final Map<String, String> categoryImages = {
    'Agriculture': 'assets/images/agriculture.jpg',
    'Hospitality': 'assets/images/hospitality.jpg',
    'Gardening & Landscaping': 'assets/images/gardening.jpg',
    'Construction & Labor': 'assets/images/construction.jpg',
    'Retail & Sales': 'assets/images/retail.jpg',
    'Cleaning & Maintenance': 'assets/images/cleaning.jpg',
    'Delivery & Transport': 'assets/images/delivery.jpg',
  };

  List<Job> jobs = [];

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    final repo = Provider.of<AppRepository>(context, listen: false);
    // If your AppRepository already loaded jobs in init(), just get them:
    setState(() {
      jobs = repo.getJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.watch<AppRepository>();
    final user = repo.currentUser;

    if (jobs.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 130,
        title: Text(
          'Hello, ${user?.name}',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications),
            iconSize: 40,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person),
            iconSize: 40,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Search
          TextField(
            decoration: InputDecoration(
              hintText: 'Search jobs',
              prefixIcon: const Icon(Icons.search, size: 30),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Categories Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                'Categories',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              Text(
                'See all',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 20),

          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                final job = jobs[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: CategoryCards(
                    title: job.title,
                    price: job.price,
                    image: job.imageUrl,
                    campany: job.company,
                    description: job.description,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 30),

          // Job List
          ListView.builder(
            itemCount: jobs.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              final job = jobs[index];
              return SizedBox(
                width: 140,
                child: Card(
                  margin: const EdgeInsets.only(bottom: 15),
                  child: ListTile(
                    leading: job.imageUrl.isNotEmpty
                        ? Image.asset(
                            job.imageUrl.isNotEmpty
                                ? job.imageUrl
                                : categoryImages[job.category] ??
                                      'assets/images/default.jpg',
                            width: 50,
                            fit: BoxFit.cover,
                          )
                        : const SizedBox(width: 50), // handle empty imageUrl
                    title: Text(job.title),
                    subtitle: Text(job.company),
                    trailing: Text("MKW${job.price}"),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => JobDetails(job: job)),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
