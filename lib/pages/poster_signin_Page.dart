import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quick_hire/navigation/poster_navigation.dart';

class PosterSigninPage extends StatefulWidget {
  const PosterSigninPage({Key? key}) : super(key: key);

  @override
  State<PosterSigninPage> createState() => _PosterSigninPageState();
}

class _PosterSigninPageState extends State<PosterSigninPage> {
  String selectedGender = 'Male';
  final TextEditingController dateController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

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

              // Name
              const Text(
                'Full Name',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(0, 45, 114, 1.0),
                ),
              ),
              const SizedBox(height: 6),
              _buildTextField(hint: 'Your name', controller: nameController),

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
              _buildTextField(hint: 'password', controller: passwordController),

              const SizedBox(height: 14),

              // Date of Birth
              const Text(
                'Date of Birth',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(0, 45, 114, 1.0),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
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
                    dateController.text =
                        '${date.day}/${date.month}/${date.year}';
                  }
                },
                decoration: InputDecoration(
                  hintText: 'Select date',
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
              ),

              const SizedBox(height: 14),

              // Gender
              const Text(
                'Gender',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(0, 45, 114, 1.0),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Male'),
                      value: 'Male',
                      groupValue: selectedGender,
                      onChanged: (value) =>
                          setState(() => selectedGender = value!),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      activeColor: Color.fromRGBO(0, 45, 114, 1.0),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Female'),
                      value: 'Female',
                      groupValue: selectedGender,
                      onChanged: (value) =>
                          setState(() => selectedGender = value!),
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      activeColor: const Color.fromRGBO(0, 45, 114, 1.0),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Phone Number
              const Text(
                'Phone Number',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(0, 45, 114, 1.0),
                ),
              ),
              const SizedBox(height: 6),
              _buildTextField(
                hint: 'e.g., 123456789',
                keyboardType: TextInputType.phone,
                controller: phoneController,
              ),

              const SizedBox(height: 14),

              // Location
              const Text(
                'Location',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color.fromRGBO(0, 45, 114, 1.0),
                ),
              ),
              const SizedBox(height: 6),
              _buildTextField(
                hint: 'Your location',
                controller: locationController,
              ),

              const SizedBox(height: 44),

              // Complete Setup Button
              SizedBox(
                height: 56,
                child: Center(
                  child: ElevatedButton(
                    onPressed: _registerPoster,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(0, 45, 114, 1.0),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Complete Setup',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
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

  Future<void> _registerPoster() async {
    final name = nameController.text.trim();
    final password = passwordController.text.trim();
    final phone = phoneController.text.trim();
    final location = locationController.text.trim();
    final dateOfBirth = dateController.text.trim();
    final gender = selectedGender;

    if (name.isEmpty || password.isEmpty || phone.isEmpty || location.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }

    try {
      // Convert name to pseudo-email (replace spaces to avoid Firebase issues)
      final email = '${name.replaceAll(' ', '').toLowerCase()}@quickhire.com';

      // Step 1: Create Firebase Auth user
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Step 2: Save profile in Firestore
      await FirebaseFirestore.instance
          .collection('posters')
          .doc(credential.user!.uid)
          .set({
            'name': name,
            'email': email, // store pseudo-email for login
            'gender': gender,
            'date_of_birth': dateOfBirth,
            'phone': phone,
            'location': location,
            'created_at': FieldValue.serverTimestamp(),
          });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile created successfully!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PosterNavigation()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Error creating account')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Something went wrong: $e')));
    }
  }

  @override
  void dispose() {
    dateController.dispose();
    nameController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    locationController.dispose();
    super.dispose();
  }
}
