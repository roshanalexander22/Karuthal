import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/accessible_card.dart';
import '../providers/fall_detection_provider.dart';

class FallDetectionScreen extends ConsumerWidget {
  const FallDetectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fallDetectionProvider);

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
            // Safe Notice Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF59E0B), width: 1.2),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Icon(Icons.info_outline_rounded,
                      color: Color(0xFFD97706), size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'മുന്നറിയിപ്പ്: ഇത് ഒരു പരീക്ഷണ സുരക്ഷാ സംവിധാനം മാത്രമാണ്. ആശുപത്രി/മെഡിക്കൽ അടിയന്തിര സേവനങ്ങൾക്ക് പകരമല്ല.',
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

            const SizedBox(height: 24),

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
                        onChanged: (_) =>
                            ref.read(fallDetectionProvider.notifier).toggle(),
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

            AccessibleCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: const [
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

  Widget _buildMetric(
      {required String title, required String value, required String status}) {
    return Column(
      children: [
        Text(title,
            style: TextStyle(fontSize: 13, color: SahaayiColors.textSecondary)),
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
                  style: TextStyle(
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
