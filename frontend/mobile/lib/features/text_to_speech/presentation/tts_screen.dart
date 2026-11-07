import 'package:flutter/material.dart';
import '../services/tts_service.dart';
import '../../../shared/widgets/sahaayi_button.dart';

class TextToSpeechScreen extends StatefulWidget {
  const TextToSpeechScreen({super.key});

  @override
  State<TextToSpeechScreen> createState() => _TextToSpeechScreenState();
}

class _TextToSpeechScreenState extends State<TextToSpeechScreen> {
  final _tts = TTSService();
  final _controller = TextEditingController(text: 'നമസ്കാരം, ഇത് വായിച്ചു കേൾപ്പിക്കാൻ സഹായിക്കുന്നതാണ്.');

  @override
  void initState() {
    super.initState();
    _tts.init();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('സ്ക്രീൻ വായന (TTS)')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              maxLines: 5,
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 24),
            SahaayiButton(
              label: 'വായിക്കുക (Read Aloud)',
              icon: Icons.volume_up,
              onPressed: () => _tts.speak(_controller.text),
            ),
            const SizedBox(height: 12),
            SahaayiButton(
              label: 'നിർത്തുക (Stop)',
              icon: Icons.stop,
              backgroundColor: Colors.red,
              onPressed: () => _tts.stop(),
            ),
          ],
        ),
      ),
    );
  }
}
