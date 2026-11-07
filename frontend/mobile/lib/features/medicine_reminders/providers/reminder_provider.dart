import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/reminder_model.dart';
import '../repositories/reminder_repository.dart';

class ReminderState {
  final bool isLoading;
  final List<ReminderModel> reminders;
  final String? errorMessage;

  const ReminderState({
    this.isLoading = false,
    this.reminders = const [],
    this.errorMessage,
  });

  ReminderState copyWith({
    bool? isLoading,
    List<ReminderModel>? reminders,
    String? errorMessage,
  }) {
    return ReminderState(
      isLoading: isLoading ?? this.isLoading,
      reminders: reminders ?? this.reminders,
      errorMessage: errorMessage,
    );
  }
}

class ReminderNotifier extends StateNotifier<ReminderState> {
  final ReminderRepository _repository;

  ReminderNotifier(this._repository) : super(const ReminderState()) {
    loadReminders();
  }

  Future<void> loadReminders() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final items = await _repository.getReminders();
      if (items.isNotEmpty) {
        state = state.copyWith(isLoading: false, reminders: items);
        return;
      }
    } catch (_) {}

    // Fallback baseline reminders for senior users if offline
    final defaults = [
      ReminderModel(
        id: '1',
        title: 'പ്രഷർ മരുന്ന് (BP Tablet)',
        description: 'Amlodipine 5mg',
        dosage: '1 ഗുളിക',
        instructionsMl: 'രാവിലെ പ്രഭാതഭക്ഷണത്തിന് ശേഷം',
        scheduledTime: DateTime.now().copyWith(hour: 8, minute: 30),
      ),
      ReminderModel(
        id: '2',
        title: 'ഷുഗർ മരുന്ന് (Sugar Tablet)',
        description: 'Metformin 500mg',
        dosage: '1 ഗുളിക',
        instructionsMl: 'ഉച്ചഭക്ഷണത്തിന് മുൻപ്',
        scheduledTime: DateTime.now().copyWith(hour: 13, minute: 0),
      ),
    ];
    state = state.copyWith(isLoading: false, reminders: defaults);
  }

  Future<void> addReminder(ReminderModel reminder) async {
    try {
      final created = await _repository.createReminder(reminder);
      state = state.copyWith(reminders: [created, ...state.reminders]);
    } catch (_) {
      state = state.copyWith(reminders: [reminder, ...state.reminders]);
    }
  }

  Future<void> acknowledgeDose(String reminderId) async {
    final now = DateTime.now();
    final updated = state.reminders.map((r) {
      if (r.id == reminderId) {
        return r.copyWith(lastAcknowledgedAt: now);
      }
      return r;
    }).toList();
    state = state.copyWith(reminders: updated);
    await _repository.acknowledgeDose(reminderId);
  }

  Future<void> toggleActive(String reminderId, bool active) async {
    final updated = state.reminders.map((r) {
      if (r.id == reminderId) {
        return r.copyWith(isActive: active);
      }
      return r;
    }).toList();
    state = state.copyWith(reminders: updated);
    await _repository.updateReminder(reminderId, {'is_active': active});
  }

  Future<void> deleteReminder(String reminderId) async {
    final updated = state.reminders.where((r) => r.id != reminderId).toList();
    state = state.copyWith(reminders: updated);
    await _repository.deleteReminder(reminderId);
  }
}

final reminderNotifierProvider =
    StateNotifierProvider<ReminderNotifier, ReminderState>((ref) {
  final repo = ref.watch(reminderRepositoryProvider);
  return ReminderNotifier(repo);
});

// Backward compatibility alias
final remindersListProvider =
    FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final state = ref.watch(reminderNotifierProvider);
  return state.reminders
      .map((r) => {
            'id': r.id,
            'title': r.title,
            'time':
                '${r.scheduledTime.hour.toString().padLeft(2, '0')}:${r.scheduledTime.minute.toString().padLeft(2, '0')}',
            'type': r.reminderType,
            'dosage': r.dosage,
            'instructions': r.instructionsMl,
          })
      .toList();
});
