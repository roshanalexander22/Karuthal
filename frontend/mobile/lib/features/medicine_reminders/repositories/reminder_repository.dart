import 'package:flutter/services.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';

class ReminderModel {
  final String id;
  final String title;
  final String? description;
  final String reminderType;
  final DateTime scheduledTime;
  final String? recurrenceRule;
  final String? dosage;
  final String? doctorName;
  final String? hospitalName;
  final bool isActive;
  final String status;

  ReminderModel({
    required this.id,
    required this.title,
    this.description,
    this.reminderType = 'MEDICINE',
    required this.scheduledTime,
    this.recurrenceRule = 'DAILY',
    this.dosage,
    this.doctorName,
    this.hospitalName,
    this.isActive = true,
    this.status = 'PENDING',
  });

  factory ReminderModel.fromJson(Map<String, dynamic> json) {
    return ReminderModel(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      reminderType: json['reminder_type']?.toString() ?? 'MEDICINE',
      scheduledTime: DateTime.tryParse(json['scheduled_time']?.toString() ?? '') ?? DateTime.now(),
      recurrenceRule: json['recurrence_rule']?.toString(),
      dosage: json['dosage']?.toString(),
      doctorName: json['doctor_name']?.toString(),
      hospitalName: json['hospital_name']?.toString(),
      isActive: json['is_active'] ?? true,
      status: json['status']?.toString() ?? 'PENDING',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'reminder_type': reminderType,
      'scheduled_time': scheduledTime.toUtc().toIso8601String(),
      'recurrence_rule': recurrenceRule,
      'dosage': dosage,
      'doctor_name': doctorName,
      'hospital_name': hospitalName,
    };
  }
}

class ReminderRepository {
  final ApiClient _apiClient;
  static const _nativeChannel = MethodChannel('sahaayi/reminders');

  ReminderRepository(this._apiClient);

  Future<List<ReminderModel>> getReminders() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.reminderList);
      final data = response.data as Map<String, dynamic>;
      final list = data['reminders'] as List<dynamic>? ?? [];
      return list.map((item) => ReminderModel.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.w('Fetch reminders fallback: $e');
      return [
        ReminderModel(
          id: 'mock-rem-1',
          title: 'പാരസെറ്റാമോൾ (Paracetamol)',
          reminderType: 'MEDICINE',
          dosage: '500mg, 1 ഗുളിക',
          scheduledTime: DateTime.now().add(const Duration(hours: 2)),
          recurrenceRule: 'DAILY',
        ),
        ReminderModel(
          id: 'mock-rem-2',
          title: 'ഡോക്ടർ സന്ദർശനം (Cardiologist)',
          reminderType: 'APPOINTMENT',
          doctorName: 'Dr. Suresh Kumar',
          hospitalName: 'മെഡിക്കൽ കോളേജ്, തിരുവനന്തപുരം',
          scheduledTime: DateTime.now().add(const Duration(days: 1, hours: 4)),
        ),
      ];
    }
  }

  Future<ReminderModel> createReminder(ReminderModel reminder) async {
    try {
      final response = await _apiClient.post(
        ApiEndpoints.reminderCreate,
        data: reminder.toJson(),
      );
      final created = ReminderModel.fromJson(response.data as Map<String, dynamic>);

      // Schedule exact local alarm via native Android AlarmManager
      try {
        await _nativeChannel.invokeMethod('scheduleReminder', {
          'reminderId': created.id,
          'title': created.title,
          'message': created.reminderType == 'MEDICINE'
              ? 'മരുന്ന് കഴിക്കാനുള്ള സമയം: ${created.dosage ?? ''}'
              : 'ആശുപത്രി സന്ദർശനം: ${created.hospitalName ?? ''}',
          'triggerAtMillis': created.scheduledTime.millisecondsSinceEpoch,
        });
      } catch (nativeErr) {
        AppLogger.w('Native alarm schedule warning: $nativeErr');
      }

      return created;
    } catch (e) {
      AppLogger.e('Create reminder error: $e');
      rethrow;
    }
  }

  Future<void> acknowledgeReminder(String id) async {
    try {
      await _apiClient.post('${ApiEndpoints.reminderAcknowledge}/$id/acknowledge');
    } catch (e) {
      AppLogger.e('Acknowledge reminder error: $e');
    }
  }

  Future<bool> deleteReminder(String id) async {
    try {
      await _apiClient.delete('${ApiEndpoints.reminderDetail}/$id');
      return true;
    } catch (e) {
      AppLogger.e('Delete reminder error: $e');
      return false;
    }
  }
}
