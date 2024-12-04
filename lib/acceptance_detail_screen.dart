import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:untitled/models/acceptance_model.dart';
import 'package:untitled/provider/acceptance_provider.dart';

class AcceptanceDetailScreen extends ConsumerStatefulWidget {
  final String phoneNumber;

  const AcceptanceDetailScreen({super.key, required this.phoneNumber});

  @override
  _AcceptanceDetailScreenState createState() => _AcceptanceDetailScreenState();
}

class _AcceptanceDetailScreenState extends ConsumerState<AcceptanceDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch acceptance records when the screen is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(acceptanceDetailProvider.notifier).fetchAcceptanceRecords(widget.phoneNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    final acceptanceState = ref.watch(acceptanceDetailProvider);

    if (acceptanceState.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (acceptanceState.error != null) {
      return Scaffold(
        body: Center(
          child: Text('Error: ${acceptanceState.error}'),
        ),
      );
    }

    if (acceptanceState.acceptanceRecords.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text('No acceptance records found'),
        ),
      );
    }

    // Take the first record for displaying details
    final record = acceptanceState.acceptanceRecords.first;

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 6,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더 부분
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '상명대병원',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF006064),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '원장: 배동성',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Image.asset(
                        'assets/medical_logo.jpg',
                        width: 200,
                        height: 80,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 32),
              const Text(
                '처방전',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF006064),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              // 환자 정보
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildInfoRow('환자명', record.patientName),
                    const SizedBox(height: 12),
                    _buildInfoRow('환자 ID', record.patientId.toString()),
                    const SizedBox(height: 12),
                    _buildInfoRow('환자 전화번호', record.patientPhone),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                        '진료일',
                        DateFormat('yyyy년 MM월 dd일').format(record.createdAt)
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // 진단 및 처방
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildPrescriptionDetails(record),
              ),
              const SizedBox(height: 32),
              // 수납 정보
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '수납 정보',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('총 진료비', '${NumberFormat('#,###').format(record.price)}원'),
                    const SizedBox(height: 8),
                    _buildInfoRow('수납 상태', record.purchase ? '수납 완료' : '미수납'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // 서명
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text('담당의사: 배동성'),
                      const SizedBox(height: 24),
                      Container(
                        width: 120,
                        height: 2,
                        color: Colors.black,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF006064),
            ),
          ),
        ),
        const Text(' : '),
        Expanded(
          child: Text(value),
        ),
      ],
    );
  }

  Widget _buildPrescriptionDetails(AcceptanceModel record) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '진단 정보',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        _buildInfoRow('진단명', record.diagnosis),
        const SizedBox(height: 12),
        _buildInfoRow('특이사항', record.comment.isNotEmpty ? record.comment : '없음'),
        const SizedBox(height: 24),
        const Text(
          '처방 내역',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        if (record.prescriptions.isNotEmpty)
          ...record.prescriptions.map((prescription) => Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _buildInfoRow(
              prescription.medicineName,
              '${prescription.dosage} / ${prescription.usageInstructions}',
            ),
          ))
        else
          const Text('처방된 약품 없음'),
      ],
    );
  }
}