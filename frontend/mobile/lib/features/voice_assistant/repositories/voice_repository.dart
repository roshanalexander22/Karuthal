import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';

final voiceRepositoryProvider = Provider<VoiceRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return VoiceRepository(apiClient);
});

class VoiceRepository {
  final ApiClient _apiClient;

  VoiceRepository(this._apiClient);

  /// Send user voice message or text to backend and obtain AI response.
  Future<Map<String, dynamic>> sendVoiceChat({
    String? message,
    String? audioBase64,
    String language = 'ml',
  }) async {
    try {
      final response = await _apiClient.post<dynamic>(
        ApiEndpoints.voiceChat,
        data: {
          if (message != null) 'message': message,
          if (audioBase64 != null) 'audio_base64': audioBase64,
          'language': language,
        },
      );
      if (response.data is Map<String, dynamic>) {
        return response.data as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      AppLogger.e('Voice chat error: $e');
      rethrow;
    }
  }

  /// Fetch past voice conversations.
  Future<List<Map<String, dynamic>>> getVoiceHistory() async {
    try {
      final response = await _apiClient.get<dynamic>(ApiEndpoints.voiceHistory);
      if (response.data is Map<String, dynamic>) {
        final list = response.data['history'] as List<dynamic>? ?? [];
        return list.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (e) {
      AppLogger.e('Voice history error: $e');
      return [];
    }
  }

  /// Synthesize text to speech audio.
  Future<String?> convertTTS(String text,
      {String language = 'ml', double speed = 0.85}) async {
    try {
      final response = await _apiClient.post<dynamic>(
        ApiEndpoints.ttsConvert,
        data: {
          'text': text,
          'language': language,
          'speed': speed,
        },
      );
      if (response.data is Map<String, dynamic>) {
        return response.data['audio_base64'] as String?;
      }
      return null;
    } catch (e) {
      AppLogger.e('TTS convert error: $e');
      return null;
    }
  }
}
