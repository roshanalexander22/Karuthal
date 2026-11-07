import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/autofill_match_model.dart';
import '../providers/autofill_provider.dart';

class AutofillScreen extends ConsumerStatefulWidget {
  const AutofillScreen({super.key});

  @override
  ConsumerState<AutofillScreen> createState() => _AutofillScreenState();
}

class _AutofillScreenState extends ConsumerState<AutofillScreen> {
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _aadhaarController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _aadhaarController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _triggerAutofill() async {
    final fields = [
      const ScreenFormFieldModel(nodeId: 'name_field', label: 'അപേക്ഷകന്റെ പേര് (Applicant Name)'),
      const ScreenFormFieldModel(nodeId: 'dob_field', label: 'ജനന തീയതി (Date of Birth)'),
      const ScreenFormFieldModel(nodeId: 'address_field', label: 'മേൽവിലാസം (Address)'),
      const ScreenFormFieldModel(nodeId: 'aadhaar_field', label: 'ആധാർ നമ്പർ (Aadhaar Number)'),
      const ScreenFormFieldModel(nodeId: 'phone_field', label: 'ഫോൺ നമ്പർ (Phone Number)'),
    ];

    final matches = await ref.read(autofillNotifierProvider.notifier).requestMatches(fields);
    if (!mounted) return;

    if (matches.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('സ്ഥിരീകരിച്ച രേഖകളിൽ പൊരുത്തപ്പെടുന്ന വിവരങ്ങൾ ലഭ്യമല്ല.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _showConfirmationBottomSheet(matches);
  }

  void _showConfirmationBottomSheet(List<FieldMatchProposalModel> matches) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.verified_user, color: Color(0xFF1B5E20), size: 30),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'വിവരങ്ങൾ പരിശോധിക്കുക (Review)',
                    style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'സ്ഥിരീകരിച്ച രേഖകളിൽ നിന്നുള്ള വിവരങ്ങളാണ് താഴെ നൽകിയിരിക്കുന്നത്. ഇവ ഫോമിൽ നൽകാൻ സമ്മതമാണോ?',
              style: TextStyle(fontSize: 16, height: 1.4),
            ),
            const Divider(height: 24),
            ...matches.map(
              (m) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle, size: 20, color: Colors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(m.profileFieldName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                          Text(m.proposedValue, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E293B))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: Colors.blue, size: 22),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'പാസ്‌വേഡുകൾ അല്ലെങ്കിൽ ഒടിപി വിവരങ്ങൾ ഒരിക്കലും നൽകില്ല.',
                      style: TextStyle(fontSize: 14, color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(minimumSize: const Size(0, 52)),
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('റദ്ദാക്കുക (Cancel)', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1B5E20),
                      foregroundColor: Colors.white,
                      minimumSize: const Size(0, 52),
                    ),
                    onPressed: () {
                      _applyMatches(matches);
                      ref.read(autofillNotifierProvider.notifier).confirmMatches(matches);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('വിവരങ്ങൾ ഫോമിൽ വിജയകരമായി പൂരിപ്പിച്ചു!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    child: const Text('പൂരിപ്പിക്കുക (Fill)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _applyMatches(List<FieldMatchProposalModel> matches) {
    setState(() {
      for (final m in matches) {
        if (m.nodeId == 'name_field') {
          _nameController.text = m.proposedValue;
        } else if (m.nodeId == 'dob_field') {
          _dobController.text = m.proposedValue;
        } else if (m.nodeId == 'address_field') {
          _addressController.text = m.proposedValue;
        } else if (m.nodeId == 'aadhaar_field') {
          _aadhaarController.text = m.proposedValue;
        } else if (m.nodeId == 'phone_field') {
          _phoneController.text = m.proposedValue;
        }
      }
    });
  }

  Widget _buildFormField(String label, TextEditingController controller, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 18),
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        const SizedBox(height: 18),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(autofillNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('സ്മാർട്ട് ഫോം (Autofill)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1B5E20).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1B5E20).withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.auto_awesome, color: Color(0xFF1B5E20), size: 30),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'മുതിർന്ന പൗരന്മാർക്കുള്ള ക്ഷേമ പെൻഷൻ അപേക്ഷ\n(Senior Citizen Pension Application Form)',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            _buildFormField('അപേക്ഷകന്റെ പേര് (Applicant Name)', _nameController, hint: 'പൂർണ്ണമായ പേര് നൽകുക'),
            _buildFormField('ജനന തീയതി (Date of Birth)', _dobController, hint: 'DD/MM/YYYY'),
            _buildFormField('മേൽവിലാസം (Address)', _addressController, hint: 'വീട്ടുപേര്, സ്ഥലം, പിൻകോഡ്'),
            _buildFormField('ആധാർ നമ്പർ (Aadhaar Number)', _aadhaarController, hint: 'XXXX XXXX XXXX'),
            _buildFormField('ഫോൺ നമ്പർ (Phone Number)', _phoneController, hint: '10 അക്ക മൊബൈൽ നമ്പർ'),

            const SizedBox(height: 16),

            // Smart Autofill Button (Min 56dp)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B5E20),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 4,
                ),
                icon: state.isMatching
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : const Icon(Icons.flash_on, size: 28),
                label: const Text(
                  'സഹായി വഴി ഓട്ടോഫിൽ ചെയ്യുക',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                onPressed: state.isMatching ? null : _triggerAutofill,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
