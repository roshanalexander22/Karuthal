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
        final parsed = list
            .map((e) => ReminderModel.fromJson(e as Map<String, dynamic>))
            .toList();
        if (parsed.isNotEmpty) return parsed;
      }
    } catch (e) {
      AppLogger.w('Failed to fetch reminders, using baseline: $e');
    }
    return [
      ReminderModel(
        id: '1',
        title: 'പ്രഷർ മരുന്ന് (Telmisartan 40mg)',
        description: 'Telmisartan 40mg',
        dosage: '1 ഗുളിക (1 Tablet)',
        instructionsMl: 'രാവിലെ പ്രഭാതഭക്ഷണത്തിന് ശേഷം',
        scheduledTime: DateTime.now().copyWith(hour: 8, minute: 0),
      ),
      ReminderModel(
        id: '2',
        title: 'ഷുഗർ മരുന്ന് (Metformin 500mg)',
        description: 'Metformin 500mg',
        dosage: '1 ഗുളിക (1 Tablet)',
        instructionsMl: 'ഉച്ചഭക്ഷണത്തിന് മുൻപ്',
        scheduledTime: DateTime.now().copyWith(hour: 13, minute: 30),
      ),
      ReminderModel(
        id: '3',
        title: 'കൊളസ്ട്രോൾ ഗുളിക (Atorvastatin 10mg)',
        description: 'Atorvastatin 10mg',
        dosage: '1 ഗുളിക (1 Tablet)',
        instructionsMl: 'രാത്രി ഉറങ്ങാൻ നേരം',
        scheduledTime: DateTime.now().copyWith(hour: 21, minute: 0),
      ),
    ];
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
      await _apiClient.post<dynamic>(
          '${ApiEndpoints.reminderList}/$reminderId/acknowledge');
    } catch (e) {
      AppLogger.e('Failed to acknowledge reminder dose: $e');
    }
  }

  Future<void> updateReminder(
      String reminderId, Map<String, dynamic> data) async {
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
      await _apiClient
          .delete<dynamic>('${ApiEndpoints.reminderList}/$reminderId');
    } catch (e) {
      AppLogger.e('Failed to delete reminder: $e');
      rethrow;
    }
  }
}
