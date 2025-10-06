import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  final String id;
  final String title;
  final int price;
  final String imageUrl;
  final String company;
  final String category;
  final String description;

  Job({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.company,
    required this.category,
    required this.description,
  });

  //  Convert Firestore document into Job object
  factory Job.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Job(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] is int)
          ? data['price']
          : int.tryParse(data['price'].toString()) ?? 0,
      company: data['company'] ?? '',
      category: data['category'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
    );
  }

  // Convert local Job object into Firestore-friendly Map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'price': price,
      'company': company,
      'category': category,
      'imageUrl': imageUrl,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}
