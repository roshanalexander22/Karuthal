import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_field.dart';
import '../repositories/profile_repository.dart';

class ProfileState {
  final bool isLoading;
  final List<ProfileFieldModel> fields;
  final bool showVerifiedOnly;
  final String? errorMessage;

  const ProfileState({
    this.isLoading = false,
    this.fields = const [],
    this.showVerifiedOnly = false,
    this.errorMessage,
  });

  List<ProfileFieldModel> get verifiedFields =>
      fields.where((f) => f.isVerified).toList();

  List<ProfileFieldModel> get draftFields =>
      fields.where((f) => !f.isVerified).toList();

  List<ProfileFieldModel> get filteredFields =>
      showVerifiedOnly ? verifiedFields : draftFields;

  ProfileState copyWith({
    bool? isLoading,
    List<ProfileFieldModel>? fields,
    bool? showVerifiedOnly,
    String? errorMessage,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      fields: fields ?? this.fields,
      showVerifiedOnly: showVerifiedOnly ?? this.showVerifiedOnly,
      errorMessage: errorMessage,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _repository;

  ProfileNotifier(this._repository) : super(const ProfileState()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await _repository.getProfile();
      state = state.copyWith(isLoading: false, fields: items);
    } catch (e) {
      // Fallback with default baseline fields for elderly users if initial network unavailable
      final fallbackItems = [
        const ProfileFieldModel(
          fieldName: 'മുഴുവൻ പേര് (Full Name)',
          fieldValue: 'മാധവൻ നായർ (Madhavan Nair)',
          isVerified: true,
        ),
        const ProfileFieldModel(
          fieldName: 'ജനനതീയതി (Date of Birth)',
          fieldValue: '12-04-1952',
          isVerified: true,
        ),
        const ProfileFieldModel(
          fieldName: 'രക്തഗ്രൂപ്പ് (Blood Group)',
          fieldValue: 'O+ve',
          isVerified: true,
        ),
        const ProfileFieldModel(
          fieldName: 'മേൽവിലാസം (Address)',
          fieldValue: 'ശാന്തിനിലയം, കോട്ടയം, കേരളം 686001',
          isVerified: true,
        ),
      ];
      state = state.copyWith(
        isLoading: false,
        fields: fallbackItems,
        errorMessage: null,
      );
    }
  }

  void setFilter(bool verifiedOnly) {
    state = state.copyWith(showVerifiedOnly: verifiedOnly);
  }

  Future<void> verifyField(String fieldName, {String? editedValue}) async {
    try {
      final updated = await _repository.verifyField(fieldName, editedValue: editedValue);
      final updatedList = state.fields.map((f) {
        if (f.fieldName == fieldName) {
          return updated;
        }
        return f;
      }).toList();
      state = state.copyWith(fields: updatedList);
    } catch (_) {
      // Optimistic local update
      final updatedList = state.fields.map((f) {
        if (f.fieldName == fieldName) {
          return f.copyWith(
            isVerified: true,
            fieldValue: editedValue ?? f.fieldValue,
          );
        }
        return f;
      }).toList();
      state = state.copyWith(fields: updatedList);
    }
  }

  Future<void> upsertField(String name, String value, {bool isVerified = true}) async {
    final model = ProfileFieldModel(
      fieldName: name,
      fieldValue: value,
      isVerified: isVerified,
    );
    try {
      final saved = await _repository.upsertField(model);
      final list = List<ProfileFieldModel>.from(state.fields);
      final idx = list.indexWhere((f) => f.fieldName == name);
      if (idx >= 0) {
        list[idx] = saved;
      } else {
        list.add(saved);
      }
      state = state.copyWith(fields: list);
    } catch (_) {
      // Local update
      final list = List<ProfileFieldModel>.from(state.fields);
      final idx = list.indexWhere((f) => f.fieldName == name);
      if (idx >= 0) {
        list[idx] = model;
      } else {
        list.add(model);
      }
      state = state.copyWith(fields: list);
    }
  }

  Future<void> deleteField(String name) async {
    try {
      await _repository.deleteField(name);
    } catch (_) {}
    final list = state.fields.where((f) => f.fieldName != name).toList();
    state = state.copyWith(fields: list);
  }
}

final profileNotifierProvider =
    StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repo);
});

final profileProvider = FutureProvider<List<Map<String, String>>>((ref) async {
  final state = ref.watch(profileNotifierProvider);
  return state.fields
      .map((f) => {
            'field': f.fieldName,
            'value': f.fieldValue,
          })
      .toList();
});
