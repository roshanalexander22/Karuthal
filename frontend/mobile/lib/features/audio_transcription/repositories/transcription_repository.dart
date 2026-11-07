import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/transcription_model.dart';

final transcriptionRepositoryProvider = Provider<TranscriptionRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TranscriptionRepository(apiClient);
});

class TranscriptionRepository {
  final ApiClient _apiClient;

  TranscriptionRepository(this._apiClient);

  Future<TranscriptionModel> uploadAudioBytes(
    List<int> bytes,
    String filename, {
    String language = 'ml',
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
        'language': language,
      });

      final response = await _apiClient.upload<dynamic>(
        ApiEndpoints.transcriptionUpload,
        formData: formData,
      );

      if (response.data is Map<String, dynamic>) {
        return TranscriptionModel.fromJson(response.data as Map<String, dynamic>);
      }
      throw Exception('Invalid server response');
    } catch (e) {
      AppLogger.e('Transcription upload failed: $e');
      rethrow;
    }
  }

  Future<List<TranscriptionModel>> getTranscriptions() async {
    try {
      final response = await _apiClient.get<dynamic>(ApiEndpoints.transcriptionList);
      if (response.data is Map<String, dynamic>) {
        final list = response.data['transcriptions'] as List<dynamic>? ?? [];
        return list
            .map((e) => TranscriptionModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      AppLogger.e('Failed to fetch transcriptions: $e');
      return [];
    }
  }

  Future<TranscriptionModel> summarize(String id) async {
    try {
      final response = await _apiClient.post<dynamic>(
        '${ApiEndpoints.transcriptionList}/$id/summarize',
      );
      return TranscriptionModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      AppLogger.e('Failed to summarize transcription: $e');
      rethrow;
    }
  }
}
