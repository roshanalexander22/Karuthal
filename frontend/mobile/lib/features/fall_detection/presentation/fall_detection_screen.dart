import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/fall_detection_provider.dart';

class FallDetectionScreen extends ConsumerWidget {
  const FallDetectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(fallDetectionProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('വീഴ്ച കണ്ടെത്തൽ (Fall Alert)')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange),
              ),
              child: const Text(
                'മുന്നറിയിപ്പ്: ഇത് ഒരു പരീക്ഷണ സുരക്ഷാ സംവിധാനം മാത്രമാണ്. ആശുപത്രി/മെഡിക്കൽ അടിയന്തിര സേവനങ്ങൾക്ക് പകരമല്ല.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 32),
            SwitchListTile(
              title: const Text('സെൻസർ നിരീക്ഷണം (Sensor Monitoring)', style: TextStyle(fontSize: 18)),
              value: state.isMonitoring,
              onChanged: (_) => ref.read(fallDetectionProvider.notifier).toggle(),
            ),
          ],
        ),
      ),
    );
  }
}
