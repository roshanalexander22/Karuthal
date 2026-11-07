import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../models/voice_message.dart';
import '../providers/voice_provider.dart';

class VoiceAssistantScreen extends ConsumerStatefulWidget {
  const VoiceAssistantScreen({super.key});

  @override
  ConsumerState<VoiceAssistantScreen> createState() =>
      _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends ConsumerState<VoiceAssistantScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<String> _suggestedPrompts = [
    'ഇന്നത്തെ മരുന്നുകൾ ഏതൊക്കെയാണ്?',
    'എന്റെ രേഖകൾ വായിക്കുക',
    'പെൻഷൻ ഫോം പൂരിപ്പിക്കാൻ സഹായിക്കാമോ?',
    'അടിയന്തിര നമ്പറുകൾ കാണിക്കുക',
  ];

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend([String? text]) {
    final query = text ?? _textController.text;
    if (query.trim().isEmpty) return;

    ref.read(voiceProvider.notifier).sendQuery(query.trim());
    _textController.clear();
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(voiceProvider);
    final notifier = ref.read(voiceProvider.notifier);

    // Auto scroll when new messages arrive
    ref.listen<VoiceState>(voiceProvider, (prev, next) {
      if (prev?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: SahaayiColors.background,
      appBar: AppBar(
        title: const Text('ശബ്ദ സഹായി (Voice Assistant)'),
        backgroundColor: SahaayiColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: SahaayiColors.textMain),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Status & Active Listening Strip
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: state.isListening
                      ? SahaayiColors.rose
                      : SahaayiColors.secondary,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: state.isListening
                        ? SahaayiColors.emergency
                        : SahaayiColors.primary,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: state.isListening
                            ? SahaayiColors.emergency
                            : SahaayiColors.primaryDark,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      state.statusText,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: state.isListening
                            ? SahaayiColors.emergency
                            : SahaayiColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Suggested prompt chips
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _suggestedPrompts.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final prompt = _suggestedPrompts[index];
                  return ActionChip(
                    avatar: const Icon(Icons.chat_bubble_outline_rounded,
                        size: 15, color: SahaayiColors.primaryDark),
                    label: Text(
                      prompt,
                      style: const TextStyle(
                        fontSize: 13,
                        color: SahaayiColors.textMain,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: SahaayiColors.border),
                    ),
                    onPressed: () => _handleSend(prompt),
                  );
                },
              ),
            ),

            const SizedBox(height: 8),

            // Messages Conversation History
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: state.messages.length + (state.isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == state.messages.length && state.isLoading) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: SahaayiColors.border),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: SahaayiColors.primary,
                              ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'സഹായി ആലോചിക്കുന്നു...',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: SahaayiColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final msg = state.messages[index];
                  return _buildMessageItem(context, msg, notifier);
                },
              ),
            ),

            // Bottom Input & Mic Controls Area
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      // Text input field
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: SahaayiColors.background,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: SahaayiColors.border),
                          ),
                          child: TextField(
                            controller: _textController,
                            style: const TextStyle(
                                fontSize: 16, color: SahaayiColors.textMain),
                            decoration: InputDecoration(
                              hintText: 'മലയാളത്തിൽ ചോദിക്കുക...',
                              hintStyle: TextStyle(
                                  color: SahaayiColors.textSecondary
                                      .withAlpha(160)),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 12),
                              border: InputBorder.none,
                            ),
                            onSubmitted: (val) => _handleSend(val),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Send button
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: SahaayiColors.secondary,
                          minimumSize: const Size(48, 48),
                        ),
                        icon: const Icon(Icons.send_rounded,
                            color: SahaayiColors.primaryDark),
                        onPressed: () => _handleSend(),
                      ),
                      const SizedBox(width: 8),

                      // Microphone Toggle Button
                      Semantics(
                        button: true,
                        label: state.isListening
                            ? 'സംസാരം നിർത്തുക'
                            : 'സംസാരിക്കാൻ ആരംഭിക്കുക',
                        child: GestureDetector(
                          onTap: () => notifier.toggleListening(),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: state.isListening
                                  ? SahaayiColors.emergency
                                  : SahaayiColors.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: (state.isListening
                                          ? SahaayiColors.emergency
                                          : SahaayiColors.primary)
                                      .withAlpha(100),
                                  blurRadius: 10,
                                  spreadRadius: state.isListening ? 3 : 0,
                                ),
                              ],
                            ),
                            child: Icon(
                              state.isListening
                                  ? Icons.stop_rounded
                                  : Icons.mic_rounded,
                              size: 28,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageItem(
      BuildContext context, VoiceMessage msg, VoiceNotifier notifier) {
    if (msg.isUser) {
      return Align(
        alignment: Alignment.centerRight,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 6),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.78,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: SahaayiColors.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            msg.text,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
              height: 1.35,
            ),
          ),
        ),
      );
    }

    // Assistant reply
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.84,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(color: SahaayiColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: SahaayiColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.handshake_outlined,
                    size: 16,
                    color: SahaayiColors.primaryDark,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'സഹായി',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: SahaayiColors.primaryDark,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.volume_up_rounded,
                      size: 20, color: SahaayiColors.primary),
                  tooltip: 'വായിച്ചു കേൾക്കുക',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => notifier.speakMessage(msg),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              msg.text,
              style: const TextStyle(
                fontSize: 16,
                color: SahaayiColors.textMain,
                height: 1.4,
              ),
            ),
            if (msg.targetRoute != null && msg.targetRoute!.isNotEmpty) ...[
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: SahaayiColors.secondary,
                  foregroundColor: SahaayiColors.primaryDark,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                ),
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text(
                  'തുറക്കുക (Open)',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: () => context.push(msg.targetRoute!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
