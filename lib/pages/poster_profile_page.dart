import 'package:flutter/material.dart';

class PosterProfilePage extends StatelessWidget {
  const PosterProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromRGBO(0, 45, 114, 1.0),
      // App Bar
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Color.fromRGBO(0, 45, 114, 1.0),
        toolbarHeight: 100,
        title: Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            color: Colors.white,
            icon: Icon(Icons.notifications_outlined),
            iconSize: 28,
          ),
          SizedBox(width: 8),
        ],
      ),
      //body
      body: Container(
        width: double.infinity,
        padding: EdgeInsets.fromLTRB(24, 32, 24, 20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: ListView(
          children: [
            // Profile Avatar Section
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
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
                child: Icon(Icons.person, size: 50, color: Colors.grey[400]),
              ),
            ),
            SizedBox(height: 16),

            // Name
            Center(
              child: Text(
                'Sibongile Chazama',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            SizedBox(height: 24),

            // Profile Details Card
            Container(
              padding: EdgeInsets.all(20),
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
                  _buildInfoRow(Icons.person_outline, 'Gender', 'Female'),
                  SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.cake_outlined,
                    'Date of Birth',
                    '19 July 1998',
                  ),
                  SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.badge_outlined,
                    'Phone Number',
                    '09972683',
                  ),
                  SizedBox(height: 16),
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    'Location',
                    'Blantyre',
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Menu Container
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
                      print('Navigate to My Applications');
                    },
                  ),
                  Divider(height: 1, indent: 60),
                  _buildMenuItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Help',
                    onTap: () {
                      print('Navigate to Help');
                    },
                  ),
                  Divider(height: 1, indent: 60),
                  _buildMenuItem(
                    context,
                    icon: Icons.logout,
                    title: 'Log out',
                    onTap: () {
                      _showLogoutDialog(context);
                    },
                    showArrow: false,
                    isDestructive: true,
                  ),
                ],
              ),
            ),

            Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color.fromRGBO(0, 45, 114, 0.08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: Color.fromRGBO(0, 45, 114, 1.0)),
        ),
        SizedBox(width: 16),
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
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
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
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.08)
                    : Color.fromRGBO(0, 45, 114, 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDestructive
                    ? Colors.red[700]
                    : Color.fromRGBO(0, 45, 114, 1.0),
              ),
            ),
            SizedBox(width: 16),
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

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                print('User logged out');
              },
              child: Text('Log Out', style: TextStyle(color: Colors.red[700])),
            ),
          ],
        );
      },
    );
  }
}
