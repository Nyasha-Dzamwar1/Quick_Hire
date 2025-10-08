import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:quick_hire/pages/job_poster_home_page.dart';

class JobPostingPage extends StatefulWidget {
  const JobPostingPage({Key? key}) : super(key: key);

  @override
  State<JobPostingPage> createState() => _JobPostingPageState();
}

class _JobPostingPageState extends State<JobPostingPage> {
  String? selectedCategory;
  bool _isPosting = false;

  final _titleController = TextEditingController();
  final _payController = TextEditingController();
  final _companyController = TextEditingController();
  final _descriptionController = TextEditingController();

  final List<String> categories = [
    'Agriculture',
    'Hospitality',
    'Gardening and Landscaping',
    'Construction & Labor',
    'Retail & Sales',
    'Cleaning & Maintenance',
    'Delivery & Transport',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _payController.dispose();
    _companyController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Post a Job',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
      body: Stack(
        children: [
          Center(
            child: Container(
              width: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Job Title',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF002D72),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildTextField(
                      hint: 'Job title',
                      controller: _titleController,
                    ),
                    const SizedBox(height: 14),

                    const Text(
                      'Job Category',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF002D72),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildDropdown(
                      value: selectedCategory,
                      hintText: 'Select category',
                      icon: Icons.work_outline,
                      items: categories,
                      onChanged: (val) =>
                          setState(() => selectedCategory = val),
                    ),
                    const SizedBox(height: 14),

                    const Text(
                      'Pay (MWK)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF002D72),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildTextField(
                      hint: 'e.g., 50,000',
                      keyboardType: TextInputType.number,
                      controller: _payController,
                    ),
                    const SizedBox(height: 14),

                    const Text(
                      'Company Name',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF002D72),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildTextField(
                      hint: 'Company name',
                      controller: _companyController,
                    ),
                    const SizedBox(height: 14),

                    const Text(
                      'Job Description',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF002D72),
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildTextField(
                      hint: 'Write something...',
                      maxLines: 4,
                      controller: _descriptionController,
                    ),
                    const SizedBox(height: 20),

                    SizedBox(
                      height: 56,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isPosting ? null : _postJob,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF002D72),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: _isPosting
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Post a Job',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Optional loading overlay
          if (_isPosting) Container(color: Colors.black.withOpacity(0.3)),
        ],
      ),
    );
  }

  Future<void> _postJob() async {
    if (_titleController.text.isEmpty ||
        _payController.text.isEmpty ||
        _companyController.text.isEmpty ||
        _descriptionController.text.isEmpty ||
        selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("You must be logged in to post a job")),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      final jobData = {
        'title': _titleController.text.trim(),
        'price':
            int.tryParse(
              _payController.text.replaceAll(RegExp(r'[^0-9]'), ''),
            ) ??
            0,
        'company': _companyController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': selectedCategory,
        'posterId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'imageUrl': 'assets/images/placeholder.jpg',
      };

      final jobRef = await FirebaseFirestore.instance
          .collection('jobs')
          .add(jobData);

      // 🔔 Notify seekers about new job
      await FirebaseFirestore.instance.collection('notifications').add({
        'title': "New Job Posted",
        'message':
            "${_titleController.text} is now available under $selectedCategory.",
        'jobId': jobRef.id,
        'type': 'new_job',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Job posted successfully!")));

      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) Navigator.pop(context); // ✅ return smoothly to home
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error posting job: $e")));
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
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
        hintStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
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

  Widget _buildDropdown({
    required String? value,
    required String hintText,
    required IconData icon,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(hintText, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
          isExpanded: true,
          items: items
              .map(
                (String val) =>
                    DropdownMenuItem<String>(value: val, child: Text(val)),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
