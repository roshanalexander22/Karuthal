import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'Sahaayi';
  static const String version = '1.0.0';

  static String get apiBaseUrl {
    if (kIsWeb) {
      return 'http://127.0.0.1:8000/api/v1';
    }
    // Android emulator loopback alias
    return 'http://10.0.2.2:8000/api/v1';
  }

  static const int connectTimeoutSeconds = 15;
  static const int receiveTimeoutSeconds = 30;
  static const bool enableDebugLogs = true;
}
