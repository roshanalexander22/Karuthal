import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/profile_field.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRepository(apiClient);
});

class ProfileRepository {
  final ApiClient _apiClient;

  ProfileRepository(this._apiClient);

  /// Fetch full profile memory or strictly verified fields.
  Future<List<ProfileFieldModel>> getProfile({bool verifiedOnly = false}) async {
    try {
      final endpoint = verifiedOnly ? ApiEndpoints.memoryVerified : ApiEndpoints.memoryList;
      final response = await _apiClient.get<dynamic>(endpoint);

      if (response.data != null && response.data is Map<String, dynamic>) {
        final fieldsList = response.data['fields'] as List<dynamic>? ?? [];
        return fieldsList
            .map((item) => ProfileFieldModel.fromJson(item as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      AppLogger.e('Failed to fetch personal profile: $e');
      rethrow;
    }
  }

  /// Add or update a profile field.
  Future<ProfileFieldModel> upsertField(ProfileFieldModel field) async {
    try {
      final response = await _apiClient.post<dynamic>(
        ApiEndpoints.memoryCreate,
        data: field.toJson(),
      );
      return ProfileFieldModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      AppLogger.e('Failed to upsert field ${field.fieldName}: $e');
      rethrow;
    }
  }

  /// Verify or edit-and-verify a draft field.
  Future<ProfileFieldModel> verifyField(String fieldName, {String? editedValue}) async {
    try {
      final response = await _apiClient.post<dynamic>(
        '${ApiEndpoints.memoryList}/verify',
        data: {
          'field_name': fieldName,
          'is_verified': true,
          if (editedValue != null) 'edited_value': editedValue,
        },
      );
      return ProfileFieldModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      AppLogger.e('Failed to verify field $fieldName: $e');
      rethrow;
    }
  }

  /// Remove a field from personal memory.
  Future<void> deleteField(String fieldName) async {
    try {
      await _apiClient.delete<dynamic>('${ApiEndpoints.memoryList}/field/$fieldName');
    } catch (e) {
      AppLogger.e('Failed to delete field $fieldName: $e');
      rethrow;
    }
  }

  /// Import draft entities from raw OCR text.
  Future<List<ProfileFieldModel>> importDrafts({
    required String rawOcrText,
    String? documentId,
    String documentType = 'AUTO',
  }) async {
    try {
      final response = await _apiClient.post<dynamic>(
        '${ApiEndpoints.memoryList}/import-draft',
        data: {
          'raw_ocr_text': rawOcrText,
          if (documentId != null) 'document_id': documentId,
          'document_type': documentType,
        },
      );
      if (response.data is List) {
        return (response.data as List)
            .map((e) => ProfileFieldModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      AppLogger.e('Failed to import draft fields: $e');
      rethrow;
    }
  }
}
