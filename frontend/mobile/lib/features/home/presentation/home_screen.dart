import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final modules = [
      {'title': 'ശബ്ദ സഹായി\n(Voice Assistant)', 'icon': Icons.mic, 'route': '/voice', 'color': Colors.blue},
      {'title': 'രേഖ വായനക്കാരൻ\n(Document Reader)', 'icon': Icons.document_scanner, 'route': '/documents', 'color': Colors.teal},
      {'title': 'മരുന്ന് ഓർമ്മകൾ\n(Medicine Reminders)', 'icon': Icons.alarm, 'route': '/reminders', 'color': Colors.purple},
      {'title': 'സ്മാർട്ട് ഫോം\n(Smart Autofill)', 'icon': Icons.edit_document, 'route': '/autofill', 'color': Colors.indigo},
      {'title': 'ട്രാൻസ്ക്രിപ്ഷൻ\n(Audio Transcribe)', 'icon': Icons.record_voice_over, 'route': '/transcription', 'color': Colors.brown},
      {'title': 'വീഴ്ച കണ്ടെത്തൽ\n(Fall Detection)', 'icon': Icons.personal_injury, 'route': '/fall-detection', 'color': Colors.orange},
      {'title': 'വ്യക്തിഗത വിവരങ്ങൾ\n(Memory Profile)', 'icon': Icons.badge, 'route': '/profile', 'color': Colors.green},
      {'title': 'അടിയന്തിര സഹായം\n(Emergency SOS)', 'icon': Icons.warning_amber, 'route': '/emergency', 'color': Colors.red},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('സഹായി (Sahaayi)'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, size: 28),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.95,
          ),
          itemCount: modules.length,
          itemBuilder: (context, index) {
            final mod = modules[index];
            return Card(
              color: (mod['color'] as Color).withValues(alpha: 0.12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: mod['color'] as Color, width: 2),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => context.push(mod['route'] as String),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(mod['icon'] as IconData, size: 48, color: mod['color'] as Color),
                      const SizedBox(height: 12),
                      Text(
                        mod['title'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
