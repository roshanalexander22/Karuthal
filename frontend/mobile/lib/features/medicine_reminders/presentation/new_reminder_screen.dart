import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/sahaayi_button.dart';
import '../../../shared/widgets/sahaayi_text_field.dart';
import '../providers/reminder_provider.dart';
import '../repositories/reminder_repository.dart';

class NewReminderScreen extends ConsumerStatefulWidget {
  const NewReminderScreen({super.key});

  @override
  ConsumerState<NewReminderScreen> createState() => _NewReminderScreenState();
}

class _NewReminderScreenState extends ConsumerState<NewReminderScreen> {
  final _titleController = TextEditingController();
  final _dosageController = TextEditingController();
  final _doctorController = TextEditingController();
  final _hospitalController = TextEditingController();

  String _reminderType = 'MEDICINE';
  String _recurrence = 'DAILY';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isLoading = false;

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _saveReminder() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ദയവായി പേര് രേഖപ്പെടുത്തുക (Please enter title)')),
      );
      return;
    }

    setState(() => _isLoading = true);

    final scheduled = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    final reminder = ReminderModel(
      id: '',
      title: _titleController.text.trim(),
      reminderType: _reminderType,
      scheduledTime: scheduled,
      recurrenceRule: _recurrence,
      dosage: _reminderType == 'MEDICINE' ? _dosageController.text.trim() : null,
      doctorName: _reminderType == 'APPOINTMENT' ? _doctorController.text.trim() : null,
      hospitalName: _reminderType == 'APPOINTMENT' ? _hospitalController.text.trim() : null,
    );

    try {
      await ref.read(reminderRepoProvider).createReminder(reminder);
      ref.invalidate(remindersListProvider);
      if (mounted) context.pop();
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('ഓർമ്മപ്പെടുത്തൽ സേവ് ചെയ്യാൻ കഴിഞ്ഞില്ല: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('പുതിയ ഓർമ്മപ്പെടുത്തൽ (New Reminder)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Type toggle
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'MEDICINE', label: Text('മരുന്ന് (Medicine)'), icon: Icon(Icons.medication)),
                ButtonSegment(value: 'APPOINTMENT', label: Text('ഡോക്ടർ (Doctor)'), icon: Icon(Icons.local_hospital)),
              ],
              selected: {_reminderType},
              onSelectionChanged: (val) => setState(() => _reminderType = val.first),
            ),
            const SizedBox(height: 20),

            SahaayiTextField(
              controller: _titleController,
              label: _reminderType == 'MEDICINE' ? 'മരുന്നിന്റെ പേര് (Medicine Name)' : 'സന്ദർശന വിഷയം (Purpose/Specialty)',
            ),
            const SizedBox(height: 16),

            if (_reminderType == 'MEDICINE') ...[
              SahaayiTextField(
                controller: _dosageController,
                label: 'ഡോസേജ് / അളവ് (Dosage, e.g. 1 ഗുളിക / 500mg)',
              ),
              const SizedBox(height: 16),
            ] else ...[
              SahaayiTextField(
                controller: _doctorController,
                label: 'ഡോക്ടറുടെ പേര് (Doctor Name)',
              ),
              const SizedBox(height: 16),
              SahaayiTextField(
                controller: _hospitalController,
                label: 'ആശുപത്രി / ക്ലിനിക്ക് (Hospital Name)',
              ),
              const SizedBox(height: 16),
            ],

            // Date and Time selection
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today),
                    label: Text('${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}', style: const TextStyle(fontSize: 16)),
                    onPressed: _pickDate,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.access_time),
                    label: Text(_selectedTime.format(context), style: const TextStyle(fontSize: 16)),
                    onPressed: _pickTime,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Recurrence
            DropdownButtonFormField<String>(
              initialValue: _recurrence,
              decoration: const InputDecoration(labelText: 'ആവർത്തനം (Repeat)', border: OutlineInputBorder()),
              items: const [
                DropdownMenuItem(value: 'DAILY', child: Text('ദിവസവും (Daily)')),
                DropdownMenuItem(value: 'WEEKLY', child: Text('ആഴ്ചയിലൊരിക്കൽ (Weekly)')),
                DropdownMenuItem(value: 'NONE', child: Text('ഒരിക്കൽ മാത്രം (One-time)')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _recurrence = v);
              },
            ),
            const SizedBox(height: 32),

            SahaayiButton(
              label: _isLoading ? 'സേവ് ചെയ്യുന്നു...' : 'സേവ് ചെയ്യുക (Save Reminder)',
              icon: Icons.check,
              onPressed: _isLoading ? null : _saveReminder,
            ),
          ],
        ),
      ),
    );
  }
}
