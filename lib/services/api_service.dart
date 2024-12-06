import 'package:dio/dio.dart';
import 'package:untitled/models/acceptance_model.dart';
import 'package:untitled/models/checkin.dart';
import 'package:untitled/models/medical_record.dart';

class ApiService {
  final Dio _dio;
  static const String baseUrl = 'http://180.65.58.182:8000'; // 실제 서버 URL 추가

  ApiService() : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
  ));

  Future<List<CheckIn>> getCheckins() async {
    try {
      final response = await _dio.get('/checkins');
      print('Checkins API Response: ${response.data}');
      
      if (response.data['status'] == 'success') {
        final checkinResponse = CheckInResponse.fromJson(response.data);
        return checkinResponse.data;
      } else {
        throw Exception('API 응답 실패: ${response.data}');
      }
    } on DioException catch (e) {
      print('Dio error: ${e.message}');
      print('Response: ${e.response?.data}');
      throw _handleDioError(e);
    } catch (e) {
      print('Other error: $e');
      throw Exception('체크인 목록을 불러오는데 실패했습니다: $e');
    }
  }

  Future<List<MedicalRecord>> getMedicalRecords(int patientId) async {
    try {
      final response = await _dio.get('/medical-records/$patientId');
      
      if (response.data['status'] == 'success') {
        final medicalRecordResponse = MedicalRecordResponse.fromJson(response.data);
        return medicalRecordResponse.data;
      } else {
        throw Exception('의료 기록 API 응답 실패: ${response.data}');
      }
    } on DioException catch (e) {
      print('Dio error: ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      print('Other error: $e');
      throw Exception('의료 기록을 불러오는데 실패했습니다: $e');
    }
  }

  Future<List<AcceptanceModel>> getAcceptanceRecord(String phoneNum) async {
    try {
      final response = await _dio.get('/medical-records/phone/$phoneNum');
      print('Acceptance API Response: ${response.data}');

      if (response.data['status'] == 'success') {
        final acceptanceResponse = AcceptanceResponse.fromJson(response.data);
        return acceptanceResponse.data;
      } else {
        throw Exception('수납 API 응답 실패: ${response.data}');
      }
    } on DioException catch (e) {
      print('Dio error: ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      print('Other error: $e');
      throw Exception('수납 기록을 불러오는데 실패했습니다: $e');
    }
  }

  Future<void> postMedicalRecord(int patientId, String diagnosis, String comment, List<Map<String, String>> prescriptions) async {
    try {
      final response = await _dio.post('/medical-records', data: {
        'patient_id': patientId,
        'diagnosis': diagnosis,
        'comment': comment,
        'prescriptions': prescriptions,
      });
      print('Post response: ${response.data}');
    } on DioException catch (e) {
      print('Dio error: ${e.message}');
      throw _handleDioError(e);
    } catch (e) {
      print('Other error: $e');
      throw Exception('의료 기록 전송에 실패했습니다: $e');
    }
  }

  Exception _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('서버 연결 시간이 초과되었습니다.');
      case DioExceptionType.badResponse:
        return Exception('서버 응답 오류: ${e.response?.statusCode} - ${e.response?.data}');
      case DioExceptionType.cancel:
        return Exception('요청이 취소되었습니다.');
      default:
        return Exception('네트워크 오류가 발생했습니다: ${e.message}');
    }
  }
} 