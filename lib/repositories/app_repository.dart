// repository/app_repository.dart
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../models/job.dart';
import '../models/application.dart';
import '../services/local_storage_service.dart';
import 'dart:math';

class AppRepository extends ChangeNotifier {
  final LocalStorageService storage;
  List<User> users = [];
  List<Job> jobs = [];
  List<ApplicationModel> applications = [];
  User? currentUser;

  AppRepository({required this.storage});

  // Call this once at app start
  Future<void> init() async {
    await storage.init();

    // load users
    final userJson = storage.loadUsers();
    users = userJson.map((m) => User.fromJson(m)).toList();

    final jobJson = storage.loadJobs();
    jobs = jobJson.map((m) => Job.fromJson(m)).toList();

    final appJson = storage.loadApplications();
    applications = appJson.map((m) => ApplicationModel.fromJson(m)).toList();

    final currentId = storage.getCurrentUserId();
    if (currentId != null) {
      final found = users.where((u) => u.id == currentId);
      if (found.isNotEmpty) currentUser = found.first;
    }

    // seed demo data if empty (useful for development)
    if (users.isEmpty && jobs.isEmpty) {
      _seedDemoData();
      await _saveAll();
    }

    notifyListeners();
  }

  // ---- simple id generator ----
  String _id() =>
      DateTime.now().millisecondsSinceEpoch.toString() +
      Random().nextInt(999).toString();

  // ---- auth ----
  Future<bool> login(String phone, String password) async {
    try {
      final u = users.firstWhere(
        (u) => u.phone == phone && u.password == password,
      );
      currentUser = u;
      await storage.setCurrentUserId(u.id);
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> registerSeeker({
    required String name,
    required String dob,
    required String gender,
    required String phone,
    required String password,
    required String location,
    String? experience,
  }) async {
    final u = User(
      id: _id(),
      role: 'seeker',
      name: name,
      dob: dob,
      gender: gender,
      phone: phone,
      password: password,
      location: location,
      experience: experience,
    );
    users.add(u);
    await storage.saveUsers(users.map((u) => u.toJson()).toList());
    notifyListeners();
  }

  Future<void> logout() async {
    currentUser = null;
    await storage.clearCurrentUserId();
    notifyListeners();
  }

  // ---- jobs ----
  List<Job> getJobs({String? category}) {
    if (category == null || category.isEmpty) return List.from(jobs);
    return jobs
        .where((j) => j.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  // ---- applications ----
  bool hasApplied(String jobId) {
    if (currentUser == null) return false;
    return applications.any(
      (a) => a.jobId == jobId && a.seekerId == currentUser!.id,
    );
  }

  Future<bool> applyToJob(String jobId) async {
    if (currentUser == null) return false;
    if (currentUser!.role != 'seeker') return false;

    // prevent duplicate
    if (hasApplied(jobId)) return false;

    final app = ApplicationModel(
      id: _id(),
      jobId: jobId,
      seekerId: currentUser!.id,
      status: 'pending',
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );

    applications.add(app);
    await storage.saveApplications(
      applications.map((a) => a.toJson()).toList(),
    );
    notifyListeners();
    return true;
  }

  List<ApplicationModel> getApplicationsForCurrentSeeker() {
    if (currentUser == null) return [];
    return applications.where((a) => a.seekerId == currentUser!.id).toList();
  }

  // helper to save everything (call after big changes)
  Future<void> _saveAll() async {
    await storage.saveUsers(users.map((u) => u.toJson()).toList());
    await storage.saveJobs(jobs.map((j) => j.toJson()).toList());
    await storage.saveApplications(
      applications.map((a) => a.toJson()).toList(),
    );
  }

  // ----- demo data -----
  void _seedDemoData() {
    final poster = User(
      id: 'poster1',
      role: 'poster',
      name: 'Sample Poster',
      dob: '1980-01-01',
      gender: 'female',
      phone: '0700000001',
      password: 'pass',
      location: 'Market',
    );

    final seeker = User(
      id: 'seeker1',
      role: 'seeker',
      name: 'Sample Seeker',
      dob: '1995-05-05',
      gender: 'male',
      phone: '0700000002',
      password: 'pass',
      location: 'Campus',
      experience: '2 years landscaping',
    );

    final job1 = Job(
      id: 'job1',
      title: 'Farm Helper',
      price: 5000,
      imageUrl: '',
      company: 'Smith Farms',
      category: 'Agriculture', // add category here
      description: 'Help with planting and harvesting.',
    );

    final job2 = Job(
      id: 'job2',
      title: 'Restaurant Server',
      price: 60000,
      imageUrl: 'assets/images/server.jpg',
      company: 'Mugg & Bean',
      category: 'Hospitality', // add category here
      description:
          'Serve customers with professionalism, handle orders, and ensure a great dining experience.',
    );

    final job3 = Job(
      id: 'job3',
      title: 'Gardening Help',
      price: 15000,
      imageUrl: 'assets/images/gardener.jpg',
      company: 'Private Client',
      category: 'Gardening', // add category here
      description:
          'Assist with trimming, planting, and maintaining a small backyard garden.',
    );

    const Map<String, String> categoryImages = {
      'Agriculture': 'assets/images/agriculture.jpg',
      'Hospitality': 'assets/images/hospitality.jpg',
      'Gardening & Landscaping': 'assets/images/gardening.jpg',
      'Construction & Labor': 'assets/images/construction.jpg',
      'Retail & Sales': 'assets/images/retail.jpg',
      'Cleaning & Maintenance': 'assets/images/cleaning.jpg',
      'Delivery & Transport': 'assets/images/delivery.jpg',
    };

    users.addAll([poster, seeker]);
    jobs.add(job1);
    // applications empty
  }
}
