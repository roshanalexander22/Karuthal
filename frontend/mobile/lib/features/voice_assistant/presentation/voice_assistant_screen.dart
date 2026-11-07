import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/voice_message.dart';
import '../providers/voice_provider.dart';

class VoiceAssistantScreen extends ConsumerStatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  ConsumerState<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends ConsumerState<VoiceAssistantScreen> {
  final TextEditingController _textCtrl = TextEditingController();

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  void _handleSuggestionTap(String prompt) {
    ref.read(voiceProvider.notifier).sendQuery(prompt);
  }

  Widget _buildMessageBubble(VoiceMessage msg) {
    final isUser = msg.isUser;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF1B5E20) : const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(16),
          ),
          border: isUser ? null : Border.all(color: const Color(0xFFCBD5E1), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              msg.text,
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w600,
                color: isUser ? Colors.white : const Color(0xFF1E293B),
                height: 1.4,
              ),
            ),
            if (!isUser) ...[
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton.filledTonal(
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.green[100],
                      minimumSize: const Size(48, 48),
                    ),
                    icon: const Icon(Icons.volume_up, color: Color(0xFF1B5E20)),
                    tooltip: 'കേൾക്കൂ (Listen)',
                    onPressed: () => ref.read(voiceProvider.notifier).speakMessage(msg),
                  ),
                  if (msg.targetRoute != null)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1B5E20),
                        foregroundColor: Colors.white,
                        minimumSize: const Size(120, 44),
                      ),
                      icon: const Icon(Icons.arrow_forward, size: 18),
                      label: const Text('തുറക്കുക', style: TextStyle(fontWeight: FontWeight.bold)),
                      onPressed: () => context.push(msg.targetRoute!),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(voiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ശബ്ദ സഹായി (Voice)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        actions: [
          if (state.isSpeaking)
            IconButton(
              icon: const Icon(Icons.stop_circle, color: Colors.red, size: 30),
              tooltip: 'ശബ്ദം നിർത്തുക (Stop Speaking)',
              onPressed: () => ref.read(voiceProvider.notifier).stopSpeaking(),
            ),
        ],
      ),
      body: Column(
        children: [
          // Suggestions header
          Container(
            height: 52,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                ActionChip(
                  avatar: const Text('💊', style: TextStyle(fontSize: 16)),
                  label: const Text('ഗുളിക ഓർമ്മിപ്പിക്കൂ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  onPressed: () => _handleSuggestionTap('രാവിലെ 8 മണിക്ക് ബിപി ഗുളിക ഓർമ്മിപ്പിക്കുക'),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  avatar: const Text('📄', style: TextStyle(fontSize: 16)),
                  label: const Text('രേഖ വായിക്കൂ', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  onPressed: () => _handleSuggestionTap('ഡോക്യുമെന്റ് വായിച്ചു കേൾപ്പിക്കൂ'),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  avatar: const Text('🚨', style: TextStyle(fontSize: 16)),
                  label: const Text('സഹായിക്കൂ (SOS)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.red)),
                  backgroundColor: Colors.red[50],
                  onPressed: () => _handleSuggestionTap('എന്നെ സഹായിക്കൂ ഞാൻ താഴെ വീണു'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Messages list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.messages.length,
              itemBuilder: (context, i) => _buildMessageBubble(state.messages[i]),
            ),
          ),

          // Status & Speaking indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: state.isListening ? Colors.red[50] : Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (state.isLoading) ...[
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: 10),
                ],
                Text(
                  state.statusText,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: state.isListening ? Colors.red[900] : Colors.blueGrey[800],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Voice Controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textCtrl,
                    style: const TextStyle(fontSize: 18),
                    decoration: InputDecoration(
                      hintText: 'ഇവിടെ ടൈപ്പ് ചെയ്യാം അല്ലെങ്കിൽ സംസാരിക്കാം...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    onSubmitted: (val) {
                      if (val.trim().isNotEmpty) {
                        ref.read(voiceProvider.notifier).sendQuery(val.trim());
                        _textCtrl.clear();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                // Big Mic Button (Minimum 64x64 dp for accessibility)
                GestureDetector(
                  onTap: () => ref.read(voiceProvider.notifier).toggleListening(),
                  child: CircleAvatar(
                    radius: 32,
                    backgroundColor: state.isListening ? Colors.red : const Color(0xFF1B5E20),
                    child: Icon(
                      state.isListening ? Icons.stop : Icons.mic,
                      size: 34,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
