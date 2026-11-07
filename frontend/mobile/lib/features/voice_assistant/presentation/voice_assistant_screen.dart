import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/accessible_card.dart';
import '../providers/voice_provider.dart';

class VoiceAssistantScreen extends ConsumerWidget {
  const VoiceAssistantScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(voiceProvider);
    final notifier = ref.read(voiceProvider.notifier);

    final suggestedPrompts = [
      'ഇന്നത്തെ മരുന്നുകൾ ഏതൊക്കെയാണ്?',
      'എന്റെ രേഖകൾ വായിക്കുക',
      'പെൻഷൻ ഫോം പൂരിപ്പിക്കാൻ സഹായിക്കാമോ?',
      'അടിയന്തിര നമ്പറുകൾ കാണിക്കുക',
    ];

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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                    horizontal: 24.0, vertical: 16.0),
                child: Column(
                  children: [
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
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
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: state.isListening
                                  ? SahaayiColors.emergency
                                  : SahaayiColors.primaryDark,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Recognized Text Box
                    AccessibleCard(
                      backgroundColor: Colors.white,
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.record_voice_over_rounded,
                                color: state.isListening
                                    ? SahaayiColors.primary
                                    : SahaayiColors.textSecondary,
                                size: 24,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'ശബ്ദ സംഭാഷണം (Transcript)',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: SahaayiColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 24),
                          Text(
                            state.recognizedText.isEmpty
                                ? 'നിങ്ങൾ സംസാരിക്കുന്ന വാക്കുകൾ ഇവിടെ മലയാളത്തിൽ കാണാം...'
                                : state.recognizedText,
                            style: TextStyle(
                              fontSize: 20,
                              height: 1.4,
                              fontWeight: state.recognizedText.isEmpty
                                  ? FontWeight.normal
                                  : FontWeight.w600,
                              color: state.recognizedText.isEmpty
                                  ? Colors.grey
                                  : SahaayiColors.textMain,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Suggested Questions
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'ചോദിക്കാവുന്ന ചോദ്യങ്ങൾ:',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: SahaayiColors.textMain),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: suggestedPrompts.map((prompt) {
                        return ActionChip(
                          avatar: const Icon(Icons.chat_bubble_outline_rounded,
                              size: 16, color: SahaayiColors.primaryDark),
                          label: Text(
                            prompt,
                            style: const TextStyle(
                                fontSize: 14,
                                color: SahaayiColors.textMain,
                                fontWeight: FontWeight.w500),
                          ),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: const BorderSide(color: SahaayiColors.border),
                          ),
                          onPressed: () {
                            notifier.toggleListening();
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),

            // Large Central Microphone Interaction Area (>= 56dp guideline, 100dp touch target)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                      color: Color(0x0C000000),
                      blurRadius: 10,
                      offset: Offset(0, -4)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Semantics(
                    button: true,
                    label: state.isListening
                        ? 'സംസാരം നിർത്തുക'
                        : 'സംസാരിക്കാൻ ആരംഭിക്കുക',
                    child: GestureDetector(
                      onTap: () => notifier.toggleListening(),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 96,
                        height: 96,
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
                              blurRadius: 16,
                              spreadRadius: state.isListening ? 4 : 0,
                            ),
                          ],
                        ),
                        child: Icon(
                          state.isListening
                              ? Icons.stop_rounded
                              : Icons.mic_rounded,
                          size: 46,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    state.isListening
                        ? 'നിർത്താൻ അമർത്തുക'
                        : 'സംസാരിക്കാൻ അമർത്തുക (Tap to Speak)',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: SahaayiColors.textMain),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
