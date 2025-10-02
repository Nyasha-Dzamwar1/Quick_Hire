import 'package:flutter/material.dart';
import '../pages/job_seeker_home_page.dart';
import '../pages/my_applications_page.dart';
import '../pages/seeker_profile_page.dart';

class SeekerNavigation extends StatefulWidget {
  const SeekerNavigation({super.key});

  @override
  State<SeekerNavigation> createState() => _SeekerNavigationState();
}

class _SeekerNavigationState extends State<SeekerNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    JobSeekerHomePage(),
    const MyApplicationsPage(),
    const SeekerProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],

      //bottom nav
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_copy),
            label: 'Applications',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
