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
            final activeReminders = reminders.isNotEmpty
                ? reminders.map((r) => {
                    "id": r['id'].toString(),
                    "title": r['title'].toString(),
                    "dosage":
                        '${r['dosage'] ?? "1 ഗുളിക"} • ${r['instructions'] ?? "ഭക്ഷണത്തിന് ശേഷം"}',
                    "time": r['time'].toString().contains('AM') ||
                            r['time'].toString().contains('PM')
                        ? r['time'].toString()
                        : 'സമയം: ${r['time']}',
                    "isActive": (r['isActive'] as bool?) ?? true,
                    "isTaken": _completedIds.contains(r['id'].toString()) ||
                        (r['isTaken'] == true),
                  }).toList()
                : [
                    {
                      "id": "1",
                      "title": "പ്രഷർ മരുന്ന് (Telmisartan 40mg)",
                      "dosage": "1 ഗുളിക • ഭക്ഷണത്തിന് ശേഷം",
                      "time": "രാവിലെ 08:00 AM",
                      "isActive": true,
                      "isTaken": _completedIds.contains('1'),
                    },
                    {
                      "id": "2",
                      "title": "ഷുഗർ മരുന്ന് (Metformin 500mg)",
                      "dosage": "1 ഗുളിക • ഭക്ഷണത്തിന് മുൻപ്",
                      "time": "ഉച്ചയ്ക്ക് 01:30 PM",
                      "isActive": true,
                      "isTaken": _completedIds.contains('2'),
                    },
                    {
                      "id": "3",
                      "title": "കൊളസ്ട്രോൾ ഗുളിക (Atorvastatin 10mg)",
                      "dosage": "1 ഗുളിക • ഉറങ്ങാൻ നേരം",
                      "time": "രാത്രി 09:00 PM",
                      "isActive": true,
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
                          'ഇന്ന് ${activeReminders.length} മരുന്നുകൾ നിശ്ചയിച്ചിട്ടുണ്ട്. കൃത്യസമയത്ത് കഴിക്കാൻ സഹായി ഓർമ്മിപ്പിക്കും.',
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

                ...activeReminders.map((rem) {
                  final isTaken = rem['isTaken'] as bool;
                  final isActive = rem['isActive'] as bool? ?? true;
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
                    ref
                        .read(reminderNotifierProvider.notifier)
                        .acknowledgeDose(id);
                  }

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14.0),
                    child: Opacity(
                      opacity: isActive ? 1.0 : 0.65,
                      child: AccessibleCard(
                        onTap: isActive ? toggleTaken : null,
                        backgroundColor: !isActive
                            ? const Color(0xFFF1F5F9)
                            : (isTaken
                                ? const Color(0xFFF8FAFC)
                                : Colors.white),
                        border: !isActive
                            ? BorderSide(color: Colors.grey.shade400, width: 1)
                            : (isTaken
                                ? BorderSide(
                                    color: SahaayiColors.success.withAlpha(120),
                                    width: 1.5)
                                : const BorderSide(
                                    color: SahaayiColors.border, width: 1.5)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top Row: Active/Off Switch & Status Badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? SahaayiColors.secondary
                                        : Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        isActive
                                            ? Icons.notifications_active_rounded
                                            : Icons.notifications_off_rounded,
                                        size: 16,
                                        color: isActive
                                            ? SahaayiColors.primaryDark
                                            : Colors.grey.shade700,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        isActive
                                            ? 'ഓർമ്മപ്പെടുത്തൽ സജീവം'
                                            : 'ഓർമ്മപ്പെടുത്തൽ ഓഫാക്കി',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: isActive
                                              ? SahaayiColors.primaryDark
                                              : Colors.grey.shade700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      isActive ? 'ഓൺ' : 'ഓഫ്',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isActive
                                            ? SahaayiColors.primaryDark
                                            : Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Switch(
                                      value: isActive,
                                      activeThumbColor: SahaayiColors.primary,
                                      onChanged: (val) {
                                        ref
                                            .read(reminderNotifierProvider
                                                .notifier)
                                            .toggleActive(id, val);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(val
                                                ? '${rem['title']} ഓർമ്മപ്പെടുത്തൽ സജീവമാക്കി!'
                                                : '${rem['title']} ഓർമ്മപ്പെടുത്തൽ ഓഫാക്കി!'),
                                            backgroundColor: val
                                                ? SahaayiColors.success
                                                : Colors.grey.shade800,
                                            duration:
                                                const Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                          Icons.delete_outline_rounded,
                                          color: Colors.grey,
                                          size: 20),
                                      tooltip: 'നീക്കം ചെയ്യുക',
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        ref
                                            .read(reminderNotifierProvider
                                                .notifier)
                                            .deleteReminder(id);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'മരുന്ന് ഓർമ്മപ്പെടുത്തൽ നീക്കം ചെയ്തു.'),
                                            duration: Duration(seconds: 2),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 16),

                            // Main Reminder Content Row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: isTaken
                                        ? Colors.grey.shade200
                                        : SahaayiColors.accent,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    Icons.medication_rounded,
                                    color: isTaken
                                        ? Colors.grey
                                        : const Color(0xFF2B6CB0),
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        rem['title'] as String,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: isTaken || !isActive
                                              ? SahaayiColors.textSecondary
                                              : SahaayiColors.textMain,
                                          decoration: isTaken
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        rem['dosage'] as String,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isTaken || !isActive
                                              ? Colors.grey
                                              : SahaayiColors.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isTaken || !isActive
                                              ? Colors.grey.shade200
                                              : SahaayiColors.secondary,
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          rem['time'] as String,
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                            color: isTaken || !isActive
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
                                  iconSize: 34,
                                  tooltip: isTaken
                                      ? 'കഴിച്ചതായി രേഖപ്പെടുത്തി'
                                      : 'കഴിച്ചതായി അടയാളപ്പെടുത്തുക',
                                  icon: Icon(
                                    isTaken
                                        ? Icons.check_circle_rounded
                                        : Icons.radio_button_unchecked_rounded,
                                    color: isTaken
                                        ? SahaayiColors.success
                                        : (isActive
                                            ? SahaayiColors.primary
                                            : Colors.grey),
                                  ),
                                  onPressed: isActive ? toggleTaken : null,
                                ),
                              ],
                            ),
                          ],
                        ),
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
