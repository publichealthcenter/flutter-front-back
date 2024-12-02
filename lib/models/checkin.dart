class CheckIn {
  final int id;
  final int patientId;
  final String patientName;

  CheckIn({
    required this.id,
    required this.patientId,
    required this.patientName,
  });

  factory CheckIn.fromJson(Map<String, dynamic> json) {
    return CheckIn(
      id: json['id'] ?? 0,
      patientId: json['patient_id'] ?? 0,
      patientName: json['patient_name'] ?? '',
    );
  }
}

class CheckInResponse {
  final String status;
  final List<CheckIn> data;

  CheckInResponse({
    required this.status,
    required this.data,
  });

  factory CheckInResponse.fromJson(Map<String, dynamic> json) {
    return CheckInResponse(
      status: json['status'] ?? 'error',
      data: (json['data'] as List?)
          ?.map((item) => CheckIn.fromJson(item))
          .toList() ?? [],
    );
  }
} 