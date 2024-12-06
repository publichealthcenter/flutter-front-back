import 'package:untitled/models/medical_record.dart';

class AcceptanceModel {
  final int id;
  final int patientId;
  final int checkinId;
  final String patientName;
  final String patientPhone;
  final String diagnosis;
  final String comment;
  final bool purchase;
  final int price;
  final DateTime createdAt;
  final List<Prescription> prescriptions;

  AcceptanceModel({
    required this.id,
    required this.patientId,
    required this.checkinId,
    required this.patientName,
    required this.patientPhone,
    required this.diagnosis,
    required this.comment,
    required this.purchase,
    required this.price,
    required this.createdAt,
    required this.prescriptions,
  });

  factory AcceptanceModel.fromJson(Map<String, dynamic> json) {
    return AcceptanceModel(
      id: json['id'] ?? 0,
      patientId: json['patient_id'] ?? 0,
      checkinId: json['checkin_id'] ?? 0,
      patientName: json['patient_name'] ?? '',
      patientPhone: json['patient_phone'] ?? '',
      diagnosis: json['diagnosis'] ?? '',
      comment: json['comment'] ?? '',
      purchase: json['purchase'] ?? false,
      price: json['price'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      prescriptions: (json['prescriptions'] as List?)
              ?.map((item) => Prescription.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class AcceptanceResponse {
  final String status;
  final List<AcceptanceModel> data;

  AcceptanceResponse({
    required this.status,
    required this.data,
  });

  factory AcceptanceResponse.fromJson(Map<String, dynamic> json) {
    return AcceptanceResponse(
      status: json['status'] ?? 'error',
      data: (json['data'] as List?)
              ?.map((item) => AcceptanceModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}
