import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';
import '../../../core/utils/logger.dart';
import '../models/autofill_match_model.dart';

final autofillRepositoryProvider = Provider<AutofillRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AutofillRepository(apiClient);
});

class AutofillRepository {
  final ApiClient _apiClient;

  AutofillRepository(this._apiClient);

  Future<List<FieldMatchProposalModel>> matchFields(
    List<ScreenFormFieldModel> fields,
  ) async {
    try {
      final response = await _apiClient.post<dynamic>(
        ApiEndpoints.autofillMatch,
        data: {
          'fields': fields.map((f) => f.toJson()).toList(),
        },
      );

      if (response.data is Map<String, dynamic>) {
        final matches = response.data['matches'] as List<dynamic>? ?? [];
        return matches
            .map((m) => FieldMatchProposalModel.fromJson(m as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      AppLogger.e('Autofill match failed: $e');
      return [];
    }
  }

  Future<bool> confirmAutofill(
    List<FieldMatchProposalModel> confirmedMatches,
  ) async {
    try {
      final response = await _apiClient.post<dynamic>(
        ApiEndpoints.autofillConfirm,
        data: {
          'confirmed_matches': confirmedMatches.map((m) => m.toJson()).toList(),
        },
      );
      return response.statusCode == 200;
    } catch (e) {
      AppLogger.e('Autofill confirm audit log failed: $e');
      return true;
    }
  }
}
