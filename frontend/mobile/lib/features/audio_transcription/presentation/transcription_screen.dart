import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/tts_service.dart';
import '../models/transcription_model.dart';
import '../providers/transcription_provider.dart';

class TranscriptionScreen extends ConsumerStatefulWidget {
  const TranscriptionScreen({super.key});

  @override
  ConsumerState<TranscriptionScreen> createState() => _TranscriptionScreenState();
}

class _TranscriptionScreenState extends ConsumerState<TranscriptionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['wav', 'mp3', 'm4a', 'aac', 'ogg'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      final file = result.files.single;
      ref
          .read(transcriptionNotifierProvider.notifier)
          .uploadAudioFile(file.bytes!, file.name);
    }
  }

  void _readSummaryAloud(String summaryText) {
    ref.read(ttsServiceProvider).playBase64Audio(summaryText);
  }

  Widget _buildSegmentCard(TranscriptionSegmentModel segment) {
    final isDoctor = segment.speaker.contains('ഡോക്ടർ') || segment.speaker.contains('Doctor');
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isDoctor ? Icons.medical_services : Icons.person,
                  size: 22,
                  color: isDoctor ? Colors.blue[800] : const Color(0xFF1B5E20),
                ),
                const SizedBox(width: 8),
                Text(
                  segment.speaker,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isDoctor ? Colors.blue[900] : const Color(0xFF1B5E20),
                  ),
                ),
                const Spacer(),
                Text(
                  '${segment.startTime.toStringAsFixed(1)}s - ${segment.endTime.toStringAsFixed(1)}s',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              segment.text,
              style: const TextStyle(fontSize: 18, color: Color(0xFF1E293B), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transcriptionNotifierProvider);
    final transcript = state.currentTranscript;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ശബ്ദ ട്രാൻസ്ക്രിപ്ഷൻ (Audio)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.file_upload_outlined, size: 28),
            tooltip: 'ഓഡിയോ ഫയൽ അപ്‌ലോഡ് ചെയ്യുക',
            onPressed: _pickAudioFile,
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: 'സംഭാഷണം (Transcript)'),
            Tab(text: 'പ്രധാന വിവരങ്ങൾ (Summary)'),
          ],
        ),
      ),
      body: state.isProcessing
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text(
                    'ശബ്ദം തിരിച്ചറിഞ്ഞ് എഴുതുന്നു...\n(Transcribing Malayalam speech)',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : transcript == null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.mic_none_outlined, size: 72, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        const Text(
                          'ഡോക്ടറുമായുള്ള സംഭാഷണങ്ങൾ അല്ലെങ്കിൽ വോയ്സ് നോട്ടുകൾ റെക്കോർഡ് ചെയ്യുക.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 19),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1B5E20),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(200, 52),
                          ),
                          icon: const Icon(Icons.mic, size: 26),
                          label: const Text('റെക്കോർഡ് ആരംഭിക്കുക', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                          onPressed: () => ref.read(transcriptionNotifierProvider.notifier).toggleRecording(),
                        ),
                      ],
                    ),
                  ),
                )
              : TabBarView(
                  controller: _tabController,
                  children: [
                    // 1. Segments list
                    ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: transcript.segments.length,
                      itemBuilder: (context, i) => _buildSegmentCard(transcript.segments[i]),
                    ),

                    // 2. Summary Tab
                    SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Card(
                        elevation: 3,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.summarize, size: 28, color: Color(0xFF1B5E20)),
                                  const SizedBox(width: 10),
                                  const Text(
                                    'ഡോക്ടറുടെ നിർദ്ദേശങ്ങൾ',
                                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                                  ),
                                  const Spacer(),
                                  IconButton.filledTonal(
                                    style: IconButton.styleFrom(backgroundColor: Colors.green[50]),
                                    icon: const Icon(Icons.volume_up, color: Color(0xFF1B5E20)),
                                    tooltip: 'വായിച്ചു കേൾക്കുക',
                                    onPressed: () => _readSummaryAloud(transcript.summary ?? transcript.fullText),
                                  ),
                                ],
                              ),
                              const Divider(height: 24),
                              Text(
                                transcript.summary ?? transcript.fullText,
                                style: const TextStyle(fontSize: 19, height: 1.5, color: Color(0xFF1E293B)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: state.isRecording ? Colors.red : const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            icon: Icon(state.isRecording ? Icons.stop : Icons.mic, size: 28),
            label: Text(
              state.isRecording ? 'റെക്കോർഡിംഗ് നിർത്തുക (Stop)' : 'പുതിയ സംഭാഷണം റെക്കോർഡ് ചെയ്യുക',
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
            ),
            onPressed: () => ref.read(transcriptionNotifierProvider.notifier).toggleRecording(),
          ),
        ),
      ),
    );
  }
}
