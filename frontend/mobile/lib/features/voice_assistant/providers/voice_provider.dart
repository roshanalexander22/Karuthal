import 'package:flutter_riverpod/flutter_riverpod.dart';

class VoiceState {
  final bool isListening;
  final String statusText;
  final String recognizedText;
  VoiceState({this.isListening = false, this.statusText = 'മൈക്രോഫോൺ അമർത്തുക', this.recognizedText = ''});
}

class VoiceNotifier extends StateNotifier<VoiceState> {
  VoiceNotifier() : super(VoiceState());

  void toggleListening() {
    state = VoiceState(
      isListening: !state.isListening,
      statusText: !state.isListening ? 'ശ്രദ്ധിക്കുന്നു...' : 'പൂർത്തിയായി',
      recognizedText: !state.isListening ? 'എന്റെ പെൻഷൻ ഫോം പൂരിപ്പിക്കാൻ സഹായിക്കാമോ?' : state.recognizedText,
    );
  }
}

final voiceProvider = StateNotifierProvider<VoiceNotifier, VoiceState>((ref) => VoiceNotifier());
