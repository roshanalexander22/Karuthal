import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/accessible_card.dart';
import '../../../shared/widgets/sahaayi_button.dart';
import '../services/tts_service.dart';

class TextToSpeechScreen extends StatefulWidget {
  const TextToSpeechScreen({super.key});

  @override
  State<TextToSpeechScreen> createState() => _TextToSpeechScreenState();
}

class _TextToSpeechScreenState extends State<TextToSpeechScreen> {
  final _tts = TTSService();
  final _controller = TextEditingController(
    text:
        'നമസ്കാരം, സഹായി സ്ക്രീൻ വായന സംവിധാനത്തിലേക്ക് സ്വാഗതം. ഏത് മലയാളം വാചകവും ഇവിടെ വ്യക്തമായി വായിച്ചു കേൾക്കാം.',
  );
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _tts.init();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSpeak() {
    setState(() => _isPlaying = true);
    _tts.speak(_controller.text);
  }

  void _handleStop() {
    setState(() => _isPlaying = false);
    _tts.stop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SahaayiColors.background,
      appBar: AppBar(
        title: const Text('സ്ക്രീൻ വായന (Malayalam TTS)'),
        backgroundColor: SahaayiColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: SahaayiColors.textMain),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AccessibleCard(
              backgroundColor: SahaayiColors.secondary,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: const [
                  Icon(Icons.record_voice_over_rounded,
                      color: SahaayiColors.primaryDark, size: 30),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'വാചകം ടൈപ്പ് ചെയ്യുകയോ പേസ്റ്റ് ചെയ്യുകയോ ചെയ്ത ശേഷം "വായിക്കുക" അമർത്തുക.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: SahaayiColors.primaryDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Text Input Box
            AccessibleCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'വായിക്കേണ്ട വാചകം (Text to read):',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: SahaayiColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _controller,
                    maxLines: 6,
                    style: const TextStyle(
                      fontSize: 18,
                      color: SahaayiColors.textMain,
                      height: 1.5,
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: SahaayiColors.background,
                      hintText: 'മലയാളം വാചകം ഇവിടെ എഴുതുക...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: SahaayiColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide:
                            const BorderSide(color: SahaayiColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: const BorderSide(
                            color: SahaayiColors.primary, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Play / Stop Controls
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: SahaayiButton(
                    label: _isPlaying
                        ? 'വായിക്കുന്നു...'
                        : 'വായിക്കുക (Read Aloud)',
                    icon: Icons.play_arrow_rounded,
                    backgroundColor: SahaayiColors.primary,
                    onPressed: _handleSpeak,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SahaayiButton(
                    label: 'നിർത്തുക',
                    icon: Icons.stop_rounded,
                    backgroundColor: const Color(0xFFFEE2E2),
                    textColor: const Color(0xFFDC2626),
                    onPressed: _handleStop,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
