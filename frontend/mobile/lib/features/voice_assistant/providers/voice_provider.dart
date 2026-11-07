import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../../text_to_speech/services/tts_service.dart';

class VoiceState {
  final bool isListening;
  final bool isLoading;
  final String statusText;
  final String recognizedText;
  final String responseText;
  final String? intent;
  final Map<String, dynamic>? entities;

  VoiceState({
    this.isListening = false,
    this.isLoading = false,
    this.statusText = 'മൈക്രോഫോൺ അമർത്തുക (Tap mic to speak)',
    this.recognizedText = '',
    this.responseText = '',
    this.intent,
    this.entities,
  });

  VoiceState copyWith({
    bool? isListening,
    bool? isLoading,
    String? statusText,
    String? recognizedText,
    String? responseText,
    String? intent,
    Map<String, dynamic>? entities,
  }) {
    return VoiceState(
      isListening: isListening ?? this.isListening,
      isLoading: isLoading ?? this.isLoading,
      statusText: statusText ?? this.statusText,
      recognizedText: recognizedText ?? this.recognizedText,
      responseText: responseText ?? this.responseText,
      intent: intent ?? this.intent,
      entities: entities ?? this.entities,
    );
  }
}

class VoiceNotifier extends StateNotifier<VoiceState> {
  final ApiClient _apiClient;
  final TTSService _ttsService;
  AudioRecorder? _audioRecorder;
  String? _recordedFilePath;

  VoiceNotifier(this._apiClient, this._ttsService) : super(VoiceState()) {
    _initRecorder();
  }

  void _initRecorder() {
    try {
      _audioRecorder = AudioRecorder();
    } catch (e) {
      AppLogger.w('AudioRecorder init error: $e');
    }
  }

  Future<void> toggleListening() async {
    if (state.isListening) {
      await stopListening();
    } else {
      await startListening();
    }
  }

  Future<void> startListening() async {
    try {
      state = state.copyWith(
        isListening: true,
        isLoading: false,
        statusText: 'ശ്രദ്ധിക്കുന്നു... സംസാരിക്കുക (Listening... Speak now)',
      );

      if (_audioRecorder != null && !kIsWeb) {
        final hasPermission = await _audioRecorder!.hasPermission();
        if (hasPermission) {
          final tempDir = Directory.systemTemp;
          final filePath = '${tempDir.path}/voice_query_${DateTime.now().millisecondsSinceEpoch}.wav';
          await _audioRecorder!.start(
            const RecordConfig(encoder: AudioEncoder.wav, sampleRate: 16000, numChannels: 1),
            path: filePath,
          );
          _recordedFilePath = filePath;
        }
      }
    } catch (e) {
      AppLogger.e('Error starting voice recording: $e');
      state = state.copyWith(
        isListening: true,
        statusText: 'റെക്കോർഡിംഗ് ആരംഭിച്ചു (സംസാരിക്കുക)',
      );
    }
  }

  Future<void> stopListening() async {
    state = state.copyWith(
      isListening: false,
      isLoading: true,
      statusText: 'പ്രോസസ്സ് ചെയ്യുന്നു... (Processing...)',
    );

    String? audioPath = _recordedFilePath;
    try {
      if (_audioRecorder != null && await _audioRecorder!.isRecording()) {
        audioPath = await _audioRecorder!.stop();
      }
    } catch (e) {
      AppLogger.w('Recorder stop error: $e');
    }

    await processVoiceInput(audioPath: audioPath);
  }

  Future<void> processVoiceInput({String? audioPath, String? directText}) async {
    state = state.copyWith(isLoading: true, statusText: 'പ്രോസസ്സ് ചെയ്യുന്നു... (Processing...)');

    try {
      Response response;
      if (audioPath != null && File(audioPath).existsSync()) {
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(audioPath, filename: 'voice_input.wav'),
          'language': 'ml',
        });
        response = await _apiClient.upload(ApiEndpoints.voiceChat, formData: formData);
      } else {
        final textQuery = directText ?? 'സഹായി, വൈകിട്ട് 7 മണിക്ക് പാരസെറ്റാമോൾ കഴിക്കാൻ ഓർമ്മിപ്പിക്കണം.';
        response = await _apiClient.post(
          ApiEndpoints.voiceChat,
          data: {'text': textQuery, 'language': 'ml'},
        );
      }

      final data = response.data as Map<String, dynamic>;
      final userQuery = data['user_query']?.toString() ?? directText ?? '';
      final responseText = data['response_text']?.toString() ?? 'സഹായി തയ്യാറാണ്.';
      final intent = data['intent']?.toString();
      final entities = data['entities'] as Map<String, dynamic>?;

      state = state.copyWith(
        isLoading: false,
        statusText: 'മറുപടി ലഭിച്ചു (Response ready)',
        recognizedText: userQuery,
        responseText: responseText,
        intent: intent,
        entities: entities,
      );

      // Speak out the response in Malayalam
      await _ttsService.speak(responseText);
    } catch (e) {
      AppLogger.e('Voice processing error: $e');
      const fallbackResponse = 'ക്ഷമിക്കണം, എനിക്ക് ഇപ്പോൾ കണക്ട് ചെയ്യാൻ സാധിച്ചില്ല. ദയവായി വീണ്ടും ശ്രമിക്കുക.';
      state = state.copyWith(
        isLoading: false,
        statusText: 'തടസ്സം നേരിട്ടു (Error occurred)',
        recognizedText: directText ?? 'സഹായി, എന്നെ സഹായിക്കാമോ?',
        responseText: fallbackResponse,
      );
      await _ttsService.speak(fallbackResponse);
    }
  }

  @override
  void dispose() {
    _audioRecorder?.dispose();
    super.dispose();
  }
}

final voiceProvider = StateNotifierProvider<VoiceNotifier, VoiceState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final ttsService = ref.watch(ttsServiceProvider);
  return VoiceNotifier(apiClient, ttsService);
});
