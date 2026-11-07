import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/accessible_card.dart';
import '../providers/reminder_provider.dart';

class RemindersScreen extends ConsumerStatefulWidget {
  const RemindersScreen({super.key});

  @override
  ConsumerState<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends ConsumerState<RemindersScreen> {
  final Set<String> _completedIds = {
    '1'
  }; // Simulated state for visual distinction

  @override
  Widget build(BuildContext context) {
    final listAsync = ref.watch(remindersListProvider);

    return Scaffold(
      backgroundColor: SahaayiColors.background,
      appBar: AppBar(
        title: const Text('മരുന്ന് ഓർമ്മകൾ (Reminders)'),
        backgroundColor: SahaayiColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: SahaayiColors.textMain),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          height: 58,
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: SahaayiColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              elevation: 3,
            ),
            icon: const Icon(Icons.add_alarm_rounded, size: 26),
            label: const Text(
              'പുതിയ മരുന്ന് ചേർക്കുക (Add Reminder)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            onPressed: () => context.push('/reminders/new'),
          ),
        ),
      ),
      body: SafeArea(
        child: listAsync.when(
          data: (reminders) {
            final sampleReminders = [
              {
                "id": "1",
                "title": "പ്രഷർ മരുന്ന് (Telmisartan 40mg)",
                "dosage": "1 ഗുളിക • ഭക്ഷണത്തിന് ശേഷം",
                "time": "രാവിലെ 08:00 AM",
                "isTaken": _completedIds.contains('1'),
              },
              {
                "id": "2",
                "title": "ഷുഗർ മരുന്ന് (Metformin 500mg)",
                "dosage": "1 ഗുളിക • ഭക്ഷണത്തിന് മുൻപ്",
                "time": "ഉച്ചയ്ക്ക് 01:30 PM",
                "isTaken": _completedIds.contains('2'),
              },
              {
                "id": "3",
                "title": "കൊളസ്ട്രോൾ ഗുളിക (Atorvastatin 10mg)",
                "dosage": "1 ഗുളിക • ഉറങ്ങാൻ നേരം",
                "time": "രാത്രി 09:00 PM",
                "isTaken": _completedIds.contains('3'),
              },
            ];

            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
              children: [
                // Summary Card
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: SahaayiColors.secondary,
                    borderRadius: BorderRadius.circular(20),
                    border:
                        Border.all(color: SahaayiColors.primary.withAlpha(80)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: SahaayiColors.primaryDark, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'ഇന്ന് 3 മരുന്നുകൾ നിശ്ചയിച്ചിട്ടുണ്ട്. കൃത്യസമയത്ത് കഴിക്കാൻ സഹായി ഓർമ്മിപ്പിക്കും.',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: SahaayiColors.primaryDark.withAlpha(240),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'ഇന്നത്തെ മരുന്നുകൾ (Today’s Schedule)',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: SahaayiColors.textMain),
                ),
                const SizedBox(height: 12),

                ...sampleReminders.map((rem) {
                  final isTaken = rem['isTaken'] as bool;
                  final id = rem['id'] as String;

                  void toggleTaken() {
                    setState(() {
                      if (isTaken) {
                        _completedIds.remove(id);
                      } else {
                        _completedIds.add(id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                '${rem['title']} കഴിച്ചതായി രേഖപ്പെടുത്തി!'),
                            backgroundColor: SahaayiColors.success,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    });
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: AccessibleCard(
                      onTap: toggleTaken,
                      backgroundColor:
                          isTaken ? const Color(0xFFF1F5F9) : Colors.white,
                      border: isTaken
                          ? BorderSide(color: Colors.grey.shade300)
                          : const BorderSide(
                              color: SahaayiColors.border, width: 1.5),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              color: isTaken
                                  ? Colors.grey.shade200
                                  : SahaayiColors.accent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              Icons.medication_rounded,
                              color: isTaken
                                  ? Colors.grey
                                  : const Color(0xFF2B6CB0),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  rem['title'] as String,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: isTaken
                                        ? SahaayiColors.textSecondary
                                        : SahaayiColors.textMain,
                                    decoration: isTaken
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  rem['dosage'] as String,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isTaken
                                        ? Colors.grey
                                        : SahaayiColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: isTaken
                                        ? Colors.grey.shade200
                                        : SahaayiColors.secondary,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    rem['time'] as String,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: isTaken
                                          ? Colors.grey
                                          : SahaayiColors.primaryDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Action to mark taken
                          IconButton(
                            iconSize: 32,
                            icon: Icon(
                              isTaken
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: isTaken
                                  ? SahaayiColors.success
                                  : SahaayiColors.primary,
                            ),
                            onPressed: toggleTaken,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            );
          },
          loading: () => const Center(
              child: CircularProgressIndicator(color: SahaayiColors.primary)),
          error: (e, _) => Center(child: Text('പിശക്: $e')),
        ),
      ),
    );
  }
}
