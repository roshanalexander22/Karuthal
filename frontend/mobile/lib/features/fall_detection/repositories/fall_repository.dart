import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';

final fallRepositoryProvider = Provider<FallRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return FallRepository(apiClient);
});

class FallRepository {
  final ApiClient _apiClient;

  FallRepository(this._apiClient);

  Future<Map<String, dynamic>> reportFall({
    double confidence = 0.94,
    Map<String, dynamic>? sensorSummary,
    bool wasCancelledByUser = false,
  }) async {
    try {
      final response = await _apiClient.post<dynamic>(
        ApiEndpoints.fallReport,
        data: {
          'confidence_score': confidence,
          'sensor_summary': sensorSummary ?? {'peak_impact_g': 3.1},
          'was_cancelled_by_user': wasCancelledByUser,
        },
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      AppLogger.e('Fall report error: $e');
      rethrow;
    }
  }

  Future<void> cancelFallEvent(String eventId) async {
    try {
      await _apiClient.post<dynamic>('${ApiEndpoints.fallSettings}/events/$eventId/cancel');
    } catch (e) {
      AppLogger.e('Fall cancel error: $e');
    }
  }

  Future<Map<String, dynamic>> getSettings() async {
    try {
      final response = await _apiClient.get<dynamic>(ApiEndpoints.fallSettings);
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {'sensitivity': 'MEDIUM', 'countdown_seconds': 30};
    } catch (e) {
      AppLogger.e('Fall settings error: $e');
      return {'sensitivity': 'MEDIUM', 'countdown_seconds': 30};
    }
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    try {
      await _apiClient.patch<dynamic>(
        ApiEndpoints.fallSettingsUpdate,
        data: settings,
      );
    } catch (e) {
      AppLogger.e('Fall settings update error: $e');
    }
  }
}
