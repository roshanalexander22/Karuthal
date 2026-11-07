import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/tts_service.dart';
import '../models/voice_message.dart';
import '../repositories/voice_repository.dart';

class VoiceState {
  final bool isListening;
  final bool isSpeaking;
  final bool isLoading;
  final String statusText;
  final String recognizedText;
  final List<VoiceMessage> messages;

  const VoiceState({
    this.isListening = false,
    this.isSpeaking = false,
    this.isLoading = false,
    this.statusText = 'മൈക്രോഫോൺ അമർത്തുക (Tap Mic)',
    this.recognizedText = '',
    this.messages = const [],
  });

  VoiceState copyWith({
    bool? isListening,
    bool? isSpeaking,
    bool? isLoading,
    String? statusText,
    String? recognizedText,
    List<VoiceMessage>? messages,
  }) {
    return VoiceState(
      isListening: isListening ?? this.isListening,
      isSpeaking: isSpeaking ?? this.isSpeaking,
      isLoading: isLoading ?? this.isLoading,
      statusText: statusText ?? this.statusText,
      recognizedText: recognizedText ?? this.recognizedText,
      messages: messages ?? this.messages,
    );
  }
}

class VoiceNotifier extends StateNotifier<VoiceState> {
  final VoiceRepository _repository;
  final TTSService _ttsService;

  VoiceNotifier(this._repository, this._ttsService)
      : super(const VoiceState()) {
    // Initial welcome message
    final welcome = VoiceMessage(
      id: 'welcome',
      text:
          'നമസ്കാരം! ഞാൻ താങ്കളുടെ സഹായി ആണ്. എന്തെങ്കിലും ചോദിക്കാനോ സഹായത്തിനോ സംസാരിക്കാം.',
      isUser: false,
      timestamp: DateTime.now(),
      intent: 'GREETING',
    );
    state = state.copyWith(messages: [welcome]);
  }

