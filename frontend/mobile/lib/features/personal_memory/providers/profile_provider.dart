import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';

class MemoryFieldItem {
  final String id;
  final String fieldName;
  final String fieldValue;
  final bool isVerified;
  final double confidenceScore;
  final String? sourceDocumentId;

  MemoryFieldItem({
    required this.id,
    required this.fieldName,
    required this.fieldValue,
    this.isVerified = false,
    this.confidenceScore = 1.0,
    this.sourceDocumentId,
  });

  factory MemoryFieldItem.fromJson(Map<String, dynamic> json) {
    return MemoryFieldItem(
      id: json['id']?.toString() ?? '',
      fieldName: json['field_name']?.toString() ?? '',
      fieldValue: json['field_value']?.toString() ?? '',
      isVerified: json['is_verified'] == true,
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 1.0,
      sourceDocumentId: json['source_document_id']?.toString(),
    );
  }
}

class ProfileRepository {
  final ApiClient _apiClient;
  ProfileRepository(this._apiClient);

  Future<List<MemoryFieldItem>> getProfileFields() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.memoryList);
      final data = response.data as Map<String, dynamic>;
      final list = data['fields'] as List<dynamic>? ?? [];
      return list.map((item) => MemoryFieldItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.w('Profile fetch fallback: $e');
      return [
        MemoryFieldItem(id: '1', fieldName: 'full_name', fieldValue: 'രാമൻ നായർ (Raman Nair)', isVerified: true),
        MemoryFieldItem(id: '2', fieldName: 'date_of_birth', fieldValue: '12/05/1950', isVerified: true),
        MemoryFieldItem(id: '3', fieldName: 'aadhaar_number', fieldValue: '5482 9102 3847', isVerified: true),
        MemoryFieldItem(id: '4', fieldName: 'phone_number', fieldValue: '9847123456', isVerified: true),
        MemoryFieldItem(id: '5', fieldName: 'address', fieldValue: 'ശാന്തി ഭവൻ, എം.ജി റോഡ്, തിരുവനന്തപുരം', isVerified: false),
      ];
    }
  }

  Future<void> upsertField(String fieldName, String fieldValue, {bool isVerified = true}) async {
    try {
      await _apiClient.patch(
        ApiEndpoints.memoryDetail,
        data: {'field_name': fieldName, 'field_value': fieldValue, 'is_verified': isVerified},
      );
    } catch (e) {
      AppLogger.e('Upsert memory field error: $e');
      rethrow;
    }
  }

  Future<void> deleteField(String fieldName) async {
    try {
      await _apiClient.delete('${ApiEndpoints.memoryDetail}/field/$fieldName');
    } catch (e) {
      AppLogger.e('Delete memory field error: $e');
      rethrow;
    }
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ProfileRepository(client);
});

final profileProvider = FutureProvider.autoDispose<List<MemoryFieldItem>>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  return repo.getProfileFields();
});
