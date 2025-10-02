import 'package:flutter/material.dart';
import 'package:quick_hire/pages/job_poster_home_page.dart';
import 'package:quick_hire/pages/poster_profile_page.dart';
import '../pages/my_jobs_page.dart';

class PosterNavigation extends StatefulWidget {
  const PosterNavigation({super.key});

  @override
  State<PosterNavigation> createState() => _PosterNavigationState();
}

class _PosterNavigationState extends State<PosterNavigation> {
  int _selectedIndex = 0;

  final List<Widget> _pages = const [
    JobPosterHomePage(),
    MyJobsPage(),
    PosterProfilePage(),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.cases), label: 'My Jobs'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
