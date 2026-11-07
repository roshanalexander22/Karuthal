import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/reminder_model.dart';
import '../providers/reminder_provider.dart';

class NewReminderScreen extends ConsumerStatefulWidget {
  const NewReminderScreen({super.key});

  @override
  ConsumerState<NewReminderScreen> createState() => _NewReminderScreenState();
}

class _NewReminderScreenState extends ConsumerState<NewReminderScreen> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 30);
  String _selectedDosage = '1 ഗുളിക (1 Tablet)';
  String _selectedInstruction = 'ഭക്ഷണത്തിന് ശേഷം (After food)';

  final List<String> _dosages = [
    '1 ഗുളിക (1 Tablet)',
    '1/2 ഗുളിക (Half Tablet)',
    '2 ഗുളിക (2 Tablets)',
    '1 സ്പൂൺ സിറപ്പ് (1 Spoon Syrup)',
    'ഇൻസുലിൻ (Insulin)',
  ];

  final List<String> _instructions = [
    'ഭക്ഷണത്തിന് ശേഷം (After food)',
    'ഭക്ഷണത്തിന് മുൻപ് (Before food)',
    'രാത്രി ഉറങ്ങുന്നതിന് മുൻപ് (Before sleep)',
    'വെറുംവയറ്റിൽ (Empty stomach)',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _saveReminder() {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('ദയവായി മരുന്നിന്റെ പേര് നൽകുക (Enter medicine name)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final now = DateTime.now();
    final schedDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final model = ReminderModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: _descController.text.trim().isNotEmpty ? _descController.text.trim() : null,
      dosage: _selectedDosage,
      instructionsMl: _selectedInstruction,
      scheduledTime: schedDateTime,
      recurrenceRule: 'DAILY',
    );

    ref.read(reminderNotifierProvider.notifier).addReminder(model);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('മരുന്ന് ഓർമ്മപ്പെടുത്തൽ വിജയകരമായി സൂക്ഷിച്ചു!'),
        backgroundColor: Colors.green,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final formattedTime =
        '${_selectedTime.hour > 12 ? _selectedTime.hour - 12 : (_selectedTime.hour == 0 ? 12 : _selectedTime.hour)}:${_selectedTime.minute.toString().padLeft(2, '0')} ${_selectedTime.hour >= 12 ? 'PM' : 'AM'}';

    return Scaffold(
      appBar: AppBar(
        title: const Text('പുതിയ ഓർമ്മപ്പെടുത്തൽ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Medicine Name
            const Text(
              'മരുന്നിന്റെ പേര് (Medicine Name)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              style: const TextStyle(fontSize: 19),
              decoration: InputDecoration(
                hintText: 'ഉദാ: പ്രഷർ ഗുളിക (Amlodipine)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
            ),
            const SizedBox(height: 20),

            // Time Selection
            const Text(
              'മരുന്ന് കഴിക്കേണ്ട സമയം (Schedule Time)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: _pickTime,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[50],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.access_time, size: 28, color: Color(0xFF1B5E20)),
                    const SizedBox(width: 14),
                    Text(
                      formattedTime,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                    ),
                    const Spacer(),
                    const Text('മാറ്റുക (Change)', style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Dosage Dropdown
            const Text(
              'അളവ് (Dosage)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedDosage,
              style: const TextStyle(fontSize: 18, color: Color(0xFF1E293B)),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: _dosages
                  .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedDosage = val);
              },
            ),
            const SizedBox(height: 20),

            // Timing Instructions
            const Text(
              'നിർദ്ദേശം (Instructions)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedInstruction,
              style: const TextStyle(fontSize: 18, color: Color(0xFF1E293B)),
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: _instructions
                  .map((ins) => DropdownMenuItem(value: ins, child: Text(ins)))
                  .toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedInstruction = val);
              },
            ),
            const SizedBox(height: 36),

            // Save Button (High contrast, minimum 56dp height)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                icon: const Icon(Icons.check_circle_outline, size: 26),
                label: const Text(
                  'സേവ് ചെയ്യുക (Save Reminder)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: _saveReminder,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
