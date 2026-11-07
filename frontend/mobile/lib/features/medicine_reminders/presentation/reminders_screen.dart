import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/services/tts_service.dart';
import '../models/reminder_model.dart';
import '../providers/reminder_provider.dart';

class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  void _speakReminder(WidgetRef ref, ReminderModel reminder) {
    final timeStr =
        '${reminder.scheduledTime.hour.toString().padLeft(2, '0')}:${reminder.scheduledTime.minute.toString().padLeft(2, '0')}';
    final text =
        'മരുന്ന്: ${reminder.title}. സമയം: $timeStr. അളവ്: ${reminder.dosage}. ${reminder.instructionsMl}.';
    ref.read(ttsServiceProvider).playBase64Audio(text);
  }

  Widget _buildReminderCard(BuildContext context, WidgetRef ref, ReminderModel item) {
    final timeStr =
        '${item.scheduledTime.hour > 12 ? item.scheduledTime.hour - 12 : item.scheduledTime.hour}:${item.scheduledTime.minute.toString().padLeft(2, '0')} ${item.scheduledTime.hour >= 12 ? 'PM' : 'AM'}';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_filled, size: 20, color: Color(0xFF1B5E20)),
                      const SizedBox(width: 6),
                      Text(
                        timeStr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B5E20),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Switch(
                  value: item.isActive,
                  activeTrackColor: const Color(0xFF1B5E20),
                  onChanged: (val) =>
                      ref.read(reminderNotifierProvider.notifier).toggleActive(item.id, val),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 26),
                  tooltip: 'ഒഴിവാക്കുക (Delete)',
                  onPressed: () =>
                      ref.read(reminderNotifierProvider.notifier).deleteReminder(item.id),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.title,
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 6),
            Text(
              'അളവ്: ${item.dosage} • ${item.instructionsMl}',
              style: TextStyle(fontSize: 16, color: Colors.blueGrey[700], fontWeight: FontWeight.w500),
            ),
            const Divider(height: 24),
            Row(
              children: [
                if (item.isTakenToday)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.green, width: 1.5),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'ഇന്ന് കഴിച്ചു (Taken Today)',
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ],
                    ),
                  )
                else
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(180, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.check, size: 24),
                    label: const Text(
                      'മരുന്ന് കഴിച്ചു (Dose Taken)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    onPressed: () {
                      ref.read(reminderNotifierProvider.notifier).acknowledgeDose(item.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('മരുന്ന് കഴിച്ചത് രേഖപ്പെടുത്തി!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                const Spacer(),
                IconButton.filledTonal(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blueGrey[50],
                    minimumSize: const Size(48, 48),
                  ),
                  icon: const Icon(Icons.volume_up, color: Colors.blueGrey, size: 26),
                  tooltip: 'കേൾക്കൂ (Read Aloud)',
                  onPressed: () => _speakReminder(ref, item),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(reminderNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('മരുന്ന് ഓർമ്മകൾ (Reminders)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_alarm, size: 28),
        label: const Text('പുതിയത് ചേർക്കുക', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        onPressed: () => context.push('/reminders/new'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.reminders.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.medication_liquid_outlined, size: 72, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text('റിമൈൻഡറുകൾ ഒന്നും ചേർത്തിട്ടില്ല.', style: TextStyle(fontSize: 19)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.push('/reminders/new'),
                        child: const Text('മരുന്ന് ഓർമ്മപ്പെടുത്തൽ ചേർക്കുക'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: state.reminders.length,
                  itemBuilder: (context, i) => _buildReminderCard(context, ref, state.reminders[i]),
                ),
    );
  }
}
