class ProfileFieldModel {
  final String fieldName;
  final String fieldValue;
  final String fieldType;
  final bool isVerified;
  final double confidenceScore;
  final String? sourceDocumentId;

  const ProfileFieldModel({
    required this.fieldName,
    required this.fieldValue,
    this.fieldType = 'TEXT',
    this.isVerified = false,
    this.confidenceScore = 1.0,
    this.sourceDocumentId,
  });

  factory ProfileFieldModel.fromJson(Map<String, dynamic> json) {
    return ProfileFieldModel(
      fieldName: json['field_name'] as String? ?? '',
      fieldValue: json['field_value'] as String? ?? '',
      fieldType: json['field_type'] as String? ?? 'TEXT',
      isVerified: json['is_verified'] as bool? ?? false,
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 1.0,
      sourceDocumentId: json['source_document_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'field_name': fieldName,
      'field_value': fieldValue,
      'field_type': fieldType,
      'is_verified': isVerified,
      'confidence_score': confidenceScore,
      'source_document_id': sourceDocumentId,
    };
  }

  ProfileFieldModel copyWith({
    String? fieldName,
    String? fieldValue,
    String? fieldType,
    bool? isVerified,
    double? confidenceScore,
    String? sourceDocumentId,
  }) {
    return ProfileFieldModel(
      fieldName: fieldName ?? this.fieldName,
      fieldValue: fieldValue ?? this.fieldValue,
      fieldType: fieldType ?? this.fieldType,
      isVerified: isVerified ?? this.isVerified,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      sourceDocumentId: sourceDocumentId ?? this.sourceDocumentId,
    );
  }
}
