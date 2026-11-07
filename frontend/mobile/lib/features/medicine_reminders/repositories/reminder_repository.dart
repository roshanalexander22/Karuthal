import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/reminder_model.dart';

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ReminderRepository(apiClient);
});

class ReminderRepository {
  final ApiClient _apiClient;

  ReminderRepository(this._apiClient);

  Future<List<ReminderModel>> getReminders() async {
    try {
      final response = await _apiClient.get<dynamic>(ApiEndpoints.reminderList);
      if (response.data is Map<String, dynamic>) {
        final list = response.data['reminders'] as List<dynamic>? ?? [];
        return list
            .map((e) => ReminderModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      AppLogger.e('Failed to fetch reminders: $e');
      return [];
    }
  }

  Future<ReminderModel> createReminder(ReminderModel reminder) async {
    try {
      final response = await _apiClient.post<dynamic>(
        ApiEndpoints.reminderCreate,
        data: reminder.toJson(),
      );
      return ReminderModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      AppLogger.e('Failed to create reminder: $e');
      rethrow;
    }
  }

  Future<void> acknowledgeDose(String reminderId) async {
    try {
      await _apiClient.post<dynamic>('${ApiEndpoints.reminderList}/$reminderId/acknowledge');
    } catch (e) {
      AppLogger.e('Failed to acknowledge reminder dose: $e');
    }
  }

  Future<void> updateReminder(String reminderId, Map<String, dynamic> data) async {
    try {
      await _apiClient.patch<dynamic>(
        '${ApiEndpoints.reminderList}/$reminderId',
        data: data,
      );
    } catch (e) {
      AppLogger.e('Failed to update reminder: $e');
      rethrow;
    }
  }

  Future<void> deleteReminder(String reminderId) async {
    try {
      await _apiClient.delete<dynamic>('${ApiEndpoints.reminderList}/$reminderId');
    } catch (e) {
      AppLogger.e('Failed to delete reminder: $e');
      rethrow;
    }
  }
}
