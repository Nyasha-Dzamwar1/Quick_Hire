import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'package:quick_hire/navigation/seeker_navigation.dart';
import 'package:quick_hire/pages/seeker_login_page.dart';
import 'package:quick_hire/repositories/app_repository.dart';

class SeekerSigninPage extends StatefulWidget {
  const SeekerSigninPage({Key? key}) : super(key: key);

  @override
  State<SeekerSigninPage> createState() => _SeekerSigninPageState();
}

class _SeekerSigninPageState extends State<SeekerSigninPage> {
  String selectedGender = 'Male';
  final TextEditingController dateController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  bool isLoading = false;

  Future<void> _completeSetup() async {
    setState(() => isLoading = true);

    final name = nameController.text.trim();
    final password = passwordController.text.trim();
    final phone = phoneController.text.trim();
    final location = locationController.text.trim();
    final experience = experienceController.text.trim();
    final dob = dateController.text.trim();
    final gender = selectedGender;

    if (name.isEmpty || password.isEmpty || phone.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      // Generate pseudo-email from name
      final email = '${name.replaceAll(' ', '').toLowerCase()}@quickhire.com';

      // Step 1: Create Firebase Auth user
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Step 2: Save profile in Firestore
      await FirebaseFirestore.instance
          .collection('seekers')
          .doc(credential.user!.uid)
          .set({
            'name': name,
            'email': email, // store pseudo-email
            'gender': gender,
            'date_of_birth': dob,
            'phone': phone,
            'location': location,
            'experience': experience,
            'created_at': FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile setup complete!')));

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SeekerNavigation()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error creating account')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Something went wrong: $e')));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    dateController.dispose();
    nameController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    locationController.dispose();
    experienceController.dispose();
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
              const SizedBox(height: 20),
              const Text(
                'Welcome to\nQuickHire',
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
                'Set up your profile',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(0, 45, 114, 1.0),
                ),
              ),
              const SizedBox(height: 30),

              _buildTextField(controller: nameController, hint: 'Full Name'),
              const SizedBox(height: 14),
              _buildTextField(
                controller: passwordController,
                hint: 'Password',
                obscureText: true,
              ),
              const SizedBox(height: 14),
              _buildDateField(),
              const SizedBox(height: 14),
              _buildGenderField(),
              const SizedBox(height: 14),
              _buildTextField(
                controller: phoneController,
                hint: 'Phone Number',
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 14),
              _buildTextField(controller: locationController, hint: 'Location'),
              const SizedBox(height: 14),
              _buildTextField(
                controller: experienceController,
                hint: 'Work Experience',
                maxLines: 3,
              ),
              const SizedBox(height: 30),

              SizedBox(
                height: 56,
                child: Center(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : () => _completeSetup(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(0, 45, 114, 1.0),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'Complete Setup',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: TextStyle(fontSize: 15, color: Colors.grey[600]),
                  ),

                  GestureDetector(
                    onTap: () {
                      // Navigate to log in page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SeekerLoginPage(),
                        ),
                      );
                    },
                    child: const Text(
                      'Log in',
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

  Widget _buildTextField({
    required TextEditingController controller,
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    bool obscureText = false,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      obscureText: obscureText,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        hintText: hint,
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
    );
  }

  Widget _buildDateField() {
    return TextField(
      controller: dateController,
      readOnly: true,
      onTap: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(1950),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          dateController.text = '${date.day}/${date.month}/${date.year}';
        }
      },
      decoration: InputDecoration(
        hintText: 'Date of Birth',
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
        suffixIcon: const Icon(
          Icons.calendar_today,
          size: 20,
          color: Color(0xFF666666),
        ),
      ),
    );
  }

  Widget _buildGenderField() {
    return Row(
      children: [
        Expanded(
          child: RadioListTile<String>(
            title: const Text('Male'),
            value: 'Male',
            groupValue: selectedGender,
            onChanged: (value) => setState(() => selectedGender = value!),
            contentPadding: EdgeInsets.zero,
            dense: true,
            activeColor: const Color.fromRGBO(0, 45, 114, 1.0),
          ),
        ),
        Expanded(
          child: RadioListTile<String>(
            title: const Text('Female'),
            value: 'Female',
            groupValue: selectedGender,
            onChanged: (value) => setState(() => selectedGender = value!),
            contentPadding: EdgeInsets.zero,
            dense: true,
            activeColor: const Color.fromRGBO(0, 45, 114, 1.0),
          ),
        ),
      ],
    );
  }
}
