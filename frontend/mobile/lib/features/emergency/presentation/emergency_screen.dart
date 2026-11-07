import 'package:flutter/material.dart';
import '../../../shared/widgets/sahaayi_button.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('അടിയന്തിര സഹായം (SOS)')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 220,
                height: 220,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: const CircleBorder(),
                    elevation: 8,
                  ),
                  onPressed: () {},
                  child: const Text(
                    'SOS\nസഹായം',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text('ഈ ബട്ടൺ അമർത്തിയാൽ നിങ്ങളുടെ പരിചാരകർക്ക് ഉടൻ വിവരം ലഭിക്കും.', textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}
