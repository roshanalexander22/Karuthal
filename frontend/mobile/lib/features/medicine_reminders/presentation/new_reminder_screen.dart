import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/sahaayi_button.dart';
import '../../../shared/widgets/sahaayi_text_field.dart';
import '../models/reminder_model.dart';
import '../providers/reminder_provider.dart';

class NewReminderScreen extends ConsumerStatefulWidget {
  const NewReminderScreen({super.key});

  @override
  ConsumerState<NewReminderScreen> createState() => _NewReminderScreenState();
}

class _NewReminderScreenState extends ConsumerState<NewReminderScreen> {
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController(text: '1 ഗുളിക');
  String _selectedTiming = 'ഭക്ഷണത്തിന് ശേഷം (After Food)';
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);

  final timings = [
    'ഭക്ഷണത്തിന് മുൻപ് (Before Food)',
    'ഭക്ഷണത്തിന് ശേഷം (After Food)',
    'ഉറങ്ങാൻ നേരം (At Bedtime)',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SahaayiColors.background,
      appBar: AppBar(
        title: const Text('പുതിയ മരുന്ന് ഓർമ്മപ്പെടുത്തൽ'),
        backgroundColor: SahaayiColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: SahaayiColors.textMain),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SahaayiTextField(
                controller: _nameController,
                label: 'മരുന്നിന്റെ പേര് (Medicine Name)',
                hint: 'ഉദാ: പാരാസെറ്റമോൾ 500mg',
                prefixIcon: Icons.medication_rounded,
              ),
              const SizedBox(height: 20),
              SahaayiTextField(
                controller: _dosageController,
                label: 'അളവ് (Dosage)',
                hint: '1 ഗുളിക / 5ml',
                prefixIcon: Icons.format_list_numbered_rounded,
              ),
              const SizedBox(height: 20),
              const Text(
                'കഴിക്കേണ്ട സമയം (Time)',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: SahaayiColors.textMain),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (picked != null) {
                    setState(() => _selectedTime = picked);
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: SahaayiColors.border, width: 1.5),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          color: SahaayiColors.primary, size: 24),
                      const SizedBox(width: 12),
                      Text(
                        _selectedTime.format(context),
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: SahaayiColors.textMain),
                      ),
                      const Spacer(),
                      const Text(
                        'മാറ്റുക (Change)',
                        style: TextStyle(
                            color: SahaayiColors.primaryDark,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'നിർദ്ദേശം (Instructions)',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: SahaayiColors.textMain),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: timings.map((timing) {
                  final isSelected = _selectedTiming == timing;
                  return ChoiceChip(
                    label: Text(
                      timing,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w500,
                        color:
                            isSelected ? Colors.white : SahaayiColors.textMain,
                      ),
                    ),
                    selected: isSelected,
                    selectedColor: SahaayiColors.primary,
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: BorderSide(
                        color: isSelected
                            ? SahaayiColors.primary
                            : SahaayiColors.border,
                      ),
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedTiming = timing);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 36),
              SahaayiButton(
                label: 'ഓർമ്മപ്പെടുത്തൽ സേവ് ചെയ്യുക',
                icon: Icons.check_circle_outline_rounded,
                onPressed: () {
                  final name = _nameController.text.trim();
                  final dosage = _dosageController.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('ദയവായി മരുന്നിന്റെ പേര് നൽകുക')),
                    );
                    return;
                  }

                  final now = DateTime.now();
                  final scheduled = DateTime(now.year, now.month, now.day,
                      _selectedTime.hour, _selectedTime.minute);

                  final newModel = ReminderModel(
                    id: DateTime.now().millisecondsSinceEpoch.toString(),
                    title: name,
                    dosage: dosage.isEmpty ? '1 ഗുളിക' : dosage,
                    instructionsMl: _selectedTiming,
                    reminderType: 'MEDICINE',
                    scheduledTime: scheduled,
                    isActive: true,
                  );

                  ref
                      .read(reminderNotifierProvider.notifier)
                      .addReminder(newModel);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('മരുന്ന് ഓർമ്മപ്പെടുത്തൽ ക്രമീകരിച്ചു!'),
                      backgroundColor: SahaayiColors.success,
                    ),
                  );
                  context.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
