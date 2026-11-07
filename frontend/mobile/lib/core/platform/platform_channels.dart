import 'package:flutter/services.dart';

/// PlatformChannels
///
/// Central Dart platform interface mapping to native Android services:
/// - MethodChannels:
///   - sahaayi/accessibility
///   - sahaayi/autofill
///   - sahaayi/sensors
///   - sahaayi/tts
///   - sahaayi/reminders
/// - EventChannels:
///   - sahaayi/sensor_events
///   - sahaayi/fall_events
class PlatformChannels {
  static const MethodChannel accessibility = MethodChannel('sahaayi/accessibility');
  static const MethodChannel autofill = MethodChannel('sahaayi/autofill');
  static const MethodChannel sensors = MethodChannel('sahaayi/sensors');
  static const MethodChannel tts = MethodChannel('sahaayi/tts');
  static const MethodChannel reminders = MethodChannel('sahaayi/reminders');

  static const EventChannel sensorEvents = EventChannel('sahaayi/sensor_events');
  static const EventChannel fallEvents = EventChannel('sahaayi/fall_events');

  // --- Accessibility Service ---
  static Future<bool> isAccessibilityServiceActive() async {
    try {
      final bool? active = await accessibility.invokeMethod<bool>('isAccessibilityServiceEnabled');
      return active ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<void> openAccessibilitySettings() async {
    try {
      await accessibility.invokeMethod('openAccessibilitySettings');
    } catch (_) {}
  }

  static Future<List<Map<dynamic, dynamic>>> requestScreenRead() async {
    try {
      final List<dynamic>? elements = await accessibility.invokeListMethod('requestScreenRead');
      if (elements == null) return [];
      return elements.cast<Map<dynamic, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  static Future<bool> injectFieldValue(String nodeId, String value) async {
    try {
      final bool? success = await accessibility.invokeMethod<bool>('injectFieldValue', {
        'nodeId': nodeId,
        'value': value,
      });
      return success ?? false;
    } catch (_) {
      return false;
    }
  }

  // --- Autofill Framework ---
  static Future<bool> isAutofillSupported() async {
    try {
      final bool? supported = await autofill.invokeMethod<bool>('isAutofillSupported');
      return supported ?? false;
    } catch (_) {
      return false;
    }
  }

  // --- Sensor Monitoring & Telemetry ---
  static Future<void> startSensorMonitoring() async {
    try {
      await sensors.invokeMethod('startSensorMonitoring');
    } catch (_) {}
  }

  static Future<void> stopSensorMonitoring() async {
    try {
      await sensors.invokeMethod('stopSensorMonitoring');
    } catch (_) {}
  }

  static Stream<dynamic> get sensorEventsStream => sensorEvents.receiveBroadcastStream();
  static Stream<dynamic> get fallEventsStream => fallEvents.receiveBroadcastStream();

  // --- Exact Alarm Reminders ---
  static Future<bool> scheduleExactReminder({
    required String reminderId,
    required String title,
    required String message,
    required int triggerAtMillis,
  }) async {
    try {
      final bool? ok = await reminders.invokeMethod<bool>('scheduleExactReminder', {
        'reminderId': reminderId,
        'title': title,
        'message': message,
        'triggerAtMillis': triggerAtMillis,
      });
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> cancelReminder(String reminderId) async {
    try {
      final bool? ok = await reminders.invokeMethod<bool>('cancelReminder', {
        'reminderId': reminderId,
      });
      return ok ?? false;
    } catch (_) {
      return false;
    }
  }
}
