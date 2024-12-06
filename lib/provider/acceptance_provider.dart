import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:untitled/models/acceptance_model.dart';
import 'package:untitled/services/api_service.dart';

final apiServiceProvider = Provider((ref) => ApiService());

final acceptanceDetailProvider = StateNotifierProvider<AcceptanceDetailNotifier, AcceptanceDetailState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return AcceptanceDetailNotifier(apiService);
});

class AcceptanceDetailState {
  final List<AcceptanceModel> acceptanceRecords;
  final bool isLoading;
  final String? error;

  AcceptanceDetailState({
    this.acceptanceRecords = const [],
    this.isLoading = false,
    this.error,
  });

  AcceptanceDetailState copyWith({
    List<AcceptanceModel>? acceptanceRecords,
    bool? isLoading,
    String? error,
  }) {
    return AcceptanceDetailState(
      acceptanceRecords: acceptanceRecords ?? this.acceptanceRecords,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class AcceptanceDetailNotifier extends StateNotifier<AcceptanceDetailState> {
  final ApiService _apiService;

  AcceptanceDetailNotifier(this._apiService) : super(AcceptanceDetailState());

  Future<void> fetchAcceptanceRecords(String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final records = await _apiService.getAcceptanceRecord(phoneNumber);
      state = state.copyWith(
        acceptanceRecords: records,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}