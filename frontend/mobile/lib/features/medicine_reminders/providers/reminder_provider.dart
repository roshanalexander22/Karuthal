import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/reminder_repository.dart';

final reminderRepoProvider = Provider((ref) => ReminderRepository());
final remindersListProvider =
    FutureProvider((ref) => ref.watch(reminderRepoProvider).getReminders());
