import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/fall_detection_provider.dart';

class FallDetectionScreen extends ConsumerWidget {
  const FallDetectionScreen({super.key});

  Widget _buildCountdownAlert(BuildContext context, WidgetRef ref, int seconds) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.red[700]!, width: 2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.warning_amber_rounded, size: 36, color: Colors.red),
              const SizedBox(width: 10),
              Text(
                'വീഴ്ച കണ്ടെത്തി! (Fall Alert)',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red[900]),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CircleAvatar(
            radius: 46,
            backgroundColor: Colors.red[700],
            child: Text(
              '$seconds',
              style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            '30 സെക്കൻഡിനുള്ളിൽ റദ്ദാക്കിയില്ലെങ്കിൽ പരിചാരകർക്ക് ഉടൻ അടിയന്തര സഹായ സന്ദേശം എത്തും.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 17, height: 1.4, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B5E20),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              icon: const Icon(Icons.check_circle, size: 28),
              label: const Text(
                'ഞാൻ സുരക്ഷിതനാണ് / റദ്ദാക്കുക',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              onPressed: () =>
                  ref.read(fallDetectionProvider.notifier).cancelCountdownAndMarkSafe(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fallDetectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('വീഴ്ച കണ്ടെത്തൽ (Fall Alert)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Active Countdown State
            if (state.countdownActive) ...[
              _buildCountdownAlert(context, ref, state.remainingSeconds),
              const SizedBox(height: 24),
            ],

            // SOS Dispatched notification
            if (state.sosDispatched) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 28),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'അടിയന്തര സഹായ സന്ദേശം പരിചാരകർക്ക് വിജയകരമായി അയച്ചു.',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Disclaimer Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[800]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.amber[900], size: 28),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'മുന്നറിയിപ്പ്: ഇത് ഒരു പരീക്ഷണ സുരക്ഷാ സംവിധാനം മാത്രമാണ്. ആശുപത്രി/മെഡിക്കൽ അടിയന്തിര സേവനങ്ങൾക്ക് പകരമല്ല.',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Monitoring Toggle
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: SwitchListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                title: const Text(
                  'സെൻസർ നിരീക്ഷണം (Sensor Monitoring)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  state.isMonitoring ? 'സെൻസറുകൾ പ്രവർത്തിക്കുന്നുണ്ട്' : 'നിരീക്ഷണം നിർത്തിവെച്ചിരിക്കുന്നു',
                  style: TextStyle(fontSize: 15, color: state.isMonitoring ? Colors.green[800] : Colors.grey),
                ),
                value: state.isMonitoring,
                activeTrackColor: const Color(0xFF1B5E20),
                onChanged: (_) => ref.read(fallDetectionProvider.notifier).toggle(),
              ),
            ),
            const SizedBox(height: 20),

            // Sensitivity Selector
            const Text(
              'സെൻസിറ്റിവിറ്റി നിലവാരം (Sensitivity)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Text('കുറഞ്ഞത്\n(Low)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                    selected: state.sensitivity == 'LOW',
                    onSelected: (_) => ref.read(fallDetectionProvider.notifier).setSensitivity('LOW'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('സാധാരണ\n(Medium)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                    selected: state.sensitivity == 'MEDIUM',
                    onSelected: (_) => ref.read(fallDetectionProvider.notifier).setSensitivity('MEDIUM'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    label: const Text('ഉയർന്നത്\n(High)', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold)),
                    selected: state.sensitivity == 'HIGH',
                    onSelected: (_) => ref.read(fallDetectionProvider.notifier).setSensitivity('HIGH'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),

            // Test Simulation Trigger Button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.bug_report, color: Colors.red),
                label: const Text(
                  'ടെസ്റ്റ് വീഴ്ച അലർട്ട് (Test Fall Alert)',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.red),
                ),
                onPressed: () {
                  ref.read(fallDetectionProvider.notifier).onFallDetected();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
