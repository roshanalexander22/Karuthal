/// App-wide constants for the Sahaayi application.
///
/// Centralises configuration values so they can be changed in one place
/// without hunting through the codebase.
abstract final class AppConstants {
  // ── API Configuration ───────────────────────────────────────────────────

  /// Base URL of the Karuthal / Sahaayi backend API.
  /// Override via [AppConfig] for staging / production environments.
  static const String defaultApiBaseUrl = 'http://10.0.2.2:8000';

  /// Connect timeout in milliseconds.
  static const int connectTimeoutMs = 15000;

  /// Receive timeout in milliseconds.
  static const int receiveTimeoutMs = 30000;

  /// Send timeout in milliseconds (used for file uploads).
  static const int sendTimeoutMs = 60000;

  // ── File Limits ─────────────────────────────────────────────────────────

  /// Maximum document file size accepted by the backend (10 MB).
  static const int maxDocumentSizeBytes = 10 * 1024 * 1024;

  /// Maximum audio file size for transcription (25 MB).
  static const int maxAudioSizeBytes = 25 * 1024 * 1024;

  /// Maximum image size for document scanning (5 MB).
  static const int maxImageSizeBytes = 5 * 1024 * 1024;

  /// Allowed document MIME types.
  static const List<String> allowedDocumentMimeTypes = [
    'application/pdf',
    'image/jpeg',
    'image/png',
    'image/webp',
    'text/plain',
  ];

  /// Allowed audio MIME types for transcription.
  static const List<String> allowedAudioMimeTypes = [
    'audio/mpeg',
    'audio/wav',
    'audio/x-wav',
    'audio/mp4',
    'audio/ogg',
    'audio/webm',
  ];

  // ── Localisation ────────────────────────────────────────────────────────

  /// Language codes supported by the app.
  static const List<String> supportedLanguageCodes = ['en', 'ml'];

  /// Human-readable names for supported languages.
  static const Map<String, String> languageNames = {
    'en': 'English',
    'ml': 'മലയാളം',
  };

  /// Default language shown to new users.
  static const String defaultLanguageCode = 'ml';

  // ── TTS ─────────────────────────────────────────────────────────────────

  /// Minimum TTS speech rate (0.0 – 1.0 scale; 0.4 is comfortable for elderly).
  static const double ttsMinRate = 0.1;

  /// Maximum TTS speech rate.
  static const double ttsMaxRate = 1.0;

  /// Default TTS rate — slightly slower than normal for elderly users.
  static const double ttsDefaultRate = 0.5;

  /// Default TTS pitch (1.0 = normal).
  static const double ttsDefaultPitch = 1.0;

  // ── Fall Detection ──────────────────────────────────────────────────────

  /// Accelerometer magnitude threshold (m/s²) that may indicate a fall.
  static const double fallAccelerationThreshold = 25.0;

  /// Duration (ms) the threshold must be exceeded before alerting.
  static const int fallDetectionWindowMs = 500;

  /// Countdown (seconds) before an emergency SOS is auto-sent after a fall.
  static const int fallAlertCountdownSeconds = 30;

  // ── Authentication ──────────────────────────────────────────────────────

  /// SharedPreferences key for storing the JWT access token.
  static const String prefKeyAccessToken = 'access_token';

  /// SharedPreferences key for storing the JWT refresh token.
  static const String prefKeyRefreshToken = 'refresh_token';

  /// SharedPreferences key for user locale preference.
  static const String prefKeyLocale = 'user_locale';

  // ── Feature Flags ───────────────────────────────────────────────────────

  /// Whether fall detection is enabled in the build.
  /// Set to false before GA until sensor accuracy is validated.
  static const bool featureFallDetection = true;

  /// Whether caregiver pairing is enabled.
  static const bool featureCaregiverMode = true;

  /// Whether the smart autofill accessibility service is enabled.
  static const bool featureSmartAutofill = true;

  /// Whether voice assistant (AI chat) is enabled.
  static const bool featureVoiceAssistant = true;

  // ── UI / UX ─────────────────────────────────────────────────────────────

  /// Minimum accessible touch target size in logical pixels.
  static const double minTouchTarget = 48.0;

  /// Standard large button height for elderly-friendly UI.
  static const double largeButtonHeight = 56.0;

  /// Padding used around feature cards on the home screen.
  static const double cardPadding = 16.0;

  /// Number of columns in the home screen feature grid.
  static const int homeGridColumns = 2;

  // ── Pagination ──────────────────────────────────────────────────────────

  /// Default page size for list APIs.
  static const int defaultPageSize = 20;

  // ── Cache ───────────────────────────────────────────────────────────────

  /// Duration in minutes that document list is cached locally.
  static const int documentCacheMinutes = 30;
}