  Future<void> sendQuery(String queryText) async {
    if (queryText.trim().isEmpty) return;

    final userMsg = VoiceMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: queryText,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final updated = List<VoiceMessage>.from(state.messages)..add(userMsg);
    state = state.copyWith(
      isLoading: true,
      statusText: 'മറുപടി തയ്യാറാക്കുന്നു...',
      messages: updated,
    );

    try {
      final res = await _repository.sendVoiceChat(message: queryText);
      final replyText =
          res['assistant_reply'] as String? ?? 'ശരി, ഞാൻ സഹായിക്കാം.';
      final audioB64 = res['audio_base64'] as String?;
      final intent = res['intent'] as String?;
      final action = res['action'] as String?;
      final targetRoute = res['target_route'] as String?;

      final botMsg = VoiceMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: replyText,
        isUser: false,
        timestamp: DateTime.now(),
        intent: intent,
        action: action,
        targetRoute: targetRoute,
        audioBase64: audioB64,
      );

      state = state.copyWith(
        isLoading: false,
        statusText: 'സംസാരിക്കാൻ മൈക് അമർത്തുക',
        messages: List<VoiceMessage>.from(state.messages)..add(botMsg),
      );

      // Speak reply aloud via Web Speech / Native TTS
      await _ttsService.speak(replyText);
    } catch (_) {
      // Offline fallback
      final fallbackReply = _getOfflineFallback(queryText);
      final botMsg = VoiceMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: fallbackReply,
        isUser: false,
        timestamp: DateTime.now(),
        intent: 'ASSISTANCE',
      );
      state = state.copyWith(
        isLoading: false,
        statusText: 'സംസാരിക്കാൻ മൈക് അമർത്തുക',
        messages: List<VoiceMessage>.from(state.messages)..add(botMsg),
      );
      await _ttsService.speak(fallbackReply);
    }
  }

  int _queryIndex = 0;
  final List<String> _voiceQueries = [
    'ഇന്നത്തെ എന്റെ മരുന്നുകൾ ഏതൊക്കെയാണ്?',
    'എന്റെ രേഖകൾ വായിച്ചു കേൾക്കാമോ?',
    'പെൻഷൻ ഫോം പൂരിപ്പിക്കാൻ സഹായിക്കാമോ?',
    'അടുത്ത ഡോക്ടർ അപ്പോയിന്റ്മെന്റ് എപ്പോഴാണ്?',
  ];

  void toggleListening() {
    if (state.isListening) {
      // Stop listening and process
      state = state.copyWith(
        isListening: false,
        statusText: 'ശ്രദ്ധിച്ചു കഴിഞ്ഞു...',
      );
      if (state.recognizedText.isNotEmpty) {
        sendQuery(state.recognizedText);
      }
    } else {
      // Start listening with interactive voice simulation
      _ttsService.stop();
      final currentQuery = _voiceQueries[_queryIndex % _voiceQueries.length];
      _queryIndex++;

      state = state.copyWith(
        isListening: true,
        statusText: 'ശ്രദ്ധിക്കുന്നു... സംസാരിക്കൂ (Listening...)',
        recognizedText: currentQuery,
      );

      // Auto-submit after 2.5 seconds if user doesn't stop manually
      Future.delayed(const Duration(milliseconds: 2500), () {
        if (state.isListening) {
          state = state.copyWith(
            isListening: false,
            statusText: 'മറുപടി തയ്യാറാക്കുന്നു...',
          );
          sendQuery(currentQuery);
        }
      });
    }
  }

  Future<void> speakAudio(String base64Wav) async {
    state = state.copyWith(isSpeaking: true);
    await _ttsService.playBase64Audio(base64Wav);
    state = state.copyWith(isSpeaking: false);
  }

  Future<void> speakMessage(VoiceMessage message) async {
    state = state.copyWith(isSpeaking: true);
    await _ttsService.speak(message.text);
    state = state.copyWith(isSpeaking: false);
  }

  void stopSpeaking() {
    _ttsService.stop();
    state = state.copyWith(isSpeaking: false);
  }

  String _getOfflineFallback(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('ഗുളിക') || lower.contains('മരുന്ന്')) {
      return 'ഇന്ന് 3 മരുന്നുകൾ കഴിക്കാനുണ്ട്. ഉച്ചയ്ക്ക് 1:30 ന് ഷുഗർ മരുന്ന് (Metformin 500mg) ഭക്ഷണത്തിന് മുൻപ് കഴിക്കാൻ ഓർമ്മിക്കുക.';
    }
    if (lower.contains('രേഖ') || lower.contains('ഡോക്യുമെന്റ്') || lower.contains('ആധാർ')) {
      return 'താങ്കളുടെ ആധാർ കാർഡും ഡോക്ടർ കുറിപ്പടിയും സൂക്ഷിച്ചിട്ടുണ്ട്. രേഖകൾ വിഭാഗത്തിൽ വായിച്ചു കേൾക്കാം.';
    }
    if (lower.contains('പെൻഷൻ') || lower.contains('ഫോം') || lower.contains('ഓട്ടോഫിൽ')) {
      return 'സ്മാർട്ട് ഓട്ടോഫിൽ വഴി താങ്കളുടെ പെൻഷൻ ഫോം വിവരങ്ങൾ പൂരിപ്പിക്കാൻ തയ്യാറാണ്.';
    }
    if (lower.contains('സഹായം') || lower.contains('അടിയന്തിരം') || lower.contains('help')) {
      return 'അടിയന്തര സഹായത്തിനായി പരിചാരകരെയും കുടുംബാംഗങ്ങളെയും ബന്ധപ്പെടാൻ ഞാൻ തയ്യാറാണ്.';
    }
    return 'നമസ്കാരം! താങ്കൾ പറഞ്ഞത് ഞാൻ ശ്രദ്ധിച്ചു. സഹായി താങ്കളെ ഏതു വിധത്തിലാണ് സഹായിക്കേണ്ടത്?';
  }
}

final voiceProvider = StateNotifierProvider<VoiceNotifier, VoiceState>((ref) {
  final repo = ref.watch(voiceRepositoryProvider);
  final tts = ref.watch(ttsServiceProvider);
  return VoiceNotifier(repo, tts);
});
