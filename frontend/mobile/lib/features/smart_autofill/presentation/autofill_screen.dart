import 'package:flutter/material.dart';
import '../../../shared/widgets/sahaayi_button.dart';

class AutofillScreen extends StatelessWidget {
  const AutofillScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('സ്മാർട്ട് ഫോം (Autofill)')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ഫോം പൂരിപ്പിക്കൽ സഹായം',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'സഹായി നിങ്ങളുടെ പരിശോധിച്ചുറപ്പിച്ച രേഖകളിൽ നിന്ന് വിവരങ്ങൾ നൽകി ഫോമുകൾ പൂരിപ്പിക്കാൻ സഹായിക്കുന്നു. നിങ്ങൾ സ്ഥിരീകരിച്ചതിനു ശേഷം മാത്രമേ വിവരങ്ങൾ നൽകൂ.',
              style: TextStyle(fontSize: 18),
            ),
            const Spacer(),
            SahaayiButton(
              label: 'സഹായ സേവനം പരിശോധിക്കുക',
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
