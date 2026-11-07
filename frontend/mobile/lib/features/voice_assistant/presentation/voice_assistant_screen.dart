import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/voice_provider.dart';

class VoiceAssistantScreen extends ConsumerWidget {
  const VoiceAssistantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(voiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ശബ്ദ സഹായി (Voice)')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(state.statusText, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              if (state.recognizedText.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.grey.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                  child: Text(state.recognizedText, style: const TextStyle(fontSize: 20)),
                ),
              const SizedBox(height: 48),
              GestureDetector(
                onTap: () => ref.read(voiceProvider.notifier).toggleListening(),
                child: CircleAvatar(
                  radius: 56,
                  backgroundColor: state.isListening ? Colors.red : Theme.of(context).colorScheme.primary,
                  child: Icon(state.isListening ? Icons.stop : Icons.mic, size: 48, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
