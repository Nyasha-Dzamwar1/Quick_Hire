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

  factory Job.fromJson(Map<String, dynamic> json) {
    return Job(
      id: json['id'],
      title: json['title'],
      price: json['price'],
      imageUrl: json['imageUrl'],
      company: json['company'],
      category: json['category'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'price': price,
      'imageUrl': imageUrl,
      'company': company,
      'category': category,
      'description': description,
    };
  }
}
