import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/platform/platform_channels.dart';

/// Single proposed field match from backend semantic matcher.
class AutofillProposal {
  final String nodeId;
  final String profileFieldName;
  final String proposedValue;
  final double confidenceScore;
  final bool isConfirmed;

  const AutofillProposal({
    required this.nodeId,
    required this.profileFieldName,
    required this.proposedValue,
    required this.confidenceScore,
    this.isConfirmed = true,
  });

  AutofillProposal copyWith({bool? isConfirmed}) {
    return AutofillProposal(
      nodeId: nodeId,
      profileFieldName: profileFieldName,
      proposedValue: proposedValue,
      confidenceScore: confidenceScore,
      isConfirmed: isConfirmed ?? this.isConfirmed,
    );
  }

  factory AutofillProposal.fromJson(Map<String, dynamic> json) {
    return AutofillProposal(
      nodeId: json['node_id']?.toString() ?? '',
      profileFieldName: json['profile_field_name']?.toString() ?? '',
      proposedValue: json['proposed_value']?.toString() ?? '',
      confidenceScore: (json['confidence_score'] as num?)?.toDouble() ?? 1.0,
      isConfirmed: true,
    );
  }

  Map<String, dynamic> toJson() => {
    'node_id': nodeId,
    'profile_field_name': profileFieldName,
    'proposed_value': proposedValue,
    'confidence_score': confidenceScore,
    'requires_user_confirmation': true,
  };
}

enum AutofillStatus { initial, scanning, ready, injecting, success, error }

class AutofillState {
  final AutofillStatus status;
  final bool isAccessibilityActive;
  final List<AutofillProposal> proposals;
  final String? errorMessage;
  final String? successMessage;

  const AutofillState({
    this.status = AutofillStatus.initial,
    this.isAccessibilityActive = false,
    this.proposals = const [],
    this.errorMessage,
    this.successMessage,
  });

  AutofillState copyWith({
    AutofillStatus? status,
    bool? isAccessibilityActive,
    List<AutofillProposal>? proposals,
    String? errorMessage,
    String? successMessage,
  }) {
    return AutofillState(
      status: status ?? this.status,
      isAccessibilityActive: isAccessibilityActive ?? this.isAccessibilityActive,
      proposals: proposals ?? this.proposals,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

class AutofillNotifier extends StateNotifier<AutofillState> {
  final ApiClient _apiClient;

  AutofillNotifier(this._apiClient) : super(const AutofillState()) {
    checkAccessibility();
  }

  Future<void> checkAccessibility() async {
    final active = await PlatformChannels.isAccessibilityServiceActive();
    state = state.copyWith(isAccessibilityActive: active);
  }

  Future<void> openSettings() async {
    await PlatformChannels.openAccessibilitySettings();
  }

  void toggleProposal(String nodeId) {
    final updated = state.proposals.map((p) {
      if (p.nodeId == nodeId) {
        return p.copyWith(isConfirmed: !p.isConfirmed);
      }
      return p;
    }).toList();
    state = state.copyWith(proposals: updated);
  }

  Future<void> scanScreenAndMatch() async {
    state = state.copyWith(status: AutofillStatus.scanning, errorMessage: null);

    try {
      final isEnabled = await PlatformChannels.isAccessibilityServiceActive();
      if (!isEnabled) {
        state = state.copyWith(
          status: AutofillStatus.error,
          isAccessibilityActive: false,
          errorMessage: 'സഹായ സേവനം പ്രവർത്തനക്ഷമമല്ല. ക്രമീകരണങ്ങളിൽ ഇത് ഓൺ ചെയ്യുക.',
        );
        return;
      }
      state = state.copyWith(isAccessibilityActive: true);

      // 1. Read on-screen elements via accessibility bridge
      final rawElements = await PlatformChannels.requestScreenRead();
      if (rawElements.isEmpty) {
        state = state.copyWith(
          status: AutofillStatus.ready,
          proposals: [],
          successMessage: 'സ്ക്രീനിൽ പൂരിപ്പിക്കാവുന്ന ഫോം ഫീൽഡുകൾ കണ്ടെത്തിയില്ല.',
        );
        return;
      }

      // 2. Prepare payload for backend semantic matcher
      final List<Map<String, dynamic>> fieldPayloads = [];
      for (final el in rawElements) {
        final label = el['label']?.toString() ?? el['hint']?.toString() ?? '';
        final nodeId = el['nodeId']?.toString() ?? '';
        if (label.isNotEmpty && nodeId.isNotEmpty) {
          fieldPayloads.add({
            'node_id': nodeId,
            'label': label,
            'input_type': 'text',
            'is_password_or_sensitive': false,
          });
        }
      }

      if (fieldPayloads.isEmpty) {
        state = state.copyWith(
          status: AutofillStatus.ready,
          proposals: [],
          successMessage: 'പൂരിപ്പിക്കാവുന്ന ഫീൽഡുകൾ ലഭ്യമല്ല.',
        );
        return;
      }

      // 3. Match against verified memory bank via REST API
      final res = await _apiClient.post(
        ApiEndpoints.autofillMatch,
        data: {'fields': fieldPayloads},
      );

      final matchesData = (res.data as Map<String, dynamic>)['matches'] as List<dynamic>? ?? [];
      final proposals = matchesData
          .map((m) => AutofillProposal.fromJson(m as Map<String, dynamic>))
          .toList();

      state = state.copyWith(
        status: AutofillStatus.ready,
        proposals: proposals,
        successMessage: proposals.isEmpty
            ? 'നിങ്ങളുടെ രേഖകളിൽ നിന്ന് പൊരുത്തപ്പെടുന്ന വിവരങ്ങൾ കണ്ടെത്താനായില്ല.'
            : null,
      );
    } catch (e) {
      state = state.copyWith(
        status: AutofillStatus.error,
        errorMessage: 'ഫീൽഡ് പരിശോധന പരാജയപ്പെട്ടു: $e',
      );
    }
  }

  Future<void> confirmAndInject() async {
    final confirmed = state.proposals.where((p) => p.isConfirmed).toList();
    if (confirmed.isEmpty) return;

    state = state.copyWith(status: AutofillStatus.injecting);

    try {
      // 1. Log compliance audit trail to backend
      await _apiClient.post(
        ApiEndpoints.autofillConfirm,
        data: {
          'confirmed_matches': confirmed.map((p) => p.toJson()).toList(),
        },
      );

      // 2. Inject values into screen nodes via platform channel
      int successCount = 0;
      for (final proposal in confirmed) {
        final ok = await PlatformChannels.injectFieldValue(
          proposal.nodeId,
          proposal.proposedValue,
        );
        if (ok) successCount++;
      }

      state = state.copyWith(
        status: AutofillStatus.success,
        successMessage: '$successCount ഫീൽഡുകൾ വിജയകരമായി പൂരിപ്പിച്ചു. ദയവായി പരിശോധിക്കുക.',
        proposals: [],
      );
    } catch (e) {
      state = state.copyWith(
        status: AutofillStatus.error,
        errorMessage: 'ഫോം പൂരിപ്പിക്കൽ പരാജയപ്പെട്ടു: $e',
      );
    }
  }
}

final autofillProvider = StateNotifierProvider<AutofillNotifier, AutofillState>((ref) {
  final client = ref.watch(apiClientProvider);
  return AutofillNotifier(client);
});
