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

  VoiceNotifier(this._repository, this._ttsService) : super(const VoiceState()) {
    // Initial welcome message
    final welcome = VoiceMessage(
      id: 'welcome',
      text: 'നമസ്കാരം! ഞാൻ താങ്കളുടെ സഹായി ആണ്. എന്തെങ്കിലും ചോദിക്കാനോ സഹായത്തിനോ സംസാരിക്കാം.',
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
      final replyText = res['assistant_reply'] as String? ?? 'ശരി, ഞാൻ സഹായിക്കാം.';
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

      // Read reply aloud
      if (audioB64 != null && audioB64.isNotEmpty) {
        speakAudio(audioB64);
      }
    } catch (_) {
      // Offline fallback
      final fallbackReply = _getOfflineFallback(queryText);
      final botMsg = VoiceMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: fallbackReply,
        isUser: false,
        timestamp: DateTime.now(),
        intent: 'OFFLINE_FALLBACK',
      );
      state = state.copyWith(
        isLoading: false,
        statusText: 'സംസാരിക്കാൻ മൈക് അമർത്തുക',
        messages: List<VoiceMessage>.from(state.messages)..add(botMsg),
      );
    }
  }

  void toggleListening() {
    if (state.isListening) {
      // Stop listening and process
      state = state.copyWith(
        isListening: false,
        statusText: 'ശ്രദ്ധിച്ചു കഴിഞ്ഞു',
      );
      if (state.recognizedText.isNotEmpty) {
        sendQuery(state.recognizedText);
      }
    } else {
      // Start listening
      _ttsService.stop();
      state = state.copyWith(
        isListening: true,
        statusText: 'ശ്രദ്ധിക്കുന്നു... സംസാരിക്കൂ (Listening...)',
        recognizedText: 'രാവിലെ 8 മണിക്ക് ബിപി ഗുളിക ഓർമ്മിപ്പിക്കുക',
      );
    }
  }

  Future<void> speakAudio(String base64Wav) async {
    state = state.copyWith(isSpeaking: true);
    await _ttsService.playBase64Audio(base64Wav);
    state = state.copyWith(isSpeaking: false);
  }

  Future<void> speakMessage(VoiceMessage message) async {
    if (message.audioBase64 != null && message.audioBase64!.isNotEmpty) {
      await speakAudio(message.audioBase64!);
    } else {
      // Synthesize on the fly
      final b64 = await _repository.convertTTS(message.text);
      if (b64 != null && b64.isNotEmpty) {
        await speakAudio(b64);
      }
    }
  }

  void stopSpeaking() {
    _ttsService.stop();
    state = state.copyWith(isSpeaking: false);
  }

  String _getOfflineFallback(String text) {
    final lower = text.toLowerCase();
    if (lower.contains('ഗുളിക') || lower.contains('മരുന്ന്')) {
      return 'മരുന്ന് കഴിക്കാനുള്ള റിമൈൻഡർ സജ്ജമാക്കാം.';
    }
    if (lower.contains('സഹായം') || lower.contains('സഹായിക്കൂ')) {
      return 'അടിയന്തര സഹായത്തിന് ബന്ധപ്പെടാം.';
    }
    return 'നമസ്കാരം, താങ്കളുടെ സന്ദേശം ലഭിച്ചു. ഞാൻ സഹായിക്കാൻ തയ്യാറാണ്.';
  }
}

final voiceProvider = StateNotifierProvider<VoiceNotifier, VoiceState>((ref) {
  final repo = ref.watch(voiceRepositoryProvider);
  final tts = ref.watch(ttsServiceProvider);
  return VoiceNotifier(repo, tts);
});
