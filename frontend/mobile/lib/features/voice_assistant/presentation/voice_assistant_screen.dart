import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/voice_provider.dart';

class VoiceAssistantScreen extends ConsumerWidget {
  const VoiceAssistantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(voiceProvider);
    final voiceNotifier = ref.read(voiceProvider.notifier);
    final ttsService = ref.read(ttsServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ശബ്ദ സഹായി (Voice Assistant)'),
        actions: [
          if (state.responseText.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.volume_up, size: 28),
              tooltip: 'വീണ്ടും കേൾക്കുക (Replay)',
              onPressed: () => ttsService.speak(state.responseText),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Header
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: state.isListening
                    ? Colors.red.withValues(alpha: 0.1)
                    : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    state.isListening
                        ? Icons.fiber_manual_record
                        : (state.isLoading ? Icons.hourglass_top : Icons.mic_none),
                    color: state.isListening ? Colors.red : Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      state.statusText,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: state.isListening ? Colors.red.shade900 : null,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // User speech recognized box
            if (state.recognizedText.isNotEmpty) ...[
              const Text(
                'നിങ്ങൾ പറഞ്ഞത് (You said):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: Text(
                  state.recognizedText,
                  style: const TextStyle(fontSize: 20, height: 1.4),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Assistant response box
            if (state.responseText.isNotEmpty) ...[
              const Text(
                'സഹായിയുടെ മറുപടി (Sahaayi Response):',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.teal),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.teal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.teal.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.responseText,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500, height: 1.4),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.volume_up),
                          label: const Text('വായിക്കുക (Speak)', style: TextStyle(fontSize: 16)),
                          onPressed: () => ttsService.speak(state.responseText),
                        ),
                        TextButton.icon(
                          icon: const Icon(Icons.stop),
                          label: const Text('നിർത്തുക (Stop)', style: TextStyle(fontSize: 16)),
                          onPressed: () => ttsService.stop(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Quick command chips
            const Text(
              'ഉദാഹരണങ്ങൾ (Quick Suggestions):',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  avatar: const Icon(Icons.alarm, size: 18),
                  label: const Text('വൈകിട്ട് 7 മണിക്ക് മരുന്ന്'),
                  onPressed: () => voiceNotifier.processVoiceInput(
                    directText: 'സഹായി, വൈകിട്ട് 7 മണിക്ക് പാരസെറ്റാമോൾ ഗുളിക കഴിക്കാൻ ഓർമ്മിപ്പിക്കണം.',
                  ),
                ),
                ActionChip(
                  avatar: const Icon(Icons.emergency, size: 18, color: Colors.red),
                  label: const Text('അടിയന്തര സഹായം വേണം'),
                  onPressed: () => voiceNotifier.processVoiceInput(
                    directText: 'സഹായി, എനിക്ക് അടിയന്തര സഹായം വേണം, രക്ഷിക്കൂ!',
                  ),
                ),
                ActionChip(
                  avatar: const Icon(Icons.document_scanner, size: 18),
                  label: const Text('ഡോക്യുമെന്റ് വായിക്കുക'),
                  onPressed: () => voiceNotifier.processVoiceInput(
                    directText: 'സഹായി, അവസാനമായി എടുത്ത രേഖയിലെ വിവരങ്ങൾ വായിച്ചു തരുമോ?',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),

            // Big Accessible Mic Button
            Center(
              child: GestureDetector(
                onTap: state.isLoading ? null : () => voiceNotifier.toggleListening(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (state.isListening ? Colors.red : Theme.of(context).colorScheme.primary)
                            .withValues(alpha: 0.35),
                        blurRadius: state.isListening ? 28 : 14,
                        spreadRadius: state.isListening ? 8 : 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 54,
                    backgroundColor: state.isListening
                        ? Colors.red
                        : (state.isLoading ? Colors.orange : Theme.of(context).colorScheme.primary),
                    child: Icon(
                      state.isListening
                          ? Icons.stop
                          : (state.isLoading ? Icons.hourglass_empty : Icons.mic),
                      size: 50,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                state.isListening
                    ? 'പറഞ്ഞു കഴിഞ്ഞാൽ നിർത്താൻ അമർത്തുക'
                    : 'സംസാരിക്കാൻ മൈക്രോഫോണിൽ തൊടുക',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
