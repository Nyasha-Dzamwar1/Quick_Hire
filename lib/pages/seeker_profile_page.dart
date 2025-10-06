import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quick_hire/pages/my_applications_page.dart';
import 'package:quick_hire/pages/seeker_notifications_page.dart';
import 'package:quick_hire/pages/splash_page.dart';

class SeekerProfilePage extends StatefulWidget {
  const SeekerProfilePage({super.key});

  @override
  State<SeekerProfilePage> createState() => _SeekerProfilePageState();
}

class _SeekerProfilePageState extends State<SeekerProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final doc = await _firestore.collection('seekers').doc(user.uid).get();

      if (doc.exists) {
        setState(() {
          userData = doc.data();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const SplashPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(0, 45, 114, 1.0),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color.fromRGBO(0, 45, 114, 1.0),
        toolbarHeight: 100,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
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
          const SizedBox(width: 8),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: userData == null
                  ? const Center(
                      child: Text(
                        'No profile data found.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView(
                      children: [
                        // Avatar
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                Color.fromRGBO(0, 45, 114, 1.0),
                                Color.fromRGBO(0, 70, 150, 1.0),
                              ],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey[200],
                            child: const Icon(
                              Icons.person,
                              size: 50,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Name
                        Center(
                          child: Text(
                            userData?['name'] ?? "Unknown User",
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Profile details
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                Icons.person_outline,
                                'Gender',
                                userData?['gender'] ?? '-',
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                Icons.cake_outlined,
                                'Date of Birth',
                                userData?['date_of_birth'] ?? '-',
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                Icons.badge_outlined,
                                'Phone Number',
                                userData?['phone'] ?? '-',
                              ),
                              const SizedBox(height: 16),
                              _buildInfoRow(
                                Icons.location_on_outlined,
                                'Location',
                                userData?['location'] ?? '-',
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Menu
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              _buildMenuItem(
                                context,
                                icon: Icons.description_outlined,
                                title: 'My Applications',
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const MyApplicationsPage(),
                                    ),
                                  );
                                },
                              ),
                              const Divider(height: 1, indent: 60),
                              _buildMenuItem(
                                context,
                                icon: Icons.help_outline,
                                title: 'Help',
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Help tapped"),
                                    ),
                                  );
                                },
                              ),
                              const Divider(height: 1, indent: 60),
                              _buildMenuItem(
                                context,
                                icon: Icons.logout,
                                title: 'Log out',
                                onTap: _logout,
                                showArrow: false,
                                isDestructive: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(0, 45, 114, 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color.fromRGBO(0, 45, 114, 1.0),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool showArrow = true,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.08)
                    : const Color.fromRGBO(0, 45, 114, 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDestructive
                    ? Colors.red[700]
                    : const Color.fromRGBO(0, 45, 114, 1.0),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? Colors.red[700] : Colors.black87,
                ),
              ),
            ),
            if (showArrow)
              Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
          ],
        ),
      ),
    );
  }
}
