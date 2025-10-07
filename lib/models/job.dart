import 'package:cloud_firestore/cloud_firestore.dart';

class Job {
  final String id;
  final String title;
  final int price;
  final String imageUrl;
  final String company;
  final String category;
  final String description;
  final String posterEmail;
  final String posterPhone;

  Job({
    required this.id,
    required this.title,
    required this.price,
    required this.imageUrl,
    required this.company,
    required this.category,
    required this.description,
    required this.posterEmail,
    required this.posterPhone,
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
      posterEmail: data['posterEmail'] ?? '',
      posterPhone: data['posterPhone'] ?? '',
    );
  }

  // Convert local Job object into Firestore-friendly Map
  Map<String, dynamic> toFirestore({
    required String posterEmail,
    required String posterPhone,
  }) {
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
