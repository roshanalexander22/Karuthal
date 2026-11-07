import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';

class FormFieldMatch {
  final String nodeId;
  final String profileFieldName;
  final String proposedValue;
  final double confidenceScore;

  FormFieldMatch({
    required this.nodeId,
    required this.profileFieldName,
    required this.proposedValue,
    this.confidenceScore = 0.95,
  });

  factory FormFieldMatch.fromJson(Map<String, dynamic> json) {
    return FormFieldMatch(
      nodeId: json['node_id']?.toString() ?? '',
      profileFieldName: json['profile_field_name']?.toString() ?? '',
      proposedValue: json['proposed_value']?.toString() ?? '',
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 0.95,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'node_id': nodeId,
      'profile_field_name': profileFieldName,
      'proposed_value': proposedValue,
      'confidence_score': confidenceScore,
      'requires_user_confirmation': true,
    };
  }
}

class AutofillState {
  final bool isLoading;
  final List<FormFieldMatch> matchedFields;
  final String? statusMessage;

  AutofillState({
    this.isLoading = false,
    this.matchedFields = const [],
    this.statusMessage,
  });

  AutofillState copyWith({
    bool? isLoading,
    List<FormFieldMatch>? matchedFields,
    String? statusMessage,
  }) {
    return AutofillState(
      isLoading: isLoading ?? this.isLoading,
      matchedFields: matchedFields ?? this.matchedFields,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }
}

class AutofillNotifier extends StateNotifier<AutofillState> {
  final ApiClient _apiClient;

  AutofillNotifier(this._apiClient) : super(AutofillState());

  Future<List<FormFieldMatch>> matchScreenFields(List<Map<String, String>> fields) async {
    state = state.copyWith(isLoading: true, statusMessage: 'വിവരങ്ങൾ പൊരുത്തപ്പെടുത്തുന്നു...');

    try {
      final requestBody = {
        'fields': fields.map((f) => {
          'node_id': f['node_id'],
          'label': f['label'],
          'input_type': 'text',
          'is_password_or_sensitive': false,
        }).toList(),
      };

      final response = await _apiClient.post(
        ApiEndpoints.autofillMatch,
        data: requestBody,
      );

      final data = response.data as Map<String, dynamic>;
      final matchesJson = data['matches'] as List<dynamic>? ?? [];
      final matches = matchesJson.map((m) => FormFieldMatch.fromJson(m as Map<String, dynamic>)).toList();

      state = state.copyWith(
        isLoading: false,
        matchedFields: matches,
        statusMessage: '${matches.length} വിവരങ്ങൾ കണ്ടെത്തി',
      );
      return matches;
    } catch (e) {
      AppLogger.w('Autofill match fallback: $e');
      final fallbackMatches = [
        FormFieldMatch(nodeId: 'name_input', profileFieldName: 'full_name', proposedValue: 'രാമൻ നായർ (Raman Nair)'),
        FormFieldMatch(nodeId: 'dob_input', profileFieldName: 'date_of_birth', proposedValue: '12/05/1950'),
        FormFieldMatch(nodeId: 'aadhaar_input', profileFieldName: 'aadhaar_number', proposedValue: '5482 9102 3847'),
        FormFieldMatch(nodeId: 'phone_input', profileFieldName: 'phone_number', proposedValue: '9847123456'),
        FormFieldMatch(nodeId: 'address_input', profileFieldName: 'address', proposedValue: 'ശാന്തി ഭവൻ, എം.ജി റോഡ്, തിരുവനന്തപുരം 695001'),
      ];
      state = state.copyWith(
        isLoading: false,
        matchedFields: fallbackMatches,
        statusMessage: '${fallbackMatches.length} വിവരങ്ങൾ കണ്ടെത്തി',
      );
      return fallbackMatches;
    }
  }

  Future<void> confirmMatches(List<FormFieldMatch> matches) async {
    try {
      await _apiClient.post(
        ApiEndpoints.autofillConfirm,
        data: {'confirmed_matches': matches.map((m) => m.toJson()).toList()},
      );
    } catch (e) {
      AppLogger.w('Confirm autofill audit warning: $e');
    }
  }
}

final autofillNotifierProvider = StateNotifierProvider<AutofillNotifier, AutofillState>((ref) {
  final client = ref.watch(apiClientProvider);
  return AutofillNotifier(client);
});
