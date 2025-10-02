// models/application.dart
class ApplicationModel {
  final String id;
  final String jobId;
  final String seekerId;
  final String status; // 'pending', 'accepted', 'denied'
  final int createdAt; // epoch millis

  ApplicationModel({
    required this.id,
    required this.jobId,
    required this.seekerId,
    required this.status,
    required this.createdAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> j) => ApplicationModel(
    id: j['id'] as String,
    jobId: j['jobId'] as String,
    seekerId: j['seekerId'] as String,
    status: j['status'] as String,
    createdAt: j['createdAt'] as int,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'jobId': jobId,
    'seekerId': seekerId,
    'status': status,
    'createdAt': createdAt,
  };
}
