import 'package:flutter/services.dart';

class PlatformChannels {
  static const MethodChannel accessibility = MethodChannel('sahaayi/accessibility');
  static const MethodChannel autofill = MethodChannel('sahaayi/autofill');
  static const MethodChannel sensors = MethodChannel('sahaayi/sensors');
  static const MethodChannel tts = MethodChannel('sahaayi/tts');

  static Future<bool> isAccessibilityServiceActive() async {
    try {
      final bool? active = await accessibility.invokeMethod<bool>('isAccessibilityServiceEnabled');
      return active ?? false;
    } catch (_) {
      return false;
    }
  }

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
}
