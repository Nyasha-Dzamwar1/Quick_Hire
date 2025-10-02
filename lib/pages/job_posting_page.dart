import 'package:flutter/material.dart';

class JobPostingPage extends StatefulWidget {
  const JobPostingPage({Key? key}) : super(key: key);

  @override
  State<JobPostingPage> createState() => _JobPostingPageState();
}

class _JobPostingPageState extends State<JobPostingPage> {
  String? selectedCategory;
  String? selectedLocation;

  final List<String> categories = [
    'Gardener',
    'Plumber',
    'Electrician',
    'Carpenter',
    'Painter',
    'Cleaner',
  ];

  final List<String> locations = [
    'Ndirande, Blantyre',
    'Limbe, Blantyre',
    'Chilomoni, Blantyre',
    'City Centre, Blantyre',
  ];

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
                _buildTextField(hint: 'Job title'),

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
                ),

                const SizedBox(height: 14),

                // Location
                const Text(
                  'Location',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color.fromRGBO(30, 58, 138, 1),
                  ),
                ),
                const SizedBox(height: 6),
                _buildTextField(hint: 'Location'),

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
                _buildTextField(hint: 'Company name'),

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
                _buildTextField(hint: 'Write something...', maxLines: 4),

                const SizedBox(height: 20),

                // Post Job Button
                SizedBox(
                  height: 56,
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromRGBO(0, 45, 114, 1.0),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey[300],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Post a Job',
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
      ),
    );
  }

  //widgets

  Widget _buildTextField({
    String? hint,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
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
          padding: const EdgeInsets.symmetric(horizontal: 12),
          items: items.map((String val) {
            return DropdownMenuItem<String>(value: val, child: Text(val));
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
