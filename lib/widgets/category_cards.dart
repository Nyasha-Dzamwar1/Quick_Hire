import 'package:flutter/material.dart';
//import 'package:quick_hire/global_variables.dart';

class CategoryCards extends StatelessWidget {
  final String title;
  final int price;
  final String image;
  final String campany;
  final String description;

  const CategoryCards({
    super.key,
    required this.title,
    required this.price,
    required this.image,
    required this.campany,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Color.fromRGBO(0, 45, 114, 1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                image,
                height: 90,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
