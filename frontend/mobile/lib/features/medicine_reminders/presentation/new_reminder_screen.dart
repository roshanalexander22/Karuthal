import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/sahaayi_button.dart';
import '../../../shared/widgets/sahaayi_text_field.dart';

class NewReminderScreen extends StatefulWidget {
  const NewReminderScreen({super.key});

  @override
  State<NewReminderScreen> createState() => _NewReminderScreenState();
}

class _NewReminderScreenState extends State<NewReminderScreen> {
  final _titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('പുതിയ ഓർമ്മപ്പെടുത്തൽ')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SahaayiTextField(controller: _titleController, label: 'മരുന്നിന്റെ പേര് (Medicine Name)'),
            const SizedBox(height: 32),
            SahaayiButton(
              label: 'സേവ് ചെയ്യുക (Save Reminder)',
              onPressed: () => context.pop(),
            )
          ],
        ),
      ),
    );
  }
}
