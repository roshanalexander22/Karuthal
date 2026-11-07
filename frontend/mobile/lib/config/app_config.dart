import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'Sahaayi';
  static const String version = '1.0.0';

  static String get apiBaseUrl {
    if (kIsWeb) {
      final host = Uri.base.host.isNotEmpty ? Uri.base.host : 'localhost';
      return 'http://$host:8000';
    }
    // Android emulator loopback alias
    return 'http://10.0.2.2:8000';
  }

  static const int connectTimeoutSeconds = 15;
  static const int receiveTimeoutSeconds = 30;
  static const bool enableDebugLogs = true;
}
