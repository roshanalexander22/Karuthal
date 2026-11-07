import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/fall_detection_provider.dart';
import '../../../shared/widgets/sahaayi_button.dart';

class FallDetectionScreen extends ConsumerWidget {
  const FallDetectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fallDetectionProvider);
    final notifier = ref.read(fallDetectionProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('വീഴ്ച കണ്ടെത്തൽ (Fall Detection)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Warning header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.6)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.health_and_safety, color: Colors.deepOrange, size: 36),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'മുന്നറിയിപ്പ്: ഇത് ഒരു സഹായ സംവിധാനം മാത്രമാണ്. ഗുരുതരമായ അടിയന്തിര ഘട്ടങ്ങളിൽ ആശുപത്രി സേവനങ്ങൾ ഉപയോഗിക്കുക.',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Active Alert Banner if triggered
            if (state.isFallAlertActive) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red, width: 2),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.warning, color: Colors.red, size: 56),
                    const SizedBox(height: 8),
                    const Text(
                      'വീഴ്ച സംഭവിച്ചതായി കണ്ടെത്തി!',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${state.countdownSeconds} സെക്കൻഡുകൾക്കുള്ളിൽ സന്ദേശം അയക്കും',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                            onPressed: () => notifier.cancelAlert(),
                            child: const Text('ഞാൻ സുരക്ഷിതനാണ്\n(I am OK / Cancel)', textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
                            onPressed: () => notifier.confirmAndDispatchSOS(),
                            child: const Text('സഹായം വേണം!\n(Confirm SOS)', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Monitoring Toggle Card
            Card(
              child: SwitchListTile(
                contentPadding: const EdgeInsets.all(16),
                title: const Text('സെൻസർ നിരീക്ഷണം (Sensor Monitoring)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text(state.statusText, style: const TextStyle(fontSize: 15)),
                value: state.isMonitoring,
                onChanged: (_) => notifier.toggleMonitoring(),
              ),
            ),
            const SizedBox(height: 20),

            // Sensitivity card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('സെൻസിറ്റിവിറ്റി (Detection Sensitivity):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 12),
                    SegmentedButton<String>(
                      segments: const [
                        ButtonSegment(value: 'LOW', label: Text('കുറഞ്ഞത് (Low)')),
                        ButtonSegment(value: 'MEDIUM', label: Text('സാധാരണം (Med)')),
                        ButtonSegment(value: 'HIGH', label: Text('കൂടിയത് (High)')),
                      ],
                      selected: const {'MEDIUM'},
                      onSelectionChanged: (_) {},
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Test Fall Trigger button
            SahaayiButton(
              label: 'വീഴ്ച മുന്നറിയിപ്പ് പരീക്ഷിക്കുക (Simulate Fall Test)',
              icon: Icons.notification_important,
              backgroundColor: Colors.deepOrange,
              onPressed: () => notifier.triggerFallDetectedAlert(),
            ),
          ],
        ),
      ),
    );
  }
}
