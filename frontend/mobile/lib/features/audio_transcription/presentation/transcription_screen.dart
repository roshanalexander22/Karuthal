import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/accessible_card.dart';

class TranscriptionScreen extends StatefulWidget {
  const TranscriptionScreen({super.key});

  @override
  State<TranscriptionScreen> createState() => _TranscriptionScreenState();
}

class _TranscriptionScreenState extends State<TranscriptionScreen> {
  bool _isRecording = false;
  final String _transcript =
      'ഡോക്ടർ പറഞ്ഞത്: ദിവസവും രാവിലെ ഭക്ഷണത്തിന് ശേഷം ഒരു പ്രഷറിന്റെ ഗുളിക കഴിക്കണം. ഉച്ചയ്ക്ക് ആഹാരം കഴിഞ്ഞ ഉടൻ വിശ്രമിക്കുക.';

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('ശബ്ദം റെക്കോർഡ് ചെയ്യുന്നു... സംസാരിക്കുക.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SahaayiColors.background,
      appBar: AppBar(
        title: const Text('ശബ്ദം എഴുത്താക്കുക (Transcription)'),
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
              backgroundColor: SahaayiColors.accent,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: const [
                  Icon(Icons.mic_external_on_rounded,
                      color: Color(0xFF2563EB), size: 30),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'ഡോക്ടറുടെ നിർദ്ദേശങ്ങളോ ശബ്ദ സന്ദേശങ്ങളോ റെക്കോർഡ് ചെയ്ത് മലയാളം ടെക്സ്റ്റായി കാണാം.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E40AF),
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Transcript Box
            const Text(
              'എഴുതി മാറ്റിയ വിവരങ്ങൾ (Transcript)',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: SahaayiColors.textMain,
              ),
            ),
            const SizedBox(height: 12),

            AccessibleCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: SahaayiColors.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'മലയാളം AI ട്രാൻസ്ക്രിപ്റ്റ്',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: SahaayiColors.primaryDark,
                          ),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.copy_rounded,
                            size: 20, color: SahaayiColors.textSecondary),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('വാചകം കോപ്പി ചെയ്തു!')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _transcript,
                    style: const TextStyle(
                      fontSize: 17,
                      color: SahaayiColors.textMain,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Record Button
            Center(
              child: GestureDetector(
                onTap: _toggleRecording,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: _isRecording
                        ? const Color(0xFFEF4444)
                        : SahaayiColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording
                                ? const Color(0xFFEF4444)
                                : SahaayiColors.primary)
                            .withValues(alpha: 0.35),
                        blurRadius: 18,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
                    color: Colors.white,
                    size: 44,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Text(
              _isRecording
                  ? 'റെക്കോർഡ് ചെയ്യുന്നു... നിർത്താൻ ടാപ്പ് ചെയ്യുക'
                  : 'റെക്കോർഡ് ആരംഭിക്കാൻ മൈക് അമർത്തുക',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _isRecording
                    ? const Color(0xFFDC2626)
                    : SahaayiColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
