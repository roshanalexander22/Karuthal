import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../repositories/reminder_repository.dart';

final reminderRepoProvider = Provider<ReminderRepository>((ref) {
  final client = ref.watch(apiClientProvider);
  return ReminderRepository(client);
});

final remindersListProvider = FutureProvider.autoDispose<List<ReminderModel>>((ref) async {
  final repo = ref.watch(reminderRepoProvider);
  return repo.getReminders();
});
