import 'package:flutter/material.dart';

class CaregiverScreen extends StatelessWidget {
  const CaregiverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('പരിചാരകർ (Caregivers)')),
      body: const Center(
        child: Text('രേഖപ്പെടുത്തിയ പരിചാരകർ ഇവിടെ കാണാം.', style: TextStyle(fontSize: 18)),
      ),
    );
  }
}
