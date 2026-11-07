import 'dart:io';
import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';

class DocumentItem {
  final String id;
  final String originalFilename;
  final String fileType;
  final String documentCategory;
  final String ocrStatus;
  final String? extractedText;
  final Map<String, dynamic>? extractedFields;
  final String? createdAt;

  DocumentItem({
    required this.id,
    required this.originalFilename,
    required this.fileType,
    required this.documentCategory,
    required this.ocrStatus,
    this.extractedText,
    this.extractedFields,
    this.createdAt,
  });

  factory DocumentItem.fromJson(Map<String, dynamic> json) {
    return DocumentItem(
      id: json['id']?.toString() ?? '',
      originalFilename: json['original_filename']?.toString() ?? 'രേഖ',
      fileType: json['file_type']?.toString() ?? '',
      documentCategory: json['document_category']?.toString() ?? 'OTHER',
      ocrStatus: json['ocr_status']?.toString() ?? 'PENDING',
      extractedText: json['extracted_text']?.toString(),
      extractedFields: json['extracted_fields'] as Map<String, dynamic>?,
      createdAt: json['created_at']?.toString(),
    );
  }
}

class DocumentRepository {
  final ApiClient _apiClient;

  DocumentRepository(this._apiClient);

  Future<List<DocumentItem>> getDocuments() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.documentList);
      final data = response.data as Map<String, dynamic>;
      final list = data['documents'] as List<dynamic>? ?? [];
      return list.map((item) => DocumentItem.fromJson(item as Map<String, dynamic>)).toList();
    } catch (e) {
      AppLogger.w('Fetch documents fallback: $e');
      return [
        DocumentItem(
          id: 'mock-1',
          originalFilename: 'ആധാർ കാർഡ് (Aadhaar Card).jpg',
          fileType: 'image/jpeg',
          documentCategory: 'IDENTITY',
          ocrStatus: 'COMPLETED',
          extractedText: 'പേര്: രാമൻ നായർ\nആധാർ: 5482 9102 3847\nവിലാസം: ശാന്തി ഭവൻ, തിരുവനന്തപുരം',
        ),
        DocumentItem(
          id: 'mock-2',
          originalFilename: 'ഡോക്ടർ കുറിപ്പടി (Prescription).pdf',
          fileType: 'application/pdf',
          documentCategory: 'PRESCRIPTION',
          ocrStatus: 'COMPLETED',
          extractedText: 'Paracetamol 500mg - ദിവസേന രണ്ട് നേരം\nMetformin 500mg - ഭക്ഷണത്തിന് ശേഷം',
        ),
      ];
    }
  }

  Future<DocumentItem> uploadDocument(File file, String category) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, filename: file.path.split(Platform.pathSeparator).last),
        'category': category,
      });
      final response = await _apiClient.upload(ApiEndpoints.documentUpload, formData: formData);
      return DocumentItem.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      AppLogger.e('Upload document error: $e');
      rethrow;
    }
  }

  Future<DocumentItem?> getDocument(String id) async {
    try {
      final response = await _apiClient.get('${ApiEndpoints.documentDetail}/$id');
      return DocumentItem.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      AppLogger.e('Get document error: $e');
      return null;
    }
  }

  Future<bool> deleteDocument(String id) async {
    try {
      await _apiClient.delete('${ApiEndpoints.documentDelete}/$id');
      return true;
    } catch (e) {
      AppLogger.e('Delete document error: $e');
      return false;
    }
  }
}
