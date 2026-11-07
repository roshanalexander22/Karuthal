import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ക്രമീകരണങ്ങൾ (Settings)')),
      body: ListView(
        children: const [
          ListTile(title: Text('ഭാഷ (Language)'), subtitle: Text('മലയാളം (Malayalam)')),
          ListTile(title: Text('അക്ഷര വലിപ്പം (Font Size)'), subtitle: Text('വലുത് (Large)')),
          ListTile(title: Text('ശബ്ദ വേഗത (Speech Speed)'), subtitle: Text('സാധാരണ (0.85x)')),
        ],
      ),
    );
  }
}
