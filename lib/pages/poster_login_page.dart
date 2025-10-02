import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PosterLoginPage extends StatefulWidget {
  const PosterLoginPage({super.key});

  @override
  State<PosterLoginPage> createState() => _PosterLoginPageState();
}

class _PosterLoginPageState extends State<PosterLoginPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;

  // Load JSON from assets
  Future<List<Map<String, dynamic>>> loadJson(String path) async {
    final data = await DefaultAssetBundle.of(context).loadString(path);
    return List<Map<String, dynamic>>.from(jsonDecode(data));
  }

  // Login function
  Future<bool> loginJobSeeker(String name, String password) async {
    try {
      final jobSeekers = await loadJson('assets/data/users_jobseekers.json');

      final user = jobSeekers.firstWhere(
        (u) => u['name'] == name && u['password'] == password,
        orElse: () => {},
      );

      if (user.isNotEmpty) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('loggedInUser', jsonEncode(user));
        await prefs.setString('userType', 'jobseeker');
        return true; // login successful
      } else {
        return false; // login failed
      }
    } catch (e) {
      print('Error logging in: $e');
      return false;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 60),
              const Text(
                'Welcome Back to\nQuickHire',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(0, 45, 114, 1.0),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Sign in to continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(0, 45, 114, 1.0),
                ),
              ),
              const SizedBox(height: 50),

              // Phone
              const Text(
                'Name',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(0, 45, 114, 1.0),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: nameController,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'John Doe',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Password
              const Text(
                'Password',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(0, 45, 114, 1.0),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Enter your password',
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
                  filled: true,
                  fillColor: Colors.grey[50],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      size: 20,
                      color: const Color(0xFF666666),
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Sign In Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final password = passwordController.text.trim();

                    final success = await loginJobSeeker(name, password);

                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Login successful!')),
                      );

                      // Navigate to home page
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Invalid credentials')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(0, 45, 114, 1.0),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sign In',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Sign Up
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Don't have an account? ",
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Navigate to sign up page
                    },
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 15,
                        color: Color.fromRGBO(0, 45, 114, 1.0),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
