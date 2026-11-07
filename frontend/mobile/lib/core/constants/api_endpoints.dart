/// All REST API endpoint paths used by the Sahaayi application.
///
/// Paths are relative to the API base URL defined in [AppConstants] /
/// [AppConfig]. Do NOT include a leading slash — Dio prepends the base URL.
///
/// Example usage:
/// ```dart
/// final response = await _dio.get(ApiEndpoints.authLogin);
/// ```
abstract final class ApiEndpoints {
  // ── Authentication ───────────────────────────────────────────────────────

  /// POST – Obtain JWT tokens (email + password body).
  static const String authLogin = 'api/v1/auth/login';

  /// POST – Register a new user account.
  static const String authRegister = 'api/v1/auth/register';

  /// POST – Refresh an expired access token using the refresh token.
  static const String authRefresh = 'api/v1/auth/refresh';

  /// POST – Logout and invalidate current tokens.
  static const String authLogout = 'api/v1/auth/logout';

  /// GET – Retrieve the authenticated user's profile.
  static const String authMe = 'api/v1/auth/me';

  // ── Personal Memory (Profile) ────────────────────────────────────────────

  /// GET – List all personal memory fields for the current user.
  static const String memoryList = 'api/v1/memory';

  /// POST – Add or upsert a personal memory field.
  static const String memoryCreate = 'api/v1/memory';

  /// GET/PATCH/DELETE – Single field by ID. Append `/{id}` to these.
  static const String memoryDetail = 'api/v1/memory'; // append /{id}

  /// GET – Retrieve all verified fields suitable for autofill.
  static const String memoryVerified = 'api/v1/memory/verified';

  // ── Documents ────────────────────────────────────────────────────────────

  /// GET – List uploaded documents (paginated).
  static const String documentList = 'api/v1/documents';

  /// POST – Upload a new document (multipart/form-data).
  static const String documentUpload = 'api/v1/documents/upload';

  /// GET – Retrieve a single document's metadata and extracted text.
  /// Append `/{id}`.
  static const String documentDetail = 'api/v1/documents'; // append /{id}

  /// DELETE – Delete a document. Append `/{id}`.
  static const String documentDelete = 'api/v1/documents'; // append /{id}

  /// POST – Request TTS audio for a document's extracted text.
  static const String documentTts = 'api/v1/documents/tts'; // append /{id}

  // ── Voice Assistant ──────────────────────────────────────────────────────

  /// POST – Send a voice message and receive an AI response.
  static const String voiceChat = 'api/v1/voice/chat';

  /// GET – Retrieve conversation history for the current user.
  static const String voiceHistory = 'api/v1/voice/history';

  // ── Text-to-Speech ───────────────────────────────────────────────────────

  /// POST – Convert arbitrary text to speech (returns audio stream or URL).
  static const String ttsConvert = 'api/v1/tts/convert';

  // ── Smart Autofill ───────────────────────────────────────────────────────

  /// POST – Submit form field labels; receive matched memory values.
  static const String autofillMatch = 'api/v1/autofill/match';

  /// POST – Confirm that autofill was applied successfully (audit log).
  static const String autofillConfirm = 'api/v1/autofill/confirm';

  // ── Medicine Reminders ───────────────────────────────────────────────────

  /// GET – List all reminders for the current user.
  static const String reminderList = 'api/v1/reminders';

  /// POST – Create a new reminder.
  static const String reminderCreate = 'api/v1/reminders';

  /// GET/PATCH/DELETE – Single reminder. Append `/{id}`.
  static const String reminderDetail = 'api/v1/reminders'; // append /{id}

  /// POST – Mark a reminder as acknowledged (taken / attended).
  static const String reminderAcknowledge =
      'api/v1/reminders'; // append /{id}/acknowledge

  // ── Audio Transcription ──────────────────────────────────────────────────

  /// POST – Upload audio file for transcription (multipart/form-data).
  static const String transcriptionUpload = 'api/v1/transcription/upload';

  /// GET – List past transcriptions.
  static const String transcriptionList = 'api/v1/transcription';

  /// GET – Get a single transcription result. Append `/{id}`.
  static const String transcriptionDetail =
      'api/v1/transcription'; // append /{id}

  /// DELETE – Delete a transcription. Append `/{id}`.
  static const String transcriptionDelete =
      'api/v1/transcription'; // append /{id}

  // ── Fall Detection ───────────────────────────────────────────────────────

  /// POST – Report a fall event (triggers server-side caregiver notification).
  static const String fallReport = 'api/v1/fall/report';

  /// GET – Retrieve fall detection settings for the current user.
  static const String fallSettings = 'api/v1/fall/settings';

  /// PATCH – Update fall detection settings.
  static const String fallSettingsUpdate = 'api/v1/fall/settings';

  // ── Emergency ────────────────────────────────────────────────────────────

  /// POST – Trigger an SOS alert (notifies all caregiver contacts).
  static const String emergencySos = 'api/v1/emergency/sos';

  /// GET – List the user's emergency contacts.
  static const String emergencyContacts = 'api/v1/emergency/contacts';

  /// POST – Add an emergency contact.
  static const String emergencyContactCreate = 'api/v1/emergency/contacts';

  /// DELETE – Remove an emergency contact. Append `/{id}`.
  static const String emergencyContactDelete =
      'api/v1/emergency/contacts'; // append /{id}

  // ── Caregiver ────────────────────────────────────────────────────────────

  /// GET – Get caregiver link status.
  static const String caregiverStatus = 'api/v1/caregiver/status';

  /// POST – Send a pairing invite to a caregiver.
  static const String caregiverInvite = 'api/v1/caregiver/invite';

  /// POST – Accept a caregiver invite (caregiver side).
  static const String caregiverAccept = 'api/v1/caregiver/accept';

  /// DELETE – Remove caregiver linkage.
  static const String caregiverUnlink = 'api/v1/caregiver/unlink';

  /// GET – Caregiver's view of linked elderly user activity.
  static const String caregiverDashboard = 'api/v1/caregiver/dashboard';

  // ── Health / Misc ────────────────────────────────────────────────────────

  /// GET – Backend health check.
  static const String health = 'health';

  /// GET – API version information.
  static const String apiVersion = 'api/v1/version';
}
