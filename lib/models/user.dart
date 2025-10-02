// models/user.dart
//import 'dart:convert';

class User {
  final String id;
  final String role; // 'seeker' or 'poster'
  final String name;
  final String dob; // yyyy-mm-dd
  final String gender; // 'male'|'female'
  final String phone;
  final String password; // plain text for prototype (NOT for production)
  final String location;
  final String? experience; // only for seekers

  User({
    required this.id,
    required this.role,
    required this.name,
    required this.dob,
    required this.gender,
    required this.phone,
    required this.password,
    required this.location,
    this.experience,
  });

  factory User.fromJson(Map<String, dynamic> j) => User(
    id: j['id'] as String,
    role: j['role'] as String,
    name: j['name'] as String,
    dob: j['dob'] as String,
    gender: j['gender'] as String,
    phone: j['phone'] as String,
    password: j['password'] as String,
    location: j['location'] as String,
    experience: j['experience'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'role': role,
    'name': name,
    'dob': dob,
    'gender': gender,
    'phone': phone,
    'password': password,
    'location': location,
    'experience': experience,
  };
}
