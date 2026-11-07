class ScreenFormFieldModel {
  final String nodeId;
  final String label;
  final String inputType;
  final bool isPasswordOrSensitive;

  const ScreenFormFieldModel({
    required this.nodeId,
    required this.label,
    this.inputType = 'text',
    this.isPasswordOrSensitive = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'node_id': nodeId,
      'label': label,
      'input_type': inputType,
      'is_password_or_sensitive': isPasswordOrSensitive,
    };
  }
}

class FieldMatchProposalModel {
  final String nodeId;
  final String profileFieldName;
  final String proposedValue;
  final double confidenceScore;
  final bool requiresUserConfirmation;

  const FieldMatchProposalModel({
    required this.nodeId,
    required this.profileFieldName,
    required this.proposedValue,
    this.confidenceScore = 1.0,
    this.requiresUserConfirmation = true,
  });

  factory FieldMatchProposalModel.fromJson(Map<String, dynamic> json) {
    return FieldMatchProposalModel(
      nodeId: json['node_id'] as String? ?? '',
      profileFieldName: json['profile_field_name'] as String? ?? '',
      proposedValue: json['proposed_value'] as String? ?? '',
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 1.0,
      requiresUserConfirmation: json['requires_user_confirmation'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'node_id': nodeId,
      'profile_field_name': profileFieldName,
      'proposed_value': proposedValue,
      'confidence_score': confidenceScore,
      'requires_user_confirmation': requiresUserConfirmation,
    };
  }
}
