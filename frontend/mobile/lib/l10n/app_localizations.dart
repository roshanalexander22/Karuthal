import 'package:flutter/widgets.dart';

abstract class AppLocalizations {
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations) ?? _DefaultLocalizations();
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  String get appName;
  String get welcome;
  String get tagline;
  String get voiceAssistant;
  String get documentReader;
  String get medicineReminders;
  String get smartAutofill;
  String get audioTranscription;
  String get fallDetection;
  String get emergencyHelp;
  String get caregiver;
  String get settings;
  String get login;
  String get register;
  String get email;
  String get password;
  String get fullName;
  String get phoneNumber;
  String get submit;
  String get cancel;
  String get retry;
  String get loading;
  String get sosAlert;
  String get disclaimerFall;
}

class _DefaultLocalizations extends AppLocalizations {
  @override String get appName => "സഹായി";
  @override String get welcome => "സഹായിലേക്ക് സ്വാഗതം";
  @override String get tagline => "മുതിർന്നവർക്കായുള്ള എഐ സഹായി";
  @override String get voiceAssistant => "ശബ്ദ സഹായി";
  @override String get documentReader => "രേഖ വായനക്കാരൻ";
  @override String get medicineReminders => "മരുന്ന് ഓർമ്മപ്പെടുത്തലുകൾ";
  @override String get smartAutofill => "സ്മാർട്ട് ഫോം പൂരിപ്പിക്കൽ";
  @override String get audioTranscription => "ഓഡിയോ ട്രാൻസ്ക്രിപ്ഷൻ";
  @override String get fallDetection => "വീഴ്ച കണ്ടെത്തൽ";
  @override String get emergencyHelp => "അടിയന്തിര സഹായം";
  @override String get caregiver => "പരിചാരകർ";
  @override String get settings => "ക്രമീകരണങ്ങൾ";
  @override String get login => "ലോഗിൻ";
  @override String get register => "രജിസ്റ്റർ";
  @override String get email => "ഇമെയിൽ വിലാസം";
  @override String get password => "പാസ്‌വേഡ്";
  @override String get fullName => "മുഴുവൻ പേര്";
  @override String get phoneNumber => "ഫോൺ നമ്പർ";
  @override String get submit => "സമർപ്പിക്കുക";
  @override String get cancel => "റദ്ദാക്കുക";
  @override String get retry => "വീണ്ടും ശ്രമിക്കുക";
  @override String get loading => "കാത്തിരിക്കുക...";
  @override String get sosAlert => "അടിയന്തിര സഹായം (SOS)";
  @override String get disclaimerFall => "പരീക്ഷണാടിസ്ഥാനത്തിലുള്ള സുരക്ഷാ സംവിധാനം.";
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ml'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => _DefaultLocalizations();

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
