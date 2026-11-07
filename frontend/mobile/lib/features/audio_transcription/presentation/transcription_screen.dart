import 'package:flutter/material.dart';
import '../../../shared/widgets/sahaayi_button.dart';

class TranscriptionScreen extends StatelessWidget {
  const TranscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ട്രാൻസ്ക്രിപ്ഷൻ (Audio)')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              'സംഭാഷണങ്ങൾ അല്ലെങ്കിൽ വോയ്സ് നോട്ടുകൾ എഴുതി കാണിക്കാം.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 32),
            SahaayiButton(
              label: 'റെക്കോർഡ് ആരംഭിക്കുക',
              icon: Icons.mic,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
