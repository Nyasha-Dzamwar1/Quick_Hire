import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quick_hire/navigation/poster_navigation.dart';
import 'package:quick_hire/pages/poster_signin_Page.dart';

class PosterLoginPage extends StatefulWidget {
  const PosterLoginPage({super.key});

  @override
  State<PosterLoginPage> createState() => _PosterLoginPageState();
}

class _PosterLoginPageState extends State<PosterLoginPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // Login function using Firebase Auth (name + password)
  Future<void> loginPoster(String name, String password) async {
    setState(() => _isLoading = true);

    try {
      // Get user by name
      final query = await FirebaseFirestore.instance
          .collection('posters')
          .where('name', isEqualTo: name)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('No user found with that name');
      }

      final userData = query.docs.first.data();
      final email = userData['email'] as String?;

      if (email == null || email.isEmpty) {
        throw Exception('Email not found for this user');
      }

      // Sign in with Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Login successful!')));

      //Navigate to Dashboard
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const PosterNavigation()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Invalid credentials')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
    } finally {
      setState(() => _isLoading = false);
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
                'Log in to continue',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(0, 45, 114, 1.0),
                ),
              ),
              const SizedBox(height: 50),

              // Name field
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
                keyboardType: TextInputType.name,
                style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Enter your name',
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
                  onPressed: _isLoading
                      ? null
                      : () {
                          final name = nameController.text.trim();
                          final password = passwordController.text.trim();

                          if (name.isEmpty || password.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill in all fields.'),
                              ),
                            );
                            return;
                          }

                          loginPoster(name, password);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(0, 45, 114, 1.0),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Log In',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
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
                      // Navigate to Sign Up page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PosterSigninPage(),
                        ),
                      );
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
