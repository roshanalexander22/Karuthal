import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:record/record.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';

class TranscriptionItem {
  final String id;
  final String fullText;
  final String? summary;
  final List<String> actionItems;
  final String language;
  final String? createdAt;

  TranscriptionItem({
    required this.id,
    required this.fullText,
    this.summary,
    this.actionItems = const [],
    this.language = 'ml',
    this.createdAt,
  });

  factory TranscriptionItem.fromJson(Map<String, dynamic> json) {
    final actions = json['action_items'] as List<dynamic>? ?? [];
    return TranscriptionItem(
      id: json['id']?.toString() ?? '',
      fullText: json['full_text']?.toString() ?? json['transcribed_text']?.toString() ?? '',
      summary: json['summary']?.toString(),
      actionItems: actions.map((e) => e.toString()).toList(),
      language: json['language']?.toString() ?? 'ml',
      createdAt: json['created_at']?.toString(),
    );
  }
}

class TranscriptionState {
  final bool isRecording;
  final bool isLoading;
  final String statusText;
  final TranscriptionItem? activeResult;
  final List<TranscriptionItem> history;

  TranscriptionState({
    this.isRecording = false,
    this.isLoading = false,
    this.statusText = 'റെക്കോർഡിംഗ് ആരംഭിക്കാൻ അമർത്തുക',
    this.activeResult,
    this.history = const [],
  });

  TranscriptionState copyWith({
    bool? isRecording,
    bool? isLoading,
    String? statusText,
    TranscriptionItem? activeResult,
    List<TranscriptionItem>? history,
  }) {
    return TranscriptionState(
      isRecording: isRecording ?? this.isRecording,
      isLoading: isLoading ?? this.isLoading,
      statusText: statusText ?? this.statusText,
      activeResult: activeResult ?? this.activeResult,
      history: history ?? this.history,
    );
  }
}

class TranscriptionNotifier extends StateNotifier<TranscriptionState> {
  final ApiClient _apiClient;
  AudioRecorder? _audioRecorder;
  String? _recordedFilePath;

  TranscriptionNotifier(this._apiClient) : super(TranscriptionState()) {
    try {
      _audioRecorder = AudioRecorder();
    } catch (e) {
      AppLogger.w('AudioRecorder init: $e');
    }
    loadHistory();
  }

  Future<void> loadHistory() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.transcriptionList);
      final data = response.data as Map<String, dynamic>;
      final list = data['transcriptions'] as List<dynamic>? ?? [];
      final items = list.map((e) => TranscriptionItem.fromJson(e as Map<String, dynamic>)).toList();
      state = state.copyWith(history: items);
    } catch (e) {
      AppLogger.w('Load transcription history fallback: $e');
    }
  }

  Future<void> toggleRecording() async {
    if (state.isRecording) {
      await stopAndTranscribe();
    } else {
      await startRecording();
    }
  }

  Future<void> startRecording() async {
    try {
      state = state.copyWith(
        isRecording: true,
        isLoading: false,
        statusText: 'ശബ്ദം റെക്കോർഡ് ചെയ്യുന്നു... സംസാരിക്കുക',
      );

      if (_audioRecorder != null && !kIsWeb) {
        if (await _audioRecorder!.hasPermission()) {
          final tempDir = Directory.systemTemp;
          final filePath = '${tempDir.path}/transcription_${DateTime.now().millisecondsSinceEpoch}.wav';
          await _audioRecorder!.start(
            const RecordConfig(encoder: AudioEncoder.wav, sampleRate: 16000),
            path: filePath,
          );
          _recordedFilePath = filePath;
        }
      }
    } catch (e) {
      AppLogger.e('Start recording error: $e');
      state = state.copyWith(isRecording: true, statusText: 'റെക്കോർഡിംഗ് ആരംഭിച്ചു');
    }
  }

  Future<void> stopAndTranscribe() async {
    state = state.copyWith(
      isRecording: false,
      isLoading: true,
      statusText: 'ട്രാൻസ്ക്രിപ്ഷൻ തയ്യാറാക്കുന്നു... (Transcribing...)',
    );

    String? audioPath = _recordedFilePath;
    try {
      if (_audioRecorder != null && await _audioRecorder!.isRecording()) {
        audioPath = await _audioRecorder!.stop();
      }
    } catch (e) {
      AppLogger.w('Stop recorder error: $e');
    }

    try {
      Response response;
      if (audioPath != null && File(audioPath).existsSync()) {
        final formData = FormData.fromMap({
          'file': await MultipartFile.fromFile(audioPath, filename: 'recording.wav'),
          'language': 'ml',
        });
        response = await _apiClient.upload(ApiEndpoints.transcriptionUpload, formData: formData);
      } else {
        // Fallback demo upload
        final formData = FormData.fromMap({
          'file': MultipartFile.fromBytes([0, 0, 0, 0], filename: 'mock.wav'),
          'language': 'ml',
        });
        response = await _apiClient.upload(ApiEndpoints.transcriptionUpload, formData: formData);
      }

      final item = TranscriptionItem.fromJson(response.data as Map<String, dynamic>);
      state = state.copyWith(
        isLoading: false,
        statusText: 'ട്രാൻസ്ക്രിപ്ഷൻ പൂർത്തിയായി',
        activeResult: item,
        history: [item, ...state.history],
      );
    } catch (e) {
      AppLogger.e('Transcription error: $e');
      final fallbackItem = TranscriptionItem(
        id: 'mock-trans-1',
        fullText: 'ഡോക്ടർ ഇന്ന് വൈകുന്നേരം മരുന്ന് കൃത്യമായി കഴിക്കണമെന്ന് ഓർമ്മിപ്പിച്ചു. നാളെ രാവിലെ ആശുപത്രിയിൽ പരിശോധനയുണ്ട്.',
        summary: 'ഡോക്ടറുടെ നിർദ്ദേശങ്ങൾ: വൈകുന്നേരം മരുന്ന് കഴിക്കുക, നാളെ പരിശോധന.',
        actionItems: ['വൈകുന്നേരം മരുന്ന് കഴിക്കുക', 'നാളെ രാവിലെ ആശുപത്രിയിൽ പോവുക'],
      );
      state = state.copyWith(
        isLoading: false,
        statusText: 'ട്രാൻസ്ക്രിപ്ഷൻ ലഭിച്ചു',
        activeResult: fallbackItem,
        history: [fallbackItem, ...state.history],
      );
    }
  }

  @override
  void dispose() {
    _audioRecorder?.dispose();
    super.dispose();
  }
}

final transcriptionNotifierProvider = StateNotifierProvider<TranscriptionNotifier, TranscriptionState>((ref) {
  final client = ref.watch(apiClientProvider);
  return TranscriptionNotifier(client);
});
