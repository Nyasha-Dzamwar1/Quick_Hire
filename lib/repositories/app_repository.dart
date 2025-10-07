import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/job.dart';
import '../models/application.dart';

class AppRepository extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  // ========== JOB SEEKERS ==========
  Future<void> createJobSeekerProfile({
    required String name,
    required String dateOfBirth,
    required String gender,
    required String phone,
    required String location,
    required String experience,
    required String password,
  }) async {
    // Create Auth User
    final credential = await _auth.createUserWithEmailAndPassword(
      email: '$phone@quickhire.com', // placeholder email for simplicity
      password: password,
    );

    // Create Firestore Document (auto-creates collection if not exists)
    await _firestore.collection('seekers').doc(credential.user!.uid).set({
      'name': name,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'phone': phone,
      'location': location,
      'experience': experience,
      'role': 'job_seeker',
      'created_at': FieldValue.serverTimestamp(),
    });

    notifyListeners();
  }

  Stream<Map<String, dynamic>?> jobSeekerProfileStream() {
    if (currentUser == null) return const Stream.empty();
    return _firestore
        .collection('seekers')
        .doc(currentUser!.uid)
        .snapshots()
        .map((doc) => doc.data());
  }

  Future<void> updateJobSeekerProfile(Map<String, dynamic> data) async {
    if (currentUser == null) return;
    await _firestore.collection('seekers').doc(currentUser!.uid).update(data);
    notifyListeners();
  }

  // ========== JOB POSTERS ==========
  Future<void> createJobPosterProfile({
    required String name,
    required String businessName,
    required String phone,
    required String location,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: '$phone@quickhire.com',
      password: password,
    );

    await _firestore.collection('job_posters').doc(credential.user!.uid).set({
      'name': name,
      'business_name': businessName,
      'phone': phone,
      'location': location,
      'role': 'job_poster',
      'created_at': FieldValue.serverTimestamp(),
    });

    notifyListeners();
  }

  Stream<Map<String, dynamic>?> jobPosterProfileStream() {
    if (currentUser == null) return const Stream.empty();
    return _firestore
        .collection('job_posters')
        .doc(currentUser!.uid)
        .snapshots()
        .map((doc) => doc.data());
  }

  // ========== JOBS ==========
  Future<void> addJob({
    required String title,
    required String company,
    required String price,
    required String description,
    required String imageUrl,
    required String category,
    required String userPhone,
  }) async {
    if (currentUser == null) return;

    await _firestore.collection('jobs').add({
      'title': title,
      'company': company,
      'price': price,
      'description': description,
      'imageUrl': imageUrl,
      'category': category,
      'posterId': currentUser!.uid,
      'posterEmail': currentUser!.email,
      'posterPhone': userPhone,
      'created_at': FieldValue.serverTimestamp(),
    });

    notifyListeners();
  }

  Stream<List<Job>> jobsStream() {
    return _firestore
        .collection('jobs')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return Job(
              id: doc.id,
              title: data['title'] ?? '',
              company: data['company'] ?? '',
              price: data['price'] is int
                  ? data['price']
                  : int.tryParse(data['price']?.toString() ?? '0') ?? 0,
              description: data['description'] ?? '',
              imageUrl: data['imageUrl'] ?? '',
              category: data['category'] ?? '',
              posterEmail: data['posterEmail'] ?? '',
              posterPhone: data['posterPhone'] ?? '',
            );
          }).toList(),
        );
  }

  Stream<List<Map<String, dynamic>>> posterJobsStream() {
    if (currentUser == null) return const Stream.empty();

    return _firestore
        .collection('jobs')
        .where('posterId', isEqualTo: currentUser!.uid)
        .snapshots()
        .map((snapshot) {
          // include the document id in each returned map so jobData['id'] exists
          return snapshot.docs.map((doc) {
            final data = doc.data();

            return {
              ...data,
              'id': doc.id,
              'posterEmail': data['posterEmail'] ?? '',
              'posterPhone': data['posterPhone'] ?? '',
            };
          }).toList();
        });
  }

  // ========== APPLICATIONS ==========
  Future<bool> applyToJob(String jobId) async {
    if (currentUser == null) return false;

    try {
      final seekerId = currentUser!.uid;

      // Check if seeker already applied
      final existing = await _firestore
          .collection('applications')
          .where('seekerId', isEqualTo: seekerId)
          .where('jobId', isEqualTo: jobId)
          .get();

      if (existing.docs.isNotEmpty) return false;

      // Get job details
      final jobDoc = await _firestore.collection('jobs').doc(jobId).get();
      if (!jobDoc.exists) return false;

      final jobData = jobDoc.data()!;
      final posterId = jobData['posterId'];
      final jobTitle = jobData['title'] ?? 'Job';

      //  Get seeker details
      final seekerDoc = await _firestore
          .collection('seekers')
          .doc(seekerId)
          .get();
      final seekerName = seekerDoc.exists
          ? (seekerDoc.data()?['name'] ?? 'Someone')
          : 'Someone';

      //  Create application
      await _firestore.collection('applications').add({
        'jobId': jobId,
        'seekerId': seekerId,
        'posterId': posterId,
        'status': 'pending',
        'appliedAt': FieldValue.serverTimestamp(),
      });

      // Notify Poster (someone applied)
      await createNotification(
        userId: posterId,
        type: 'new_application',
        applicantName: seekerName,
        jobTitle: jobTitle,
      );

      //  Notify Seeker (you applied successfully)
      await createNotification(
        userId: seekerId,
        type: 'application_success',
        applicantName: seekerName,
        jobTitle: jobTitle,
      );

      notifyListeners();
      return true;
    } catch (e) {
      if (kDebugMode) print('Error applying to job: $e');
      return false;
    }
  }

  Stream<List<Application>> applicationsStream() {
    final uid = currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('applications')
        .where('seekerId', isEqualTo: uid)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return Application(
              id: doc.id,
              jobId: data['jobId'],
              seekerId: data['seekerId'],
              status: data['status'] ?? 'pending',
            );
          }).toList(),
        );
  }

  // Check if current user has applied to a job
  Future<bool> hasApplied(String jobId) async {
    if (currentUser == null) return false;

    final existing = await _firestore
        .collection('applications')
        .where('seekerId', isEqualTo: currentUser!.uid)
        .where('jobId', isEqualTo: jobId)
        .get();

    return existing.docs.isNotEmpty;
  }

  // Update the status of an applicant for a job
  Future<void> updateApplicationStatus(
    String applicationId,
    String status,
  ) async {
    try {
      await _firestore.collection('applications').doc(applicationId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error updating application status: $e');
    }
  }

  // Get applicants for a specific job
  Stream<List<Map<String, dynamic>>> getJobApplicants(String jobId) {
    return _firestore
        .collection('applications')
        .where('jobId', isEqualTo: jobId)
        .snapshots()
        .asyncMap((snapshot) async {
          final futures = snapshot.docs.map((doc) async {
            final appData = doc.data();
            final seekerId = appData['seekerId'];

            final seekerDoc = await _firestore
                .collection('seekers')
                .doc(seekerId)
                .get();
            if (seekerDoc.exists) {
              final seekerData = seekerDoc.data()!;
              return {
                'applicationId': doc.id,
                'name': seekerData['name'],
                'phone': seekerData['phone'],
                'experience': seekerData['experience'],
                'status': appData['status'] ?? 'pending',
                'appliedAt': appData['appliedAt'],
              };
            }
            return null;
          }).toList();

          final applicantsWithDetails = await Future.wait(futures);
          return applicantsWithDetails
              .whereType<Map<String, dynamic>>()
              .toList();
        });
  }

  Future<void> deleteJob(String jobId) async {
    try {
      await FirebaseFirestore.instance.collection('jobs').doc(jobId).delete();

      // Optionally, also delete all applications for this job
      final applications = await FirebaseFirestore.instance
          .collection('applications')
          .where('jobId', isEqualTo: jobId)
          .get();

      for (var doc in applications.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error deleting job: $e');
      rethrow;
    }
  }

  Future<void> deleteApplication(String applicationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('applications')
          .doc(applicationId)
          .delete();
    } catch (e) {
      print('Error deleting application: $e');
      rethrow;
    }
  }

  //creating notifications

  Future<void> createNotification({
    required String userId,
    required String type,
    String? applicantName,
    String? jobTitle,
    String? jobId,
    String? status,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final notificationData = <String, dynamic>{
        'userId': userId,
        'type': type,
        'isRead': false,
        'timestamp': FieldValue.serverTimestamp(),
      };

      // Add fields based on notification type
      // Poster notifications need: applicantName, jobTitle
      if (type == 'new_application' || type == 'application_withdrawn') {
        notificationData['applicantName'] = applicantName;
        notificationData['jobTitle'] = jobTitle;
        if (jobId != null) notificationData['jobId'] = jobId;
      }
      // Seeker notifications need: jobTitle, and sometimes status
      else if (type == 'application_accepted' ||
          type == 'application_denied' ||
          type == 'application_success' ||
          type == 'job_updated' ||
          type == 'job_deleted') {
        notificationData['jobTitle'] = jobTitle;
        if (jobId != null) notificationData['jobId'] = jobId;
        if (status != null) notificationData['status'] = status;
      }

      // Add any additional custom data
      if (additionalData != null) {
        notificationData.addAll(additionalData);
      }

      await _firestore.collection('notifications').add(notificationData);
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error creating notification: $e');
    }
  }

  // Poster notifications stream - filters for poster-specific notification types
  Stream<List<Map<String, dynamic>>> posterNotificationsStream() {
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: currentUser!.uid)
        .where('type', whereIn: ['new_application', 'application_withdrawn'])
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  // Seeker notifications stream - filters for seeker-specific notification types
  Stream<List<Map<String, dynamic>>> seekerNotificationsStream() {
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: currentUser!.uid)
        .where(
          'type',
          whereIn: [
            'application_accepted',
            'application_denied',
            'application_success',
            'job_updated',
            'job_deleted',
          ],
        )
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList();
        });
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
      });
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error marking notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead() async {
    if (currentUser == null) return;

    try {
      final notifications = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: currentUser!.uid)
          .where('isRead', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in notifications.docs) {
        batch.update(doc.reference, {'isRead': true});
      }
      await batch.commit();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error marking all notifications as read: $e');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).delete();
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Error deleting notification: $e');
    }
  }

  // Get unread notification count
  Stream<int> unreadNotificationCountStream() {
    if (currentUser == null) return Stream.value(0);

    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: currentUser!.uid)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  // ========== AUTH ==========
  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }
}
