class AppConfig {
  static const AppConfig current = AppConfig();
  const AppConfig();

  static const String appName = 'Sahaayi';
  static const String version = '0.1.0';
  static const String apiBaseUrl = 'http://10.0.2.2:8000/api/v1'; // Android emulator to host
  static const int connectTimeoutSeconds = 15;
  static const int receiveTimeoutSeconds = 30;
  static const bool enableDebugLogs = true;

  String get appNameVal => appName;
  String get versionVal => version;
  String get baseUrl => apiBaseUrl;
}
