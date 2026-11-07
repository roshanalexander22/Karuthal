import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/transcription_provider.dart';

class TranscriptionScreen extends ConsumerWidget {
  const TranscriptionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(transcriptionNotifierProvider);
    final notifier = ref.read(transcriptionNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('ശബ്ദ കുറിപ്പുകൾ (Audio Transcription)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: state.isRecording
                    ? Colors.red.withValues(alpha: 0.1)
                    : Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    state.isRecording ? Icons.mic : (state.isLoading ? Icons.hourglass_top : Icons.record_voice_over),
                    color: state.isRecording ? Colors.red : Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    state.statusText,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: state.isRecording ? Colors.red.shade900 : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Big Record Button
            Center(
              child: GestureDetector(
                onTap: state.isLoading ? null : () => notifier.toggleRecording(),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (state.isRecording ? Colors.red : Colors.teal).withValues(alpha: 0.3),
                        blurRadius: state.isRecording ? 24 : 12,
                        spreadRadius: state.isRecording ? 6 : 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: state.isRecording
                        ? Colors.red
                        : (state.isLoading ? Colors.orange : Colors.teal),
                    child: Icon(
                      state.isRecording ? Icons.stop : (state.isLoading ? Icons.hourglass_empty : Icons.mic),
                      size: 44,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                state.isRecording
                    ? 'റെക്കോർഡിംഗ് നിർത്താൻ ഇവിടെ അമർത്തുക'
                    : 'ശബ്ദം റെക്കോർഡ് ചെയ്യാൻ അമർത്തുക',
                style: const TextStyle(fontSize: 15, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 24),

            // Current Transcript Result
            if (state.activeResult != null) ...[
              Card(
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.teal),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.text_snippet, color: Colors.teal),
                          SizedBox(width: 8),
                          Text('പൂർണ്ണ രൂപം (Transcript):', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        state.activeResult!.fullText,
                        style: const TextStyle(fontSize: 18, height: 1.4),
                      ),
                      if (state.activeResult!.summary != null) ...[
                        const Divider(height: 24),
                        const Row(
                          children: [
                            Icon(Icons.auto_awesome, color: Colors.amber),
                            SizedBox(width: 8),
                            Text('സംഗ്രഹം (Summary):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          state.activeResult!.summary!,
                          style: const TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ],
                      if (state.activeResult!.actionItems.isNotEmpty) ...[
                        const Divider(height: 24),
                        const Row(
                          children: [
                            Icon(Icons.checklist, color: Colors.deepOrange),
                            SizedBox(width: 8),
                            Text('ചെയ്യേണ്ട കാര്യങ്ങൾ (Action Items):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ...state.activeResult!.actionItems.map(
                          (act) => Padding(
                            padding: const EdgeInsets.only(bottom: 6.0),
                            child: Row(
                              children: [
                                const Icon(Icons.check_circle_outline, size: 20, color: Colors.deepOrange),
                                const SizedBox(width: 8),
                                Expanded(child: Text(act, style: const TextStyle(fontSize: 16))),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // History
            if (state.history.isNotEmpty) ...[
              const Text(
                'മുൻകാല കുറിപ്പുകൾ (Past Recordings):',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...state.history.map(
                (item) => Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(Icons.audiotrack, color: Colors.teal, size: 32),
                    title: Text(
                      item.fullText,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    subtitle: item.summary != null ? Text(item.summary!, maxLines: 1, overflow: TextOverflow.ellipsis) : null,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
