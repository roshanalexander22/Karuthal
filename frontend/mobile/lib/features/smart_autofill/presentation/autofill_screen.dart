import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/autofill_provider.dart';
import '../../../shared/widgets/sahaayi_button.dart';

class AutofillScreen extends ConsumerStatefulWidget {
  const AutofillScreen({super.key});

  @override
  ConsumerState<AutofillScreen> createState() => _AutofillScreenState();
}

class _AutofillScreenState extends ConsumerState<AutofillScreen> {
  final _nameCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _aadhaarCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  Future<void> _triggerAutofill() async {
    final notifier = ref.read(autofillNotifierProvider.notifier);
    final fieldsToMatch = [
      {'node_id': 'name_input', 'label': 'അപേക്ഷകന്റെ പേര് (Applicant Name)'},
      {'node_id': 'dob_input', 'label': 'ജനന തീയതി (Date of Birth)'},
      {'node_id': 'aadhaar_input', 'label': 'ആധാർ നമ്പർ (Aadhaar Number)'},
      {'node_id': 'phone_input', 'label': 'ഫോൺ നമ്പർ (Phone Number)'},
      {'node_id': 'address_input', 'label': 'മേൽവിലാസം (Address)'},
    ];

    final matches = await notifier.matchScreenFields(fieldsToMatch);
    if (!mounted) return;

    // Show Human-in-the-loop Confirmation Dialog
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Row(
                children: [
                  Icon(Icons.verified_user, color: Colors.teal, size: 28),
                  SizedBox(width: 8),
                  Text('സ്ഥിരീകരിച്ച വിവരങ്ങൾ നൽകണോ?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              const Text('സഹായി നിങ്ങളുടെ പരിശോധിച്ചുറപ്പിച്ച മെമ്മറിയിൽ നിന്ന് കണ്ടെത്തിയ വിവരങ്ങൾ:'),
              const SizedBox(height: 12),
              ...matches.map(
                (m) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Icon(Icons.check, color: Colors.green, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${m.profileFieldName}: ${m.proposedValue}',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SahaayiButton(
                label: 'ശരി, ഫോമിൽ ചേർക്കുക (Apply to Form)',
                icon: Icons.auto_fix_high,
                onPressed: () async {
                  Navigator.pop(ctx);
                  for (final m in matches) {
                    if (m.nodeId == 'name_input') _nameCtrl.text = m.proposedValue;
                    if (m.nodeId == 'dob_input') _dobCtrl.text = m.proposedValue;
                    if (m.nodeId == 'aadhaar_input') _aadhaarCtrl.text = m.proposedValue;
                    if (m.nodeId == 'phone_input') _phoneCtrl.text = m.proposedValue;
                    if (m.nodeId == 'address_input') _addressCtrl.text = m.proposedValue;
                  }
                  await notifier.confirmMatches(matches);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('വിവരങ്ങൾ ഫോമിൽ പൂരിപ്പിച്ചു! (Form autofilled)')),
                    );
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _clearForm() {
    _nameCtrl.clear();
    _dobCtrl.clear();
    _aadhaarCtrl.clear();
    _phoneCtrl.clear();
    _addressCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(autofillNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('സ്മാർട്ട് ഫോം (Smart Autofill)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Explanatory Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.teal.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal),
              ),
              child: const Text(
                'സഹായി സ്മാർട്ട് ഫോം സഹായം: ഡിജിറ്റൽ ഫോമുകളോ പെൻഷൻ അപേക്ഷകളോ പൂരിപ്പിക്കുമ്പോൾ, നിങ്ങളുടെ പരിശോധിച്ചുറപ്പിച്ച മെമ്മറിയിൽ നിന്ന് വിവരങ്ങൾ സ്വയം പൊരുത്തപ്പെടുത്തി തരുന്നു.',
                style: TextStyle(fontSize: 15, height: 1.4),
              ),
            ),
            const SizedBox(height: 24),

            // Sample application form
            const Text(
              'മാതൃകാ അപേക്ഷാ ഫോം (Sample Application Form):',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'അപേക്ഷകന്റെ പേര് (Applicant Name)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _dobCtrl, decoration: const InputDecoration(labelText: 'ജനന തീയതി (Date of Birth)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _aadhaarCtrl, decoration: const InputDecoration(labelText: 'ആധാർ നമ്പർ (Aadhaar Number)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'ഫോൺ നമ്പർ (Phone Number)', border: OutlineInputBorder())),
            const SizedBox(height: 12),
            TextField(controller: _addressCtrl, maxLines: 2, decoration: const InputDecoration(labelText: 'മേൽവിലാസം (Address)', border: OutlineInputBorder())),
            const SizedBox(height: 24),

            // Smart Autofill Action Button
            SahaayiButton(
              label: state.isLoading ? 'വിവരങ്ങൾ കണ്ടെത്തുന്നു...' : 'സഹായിയെക്കൊണ്ട് പൂരിപ്പിക്കുക (Smart Autofill)',
              icon: Icons.auto_awesome,
              backgroundColor: Colors.teal,
              onPressed: state.isLoading ? null : _triggerAutofill,
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: _clearForm,
              child: const Text('ഫോം മായ്ക്കുക (Clear Form)'),
            ),
          ],
        ),
      ),
    );
  }
}
