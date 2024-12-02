import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/checkin.dart';
import '../models/medical_record.dart';
import 'package:intl/intl.dart';


class Backoffice extends StatefulWidget {
  const Backoffice({super.key});

  @override
  State<Backoffice> createState() => _BackofficeState();
}

class _BackofficeState extends State<Backoffice> {
  final ApiService _apiService = ApiService();
  List<CheckIn> checkins = [];
  CheckIn? selectedCheckin;
  List<MedicalRecord> medicalRecords = [];
  bool isLoading = false;
  bool isLoadingRecords = false;
  String? error;
  
  // 처방 입력 필드 컨트롤러들
  final List<Map<String, TextEditingController>> prescriptionControllers = [];
  // 진단과 비고를 위한 컨트롤러
  final TextEditingController diagnosisController = TextEditingController();
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCheckins();
    _addPrescriptionField();
  }

  @override
  void dispose() {
    // 컨트롤러들 해제
    diagnosisController.dispose();
    commentController.dispose();
    for (var controllers in prescriptionControllers) {
      controllers.values.forEach((controller) => controller.dispose());
    }
    super.dispose();
  }

  void _addPrescriptionField() {
    setState(() {
      prescriptionControllers.add({
        'medicineName': TextEditingController(),
        'dosage': TextEditingController(),
        'usageInstructions': TextEditingController(),
      });
    });
  }

  void _clearPrescriptionFields() {
    setState(() {
      // 기존 컨트롤러들 해제
      for (var controllers in prescriptionControllers) {
        controllers.values.forEach((controller) => controller.dispose());
      }
      prescriptionControllers.clear();
      // 새로운 빈 필드 추가
      _addPrescriptionField();
      // 진단과 비고 초기화
      diagnosisController.clear();
      commentController.clear();
    });
  }

  // 진료 완료 처리
  Future<void> _completeMedicalRecord() async {
    if (selectedCheckin == null) return;

    final prescriptions = prescriptionControllers.map((controllers) {
      return {
        'medicine_name': controllers['medicineName']!.text,
        'dosage': controllers['dosage']!.text,
        'usage_instructions': controllers['usageInstructions']!.text,
      };
    }).toList();

    try {
      await _apiService.postMedicalRecord(
        selectedCheckin!.patientId,
        diagnosisController.text,
        commentController.text,
        prescriptions,
      );
      
      setState(() {
        selectedCheckin = null;
        medicalRecords = [];
      });
      _clearPrescriptionFields();
      _loadCheckins(); // 환자 목록 새로고침
    } catch (e) {
      // 에러 처리
      print('Error: $e');
      // 사용자에게 에러 메시지 표시
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('진료 기록 저장에 실패했습니다: $e')),
      );
    }
  }

  Future<void> _loadCheckins() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final loadedCheckins = await _apiService.getCheckins();
      setState(() {
        checkins = loadedCheckins;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadMedicalRecords(int patientId) async {
    setState(() {
      isLoadingRecords = true;
      error = null;
    });

    try {
      final records = await _apiService.getMedicalRecords(patientId);
      setState(() {
        medicalRecords = records;
        isLoadingRecords = false;
      });
    } catch (e) {
      print('Error loading medical records: $e');
      setState(() {
        // 에러가 발생해도 selectedCheckin은 유지
        medicalRecords = []; // 빈 리스트로 설정
        isLoadingRecords = false;
        error = null; // 에러 메시지 표시하지 않음
      });
    }
  }

  // 중복 제거된 체크인 목록을 반환하는 getter
  List<CheckIn> get uniqueCheckins {
    final Map<int, CheckIn> uniqueMap = {};
    for (var checkIn in checkins) {
      uniqueMap[checkIn.patientId] = checkIn;
    }
    return uniqueMap.values.toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  // 환자 리스트
                  Expanded(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomScrollView(
                        slivers: [
                          const SliverPersistentHeader(
                            pinned: true,
                            delegate: _SliverHeaderDelegate(
                              title: '진료 대기 환자 목록',
                              height: 50,
                            ),
                          ),
                          SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                if (isLoading) {
                                  return const Center(child: CircularProgressIndicator());
                                }

                                if (error != null) {
                                  return Center(child: Text(error!));
                                }

                                if (uniqueCheckins.isEmpty) {
                                  return const Center(child: Text('대기 중인 환자가 없습니다.'));
                                }

                                final checkin = uniqueCheckins[index];
                                final isSelected = selectedCheckin?.id == checkin.id;

                                return Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                      ? const Color(0xFFBBDEFB)
                                      : (index % 2 == 0 ? const Color(0xFFF5F5F5) : Colors.white),
                                    border: Border(
                                      bottom: BorderSide(color: Colors.grey.shade300, width: 0.5),
                                    ),
                                  ),
                                  child: ListTile(
                                    title: Text(
                                      checkin.patientName,
                                      style: TextStyle(
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                    subtitle: Text('ID: ${checkin.patientId}'),
                                    selected: isSelected,
                                    onTap: () {
                                      setState(() {
                                        selectedCheckin = checkin;
                                      });
                                      _loadMedicalRecords(checkin.patientId);
                                    },
                                  ),
                                );
                              },
                              childCount: isLoading ? 1 : uniqueCheckins.length,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 환자 상세정보
                  Expanded(
                    flex: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomScrollView(
                        slivers: [
                          const SliverPersistentHeader(
                            pinned: true,
                            delegate: _SliverHeaderDelegate(
                              title: '환자 상세정보',
                              height: 50,
                            ),
                          ),
                          SliverPadding(
                            padding: const EdgeInsets.all(16.0),
                            sliver: SliverList(
                              delegate: SliverChildListDelegate([
                                if (selectedCheckin != null) ...[
                                  Text('환자 정보', 
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade200),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        _buildInfoRow('이름', selectedCheckin!.patientName),
                                        const SizedBox(height: 8),
                                        _buildInfoRow('환자 ID', selectedCheckin!.patientId.toString()),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  if (isLoadingRecords)
                                    const Center(child: CircularProgressIndicator())
                                  else if (medicalRecords.isEmpty)
                                    Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[50],
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey.shade200),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          '이전 진료 기록이 없습니다.',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    )
                                  else ...[
                                    Text('진료 기록', 
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                    const SizedBox(height: 16),
                                    ...medicalRecords.map((record) => Padding(
                                      padding: const EdgeInsets.only(bottom: 16),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey.shade200),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.grey.withOpacity(0.1),
                                              spreadRadius: 1,
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                        child: ExpansionTile(
                                          title: Text(
                                            DateFormat('yyyy년 MM월 dd일').format(record.createdAt),
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          subtitle: Text(record.diagnosis),
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  _buildSectionTitle('진단'),
                                                  Text(record.diagnosis),
                                                  const SizedBox(height: 16),
                                                  _buildSectionTitle('비고'),
                                                  Text(record.comment),
                                                  const SizedBox(height: 16),
                                                  _buildSectionTitle('처방 내역'),
                                                  ...record.prescriptions.map((prescription) => Container(
                                                    margin: const EdgeInsets.only(top: 8),
                                                    padding: const EdgeInsets.all(12),
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[50],
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          prescription.medicineName,
                                                          style: const TextStyle(fontWeight: FontWeight.bold),
                                                        ),
                                                        const SizedBox(height: 4),
                                                        Text('용량: ${prescription.dosage}'),
                                                        Text('복용법: ${prescription.usageInstructions}'),
                                                      ],
                                                    ),
                                                  )).toList(),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )).toList(),
                                  ],
                                ] else
                                  const Center(
                                    child: Text('환자를 선택해주세요'),
                                  ),
                              ]),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // 오방전
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: CustomScrollView(
                      slivers: [
                        const SliverPersistentHeader(
                          pinned: true,
                          delegate: _SliverHeaderDelegate(
                            title: '처방전',
                            height: 50,
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.all(1.0),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              if (selectedCheckin != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(24.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
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
                                      // 처방전 폼
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
                                            _buildInfoRow('환자명', selectedCheckin!.patientName),
                                            const SizedBox(height: 12),
                                            _buildInfoRow('환자 번호', selectedCheckin!.patientId.toString()),
                                            const SizedBox(height: 12),
                                            _buildInfoRow('진료일', DateFormat('yyyy년 MM월 dd일').format(DateTime.now())),
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
                                        child: _buildPrescriptionInputs(),
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
                              ] else
                                const Center(
                                  child: Text('환자를 선택해주세요'),
                                ),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: ElevatedButton(
                      onPressed: selectedCheckin != null
                          ? () async {
                              final prescriptions = prescriptionControllers.map((controllers) {
                                return {
                                  'medicine_name': controllers['medicineName']!.text,
                                  'dosage': controllers['dosage']!.text,
                                  'usage_instructions': controllers['usageInstructions']!.text,
                                };
                              }).toList();

                              try {
                                await _apiService.postMedicalRecord(
                                  selectedCheckin!.patientId,
                                  diagnosisController.text,
                                  commentController.text,
                                  prescriptions,
                                );
                                setState(() {
                                  selectedCheckin = null;
                                  medicalRecords = [];
                                  prescriptionControllers.clear();
                                });
                              } catch (e) {
                                print('Error: $e');
                              }

                              diagnosisController.clear();
                              commentController.clear();
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                      ),
                      child: const Text('진료완료'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrescriptionInputs() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '진료 정보 입력',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: diagnosisController,
            decoration: const InputDecoration(
              labelText: '진단',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: commentController,
            decoration: const InputDecoration(
              labelText: '비고',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            '처방 입력',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...prescriptionControllers.map((controllers) {
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    TextField(
                      controller: controllers['medicineName'],
                      decoration: const InputDecoration(
                        labelText: '약품명',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controllers['dosage'],
                      decoration: const InputDecoration(
                        labelText: '용량',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: controllers['usageInstructions'],
                      decoration: const InputDecoration(
                        labelText: '복용법',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: _addPrescriptionField,
                icon: const Icon(Icons.add),
                label: const Text('처방 추가'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF006064),
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
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final double height;

  const _SliverHeaderDelegate({
    required this.title,
    required this.height,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      height: height,
      color: Colors.grey[200],
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => height;

  @override
  double get minExtent => height;

  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) {
    return false;
  }
}
