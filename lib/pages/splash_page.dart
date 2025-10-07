import 'package:flutter/material.dart';
import 'package:quick_hire/navigation/poster_navigation.dart';
import 'package:quick_hire/navigation/seeker_navigation.dart';
import 'package:quick_hire/pages/poster_login_page.dart';
import 'package:quick_hire/pages/seeker_login_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  String? selectedOption;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            children: [
              // Title with styled text
              RichText(
                text: TextSpan(
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: 'Choose ',
                      style: TextStyle(color: Color.fromRGBO(0, 45, 114, 1.0)),
                    ),
                    TextSpan(
                      text: 'One',
                      style: TextStyle(color: Color.fromRGBO(255, 193, 7, 1.0)),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12),

              // Subtitle
              Text(
                'I am a',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.grey[700],
                  height: 1.5,
                  fontWeight: FontWeight.w700,
                ),
              ),

              Spacer(),

              // Option cards
              Column(
                children: [
                  _buildOptionCard(
                    isSelected: selectedOption == 'job_seeker',
                    icon: Icons.work_outline,
                    title: 'Job Seeker',
                    subtitle:
                        'It\'s easy to find your dream\njobs here with us',
                    onTap: () {
                      setState(() {
                        selectedOption = 'job_seeker';
                      });
                    },
                  ),

                  SizedBox(height: 16),

                  _buildOptionCard(
                    isSelected: selectedOption == 'job_poster',
                    icon: Icons.people_outline,
                    title: 'Job Poster',
                    subtitle: 'It\'s easy to find your\nemployees here with us',
                    onTap: () {
                      setState(() {
                        selectedOption = 'job_poster';
                      });
                    },
                  ),
                ],
              ),

              Spacer(),

              // Confirm button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: selectedOption != null
                      ? () {
                          if (selectedOption == 'job_seeker') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SeekerLoginPage(),
                              ),
                            );
                          } else if (selectedOption == 'job_poster') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PosterLoginPage(),
                              ),
                            );
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(0, 45, 114, 1.0),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirm',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionCard({
    required bool isSelected,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFFFFF4D6) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Color(0xFFFDB714) : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.white : Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 28, color: Color(0xFF1E3A5F)),
            ),

            SizedBox(width: 16),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A5F),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
