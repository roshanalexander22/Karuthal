import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/reminder_provider.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(remindersListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('മരുന്ന് & ആശുപത്രി ഓർമ്മകൾ (Reminders)')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_alarm),
        label: const Text('പുതിയത് ചേർക്കുക (Add)'),
        onPressed: () => context.push('/reminders/new'),
      ),
      body: listAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text(
                'ഓർമ്മപ്പെടുത്തലുകൾ ഒന്നും ചേർത്തിട്ടില്ല.\nപുതിയത് ചേർക്കാൻ താഴെയുള്ള + അമർത്തുക.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final timeFormat = DateFormat('hh:mm a');
          final dateFormat = DateFormat('dd MMM yyyy');

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(remindersListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              itemBuilder: (context, i) {
                final item = items[i];
                final isMed = item.reminderType == 'MEDICINE';
                final isTaken = item.status == 'TAKEN';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color: isTaken ? Colors.green.withValues(alpha: 0.5) : Colors.grey.withValues(alpha: 0.2),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: isMed ? Colors.purple.shade50 : Colors.teal.shade50,
                              radius: 24,
                              child: Icon(
                                isMed ? Icons.medication : Icons.local_hospital,
                                size: 28,
                                color: isMed ? Colors.purple : Colors.teal,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.title,
                                    style: TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      decoration: isTaken ? TextDecoration.lineThrough : null,
                                    ),
                                  ),
                                  if (item.dosage != null && item.dosage!.isNotEmpty)
                                    Text('അളവ് (Dosage): ${item.dosage}', style: const TextStyle(fontSize: 15, color: Colors.grey)),
                                  if (item.doctorName != null && item.doctorName!.isNotEmpty)
                                    Text('ഡോക്ടർ: ${item.doctorName} (${item.hospitalName ?? ""})', style: const TextStyle(fontSize: 15, color: Colors.grey)),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              tooltip: 'ഒഴിവാക്കുക (Delete)',
                              onPressed: () async {
                                await ref.read(reminderRepoProvider).deleteReminder(item.id);
                                ref.invalidate(remindersListProvider);
                              },
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 20, color: Colors.grey),
                                const SizedBox(width: 6),
                                Text(
                                  '${timeFormat.format(item.scheduledTime)} (${dateFormat.format(item.scheduledTime)})',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: isTaken ? Colors.green.shade100 : Colors.teal,
                                foregroundColor: isTaken ? Colors.green.shade900 : Colors.white,
                              ),
                              icon: Icon(isTaken ? Icons.check_circle : Icons.done),
                              label: Text(isTaken ? 'കഴിച്ചു (Taken)' : 'കഴിച്ചു (Mark Done)'),
                              onPressed: isTaken
                                  ? null
                                  : () async {
                                      await ref.read(reminderRepoProvider).acknowledgeReminder(item.id);
                                      ref.invalidate(remindersListProvider);
                                    },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
