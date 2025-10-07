class Application {
  final String id;
  final String jobId;
  final String seekerId;
  final String status;

  Application({
    required this.id,
    required this.jobId,
    required this.seekerId,
    required this.status,
  });

  // Convert from Firestore document
  factory Application.fromMap(String id, Map<String, dynamic> data) {
    return Application(
      id: id,
      jobId: data['jobId'] ?? '',
      seekerId: data['seekerId'] ?? '',
      status: data['status'] ?? 'pending',
    );
  }

  // Convert to Map for saving in Firestore
  Map<String, dynamic> toMap() {
    return {'jobId': jobId, 'seekerId': seekerId, 'status': status};
  }
}
