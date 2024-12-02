class Prescription {
  final int id;
  final String medicineName;
  final String dosage;
  final String usageInstructions;
  final DateTime createdAt;

  Prescription({
    required this.id,
    required this.medicineName,
    required this.dosage,
    required this.usageInstructions,
    required this.createdAt,
  });

  factory Prescription.fromJson(Map<String, dynamic> json) {
    return Prescription(
      id: json['id'] ?? 0,
      medicineName: json['medicine_name'] ?? '',
      dosage: json['dosage'] ?? '',
      usageInstructions: json['usage_instructions'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
    );
  }
}

class MedicalRecord {
  final int id;
  final String patientName;
  final String patientPhone;
  final String diagnosis;
  final String comment;
  final DateTime createdAt;
  final List<Prescription> prescriptions;

  MedicalRecord({
    required this.id,
    required this.patientName,
    required this.patientPhone,
    required this.diagnosis,
    required this.comment,
    required this.createdAt,
    required this.prescriptions,
  });

  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: json['id'] ?? 0,
      patientName: json['patient_name'] ?? '',
      patientPhone: json['patient_phone'] ?? '',
      diagnosis: json['diagnosis'] ?? '',
      comment: json['comment'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      prescriptions: (json['prescriptions'] as List?)
          ?.map((item) => Prescription.fromJson(item))
          .toList() ?? [],
    );
  }
}

class MedicalRecordResponse {
  final String status;
  final List<MedicalRecord> data;

  MedicalRecordResponse({
    required this.status,
    required this.data,
  });

  factory MedicalRecordResponse.fromJson(Map<String, dynamic> json) {
    return MedicalRecordResponse(
      status: json['status'] ?? 'error',
      data: (json['data'] as List?)
          ?.map((item) => MedicalRecord.fromJson(item))
          .toList() ?? [],
    );
  }
} 