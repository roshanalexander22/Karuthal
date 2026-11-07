import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/accessible_card.dart';
import '../../../shared/widgets/sahaayi_button.dart';
import '../providers/fall_detection_provider.dart';

class FallDetectionScreen extends ConsumerWidget {
  const FallDetectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fallDetectionProvider);
    final notifier = ref.read(fallDetectionProvider.notifier);

    return Scaffold(
      backgroundColor: SahaayiColors.background,
      appBar: AppBar(
        title: const Text('വീഴ്ച കണ്ടെത്തൽ (Fall Alert)'),
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
            // Active Fall Countdown Banner
            if (state.countdownActive) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFDC2626), width: 2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x1CDC2626),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFDC2626), size: 48),
                    const SizedBox(height: 8),
                    const Text(
                      'വീഴ്ച കണ്ടെത്തി! (Fall Detected)',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF991B1B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${state.remainingSeconds} സെക്കൻഡുകൾക്കുള്ളിൽ പരിചാരകർക്ക് അടിയന്തിര സന്ദേശം പോകും.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7F1D1D),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: SahaayiColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text(
                              'ഞാൻ സുരക്ഷിതനാണ്',
                              style: TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            onPressed: () =>
                                notifier.cancelCountdownAndMarkSafe(),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFDC2626),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                          onPressed: () => context.push('/emergency'),
                          child: const Text(
                            'SOS Now',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            if (state.sosDispatched) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFDC2626)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emergency_share_rounded,
                        color: Color(0xFFDC2626), size: 30),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'അടിയന്തിര SOS അയച്ചു! GPS ലൊക്കേഷൻ പങ്കുവെച്ചു.',
                        style: TextStyle(
                            color: Color(0xFF991B1B),
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton(
                      onPressed: () => notifier.cancelCountdownAndMarkSafe(),
                      child: const Text('ക്ലിയർ ചെയ്യുക'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Safe Notice Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: Color(0xFFD97706), size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'മുന്നറിയിപ്പ്: ഇത് ഒരു പരീക്ഷണ സുരക്ഷാ സംവിധാനം മാത്രമാണ്. ഫോൺ സെൻസർ അടിസ്ഥാനമാക്കിയുള്ളതാണ്.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF92400E),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Sensor Status Card
            AccessibleCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: state.isMonitoring
                                  ? SahaayiColors.secondary
                                  : SahaayiColors.border.withValues(alpha: 0.4),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.sensors_rounded,
                              color: state.isMonitoring
                                  ? SahaayiColors.primaryDark
                                  : SahaayiColors.textSecondary,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'സെൻസർ നിരീക്ഷണം',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                  color: SahaayiColors.textMain,
                                ),
                              ),
                              Text(
                                state.isMonitoring
                                    ? 'സജീവമാണ് (Active)'
                                    : 'നിർത്തലാക്കി (Paused)',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: state.isMonitoring
                                      ? SahaayiColors.primaryDark
                                      : SahaayiColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Switch(
                        activeThumbColor: SahaayiColors.primary,
                        value: state.isMonitoring,
                        onChanged: (_) => notifier.toggle(),
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMetric(
                        title: 'ത്വരണമാനം (Accel)',
                        value: state.isMonitoring ? '1.02 g' : '--',
                        status: 'സാധാരണ',
                      ),
                      _buildMetric(
                        title: 'സൂചന (Status)',
                        value: state.isMonitoring ? 'സുരക്ഷിതം' : 'ഓഫ്',
                        status: 'നിരീക്ഷിക്കുന്നു',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Sensitivity Settings Card
            AccessibleCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'സെൻസിറ്റിവിറ്റി നില (Sensitivity):',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: SahaayiColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildSensitivityChip(
                          'കുറഞ്ഞത് (Low)', 'LOW', state.sensitivity, notifier),
                      const SizedBox(width: 8),
                      _buildSensitivityChip('സാധാരണ (Medium)', 'MEDIUM',
                          state.sensitivity, notifier),
                      const SizedBox(width: 8),
                      _buildSensitivityChip('കൂടിയത് (High)', 'HIGH',
                          state.sensitivity, notifier),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Simulate Fall Test Button
            SahaayiButton(
              label: 'വീഴ്ച കണ്ടെത്തൽ പരീക്ഷിക്കുക (Test Fall Alert)',
              icon: Icons.play_circle_outline_rounded,
              backgroundColor: SahaayiColors.secondary,
              textColor: SahaayiColors.primaryDark,
              onPressed: () {
                notifier.onFallDetected();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'പരീക്ഷണ വീഴ്ച തിരിച്ചറിഞ്ഞു! 30 സെക്കൻഡ് കൗണ്ട്ഡൗൺ ആരംഭിച്ചു.'),
                    backgroundColor: Color(0xFFDC2626),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // How it works card
            const Text(
              'ഇത് എങ്ങനെ പ്രവർത്തിക്കുന്നു? (How It Works)',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: SahaayiColors.textMain,
              ),
            ),
            const SizedBox(height: 12),

            const AccessibleCard(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.phone_android_rounded,
                    title: '1. ഫോൺ ചലനം നിരീക്ഷിക്കുന്നു',
                    subtitle:
                        'ഫോണിലെ ആക്സിലറോമീറ്റർ ഉപയോഗിച്ച് പെട്ടെന്നുള്ള വീഴ്ചകൾ തിരിച്ചറിയുന്നു.',
                  ),
                  Divider(height: 20),
                  _InfoRow(
                    icon: Icons.timer_outlined,
                    title: '2. 30 സെക്കൻഡ് കൗണ്ട്ഡൗൺ',
                    subtitle:
                        'വീഴ്ച തിരിച്ചറിഞ്ഞാൽ അലാറം മുഴങ്ങും. അബദ്ധമാണെങ്കിൽ റദ്ദാക്കാം.',
                  ),
                  Divider(height: 20),
                  _InfoRow(
                    icon: Icons.sms_outlined,
                    title: '3. പരിചാരകർക്ക് സന്ദേശം',
                    subtitle:
                        'മറുപടി ലഭിച്ചില്ലെങ്കിൽ GPS ലൊക്കേഷൻ അടക്കം SMS/അലേർട്ട് പോകും.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSensitivityChip(String label, String value,
      String currentSensitivity, FallNotifier notifier) {
    final isSelected = currentSensitivity == value;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: isSelected,
      selectedColor: SahaayiColors.primary,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : SahaayiColors.textMain,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (val) {
        if (val) notifier.setSensitivity(value);
      },
    );
  }

  Widget _buildMetric(
      {required String title, required String value, required String status}) {
    return Column(
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 13, color: SahaayiColors.textSecondary)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: SahaayiColors.textMain)),
        const SizedBox(height: 2),
        Text(status,
            style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: SahaayiColors.primaryDark)),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoRow(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: SahaayiColors.primary, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: SahaayiColors.textMain)),
              const SizedBox(height: 3),
              Text(subtitle,
                  style: const TextStyle(
                      fontSize: 13,
                      color: SahaayiColors.textSecondary,
                      height: 1.3)),
            ],
          ),
        ),
      ],
    );
  }
}
