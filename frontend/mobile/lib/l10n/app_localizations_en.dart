// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Sahaayi';

  @override
  String get welcome => 'Welcome to Sahaayi';

  @override
  String get tagline => 'AI Companion for Senior Citizens';

  @override
  String get voiceAssistant => 'Voice Assistant';

  @override
  String get documentReader => 'Document Reader';

  @override
  String get medicineReminders => 'Medicine Reminders';

  @override
  String get smartAutofill => 'Smart Autofill';

  @override
  String get audioTranscription => 'Audio Transcription';

  @override
  String get fallDetection => 'Fall Detection';

  @override
  String get emergencyHelp => 'Emergency Help';

  @override
  String get caregiver => 'Caregivers';

  @override
  String get settings => 'Settings';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get email => 'Email Address';

  @override
  String get password => 'Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get submit => 'Submit';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Retry';

  @override
  String get loading => 'Please wait...';

  @override
  String get sosAlert => 'EMERGENCY SOS';

  @override
  String get disclaimerFall =>
      'Experimental safety feature. Not a certified medical device.';
}
