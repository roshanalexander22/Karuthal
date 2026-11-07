import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/authentication/presentation/login_screen.dart';
import '../features/authentication/presentation/register_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/voice_assistant/presentation/voice_assistant_screen.dart';
import '../features/text_to_speech/presentation/tts_screen.dart';
import '../features/document_reader/presentation/document_list_screen.dart';
import '../features/document_reader/presentation/document_upload_screen.dart';
import '../features/personal_memory/presentation/profile_screen.dart';
import '../features/smart_autofill/presentation/autofill_screen.dart';
import '../features/medicine_reminders/presentation/reminders_screen.dart';
import '../features/medicine_reminders/presentation/new_reminder_screen.dart';
import '../features/audio_transcription/presentation/transcription_screen.dart';
import '../features/fall_detection/presentation/fall_detection_screen.dart';
import '../features/emergency/presentation/emergency_screen.dart';
import '../features/caregiver/presentation/caregiver_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/auth/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/auth/register', builder: (context, state) => const RegisterScreen()),
      GoRoute(path: '/voice', builder: (context, state) => const VoiceAssistantScreen()),
      GoRoute(path: '/tts', builder: (context, state) => const TextToSpeechScreen()),
      GoRoute(path: '/documents', builder: (context, state) => const DocumentListScreen()),
      GoRoute(path: '/documents/upload', builder: (context, state) => const DocumentUploadScreen()),
      GoRoute(path: '/profile', builder: (context, state) => const ProfileScreen()),
      GoRoute(path: '/autofill', builder: (context, state) => const AutofillScreen()),
      GoRoute(path: '/reminders', builder: (context, state) => const RemindersScreen()),
      GoRoute(path: '/reminders/new', builder: (context, state) => const NewReminderScreen()),
      GoRoute(path: '/transcription', builder: (context, state) => const TranscriptionScreen()),
      GoRoute(path: '/fall-detection', builder: (context, state) => const FallDetectionScreen()),
      GoRoute(path: '/emergency', builder: (context, state) => const EmergencyScreen()),
      GoRoute(path: '/caregiver', builder: (context, state) => const CaregiverScreen()),
      GoRoute(path: '/settings', builder: (context, state) => const SettingsScreen()),
    ],
  );
});
