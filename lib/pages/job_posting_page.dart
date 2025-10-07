import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:quick_hire/pages/job_poster_home_page.dart';

class JobPostingPage extends StatefulWidget {
  const JobPostingPage({Key? key}) : super(key: key);

  @override
  State<JobPostingPage> createState() => _JobPostingPageState();
}

class _JobPostingPageState extends State<JobPostingPage> {
  String? selectedCategory;

  // Controllers
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
        title: Center(
          child: Text(
            'Post a Job',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
      body: Center(
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
                // Job Title
                const Text(
                  'Job Title',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(0, 45, 114, 1.0),
                  ),
                ),
                const SizedBox(height: 6),
                _buildTextField(
                  hint: 'Job title',
                  controller: _titleController,
                ),
                const SizedBox(height: 14),

                // Job Category
                const Text(
                  'Job Category',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(0, 45, 114, 1.0),
                  ),
                ),
                const SizedBox(height: 6),
                _buildDropdown(
                  value: selectedCategory,
                  hintText: 'Select category',
                  icon: Icons.work_outline,
                  items: categories,
                  onChanged: (val) => setState(() => selectedCategory = val),
                ),

                const SizedBox(height: 14),

                // Pay
                const Text(
                  'Pay (MWK)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(30, 58, 138, 1),
                  ),
                ),
                const SizedBox(height: 6),
                _buildTextField(
                  hint: 'e.g., 50,000',
                  keyboardType: TextInputType.number,
                  controller: _payController,
                  // inputFormatters: [
                  //   MoneyInputFormatter(
                  //     thousandSeparator: ThousandSeparator.Comma,
                  //   ),
                  // ],
                ),
                const SizedBox(height: 14),

                // Company Name
                const Text(
                  'Company Name',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(30, 58, 138, 1),
                  ),
                ),
                const SizedBox(height: 6),
                _buildTextField(
                  hint: 'Company name',
                  controller: _companyController,
                ),
                const SizedBox(height: 14),

                // Job Description
                const Text(
                  'Job Description',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
                const SizedBox(height: 6),
                _buildTextField(
                  hint: 'Write something...',
                  maxLines: 4,
                  controller: _descriptionController,
                ),
                const SizedBox(height: 20),

                // Post Job Button
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _postJob,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromRGBO(0, 45, 114, 1.0),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey[300],
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
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
    );
  }

  // Firebase integration
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

    try {
      final jobData = {
        'title': _titleController.text,
        'price':
            int.tryParse(
              _payController.text.replaceAll(RegExp(r'[^0-9]'), ''),
            ) ??
            0,
        'company': _companyController.text,
        'description': _descriptionController.text,
        'category': selectedCategory,
        'posterId': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
        'imageUrl': 'assets/images/placeholder.jpg', // Placeholder image
      };

      await FirebaseFirestore.instance.collection('jobs').add(jobData);

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Job posted successfully!")));

      // Clear fields
      _titleController.clear();
      _payController.clear();
      _companyController.clear();
      _descriptionController.clear();
      setState(() => selectedCategory = null);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error posting job: $e")));
    }

    //navigation
    Navigator.pop(
      context,
      MaterialPageRoute(builder: (context) => const JobPosterHomePage()),
    );
  }

  // widgets
  Widget _buildTextField({
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    TextEditingController? controller,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
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
