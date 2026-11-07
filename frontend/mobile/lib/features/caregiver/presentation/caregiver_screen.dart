import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/accessible_card.dart';
import '../../../shared/widgets/sahaayi_button.dart';

class CaregiverScreen extends StatefulWidget {
  const CaregiverScreen({super.key});

  @override
  State<CaregiverScreen> createState() => _CaregiverScreenState();
}

class _CaregiverScreenState extends State<CaregiverScreen> {
  final List<Map<String, dynamic>> _caregivers = [
    {
      'name': 'അരുൺ മാധവൻ',
      'relation': 'മകൻ (Son) • പ്രാഥമിക പരിചാരകൻ',
      'phone': '+91 98470 12345',
      'status': 'കണക്റ്റ് ചെയ്തു (Connected)',
      'permissions': ['മരുന്ന് ഓർമ്മപ്പെടുത്തൽ', 'SOS സന്ദേശം', 'ലൊക്കേഷൻ'],
    },
    {
      'name': 'പ്രിയ അരുൺ',
      'relation': 'മരുമകൾ (Daughter-in-law)',
      'phone': '+91 98470 67890',
      'status': 'കണക്റ്റ് ചെയ്തു (Connected)',
      'permissions': ['മരുന്ന് ഓർമ്മപ്പെടുത്തൽ', 'SOS സന്ദേശം'],
    },
  ];

  void _showAddCaregiverSheet() {
    final nameCtrl = TextEditingController();
    final relationCtrl = TextEditingController(text: 'മകൾ (Daughter)');
    final phoneCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: SahaayiColors.secondary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_add_alt_1_rounded,
                        color: SahaayiColors.primaryDark, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'പുതിയ പരിചാരകൻ (Add Caregiver)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: SahaayiColors.textMain,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameCtrl,
                decoration: InputDecoration(
                  labelText: 'പരിചാരകന്റെ പേര് (Name)',
                  hintText: 'ഉദാ: രാജേഷ് കുമാർ',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: relationCtrl,
                decoration: InputDecoration(
                  labelText: 'ബന്ധം (Relationship)',
                  hintText: 'ഉദാ: മകൻ / അയൽവാസി',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                  prefixIcon: const Icon(Icons.family_restroom_rounded),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: 'ഫോൺ നമ്പർ (Phone)',
                  hintText: '+91 98470 00000',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14)),
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 24),
              SahaayiButton(
                label: 'സേവ് ചെയ്യുക (Save Caregiver)',
                icon: Icons.check_circle_outline_rounded,
                onPressed: () {
                  final name = nameCtrl.text.trim();
                  final relation = relationCtrl.text.trim();
                  final phone = phoneCtrl.text.trim();

                  if (name.isEmpty || phone.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('ദയവായി പേരും ഫോൺ നമ്പറും നൽകുക.')),
                    );
                    return;
                  }

                  setState(() {
                    _caregivers.add({
                      'name': name,
                      'relation': relation.isEmpty ? 'പരിചാരകൻ' : relation,
                      'phone': phone,
                      'status': 'കണക്റ്റ് ചെയ്തു (Connected)',
                      'permissions': ['മരുന്ന് ഓർമ്മപ്പെടുത്തൽ', 'SOS സന്ദേശം'],
                    });
                  });

                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$name വിജയകരമായി ബന്ധിപ്പിച്ചു!'),
                      backgroundColor: SahaayiColors.success,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SahaayiColors.background,
      appBar: AppBar(
        title: const Text('പരിചാരകർ (Caregivers)'),
        backgroundColor: SahaayiColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: SahaayiColors.textMain),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Info Header
            AccessibleCard(
              backgroundColor: SahaayiColors.accent,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.family_restroom_rounded,
                      color: Color(0xFF2563EB), size: 32),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_caregivers.length} പരിചാരകർ ബന്ധിപ്പിച്ചിരിക്കുന്നു',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E40AF),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'മരുന്ന് കഴിച്ച വിവരങ്ങളും അടിയന്തിര അറിയിപ്പുകളും ഇവർക്ക് തത്സമയം ലഭിക്കും.',
                          style: TextStyle(
                              fontSize: 13,
                              color: const Color(0xFF1E3A8A)
                                  .withValues(alpha: 0.8)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'രേഖപ്പെടുത്തിയ പരിചാരകർ (Registered)',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: SahaayiColors.textMain,
              ),
            ),
            const SizedBox(height: 12),

            ..._caregivers.map((c) => Padding(
                  padding: const EdgeInsets.only(bottom: 14.0),
                  child: AccessibleCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: SahaayiColors.secondary,
                              child: Text(
                                (c['name'] as String).substring(0, 1),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: SahaayiColors.primaryDark,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    c['name'] as String,
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                      color: SahaayiColors.textMain,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    c['relation'] as String,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: SahaayiColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.call_rounded,
                                  color: SahaayiColors.primaryDark),
                              tooltip: 'വിളിക്കുക (Call)',
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        '${c['name']} ലേക്ക് വിളിക്കുന്നു... (${c['phone']})'),
                                    backgroundColor: SahaayiColors.primaryDark,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.check_circle_rounded,
                                color: SahaayiColors.primary, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              c['phone'] as String,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: SahaayiColors.textMain),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: SahaayiColors.secondary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'കണക്റ്റഡ്',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: SahaayiColors.primaryDark),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 6,
                          children: (c['permissions'] as List<String>)
                              .map(
                                (p) => Chip(
                                  label: Text(p,
                                      style: const TextStyle(fontSize: 11)),
                                  backgroundColor: SahaayiColors.background,
                                  padding: EdgeInsets.zero,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              )
                              .toList(),
                        ),
                      ],
                    ),
                  ),
                )),

            const SizedBox(height: 16),

            // Add Caregiver button
            SahaayiButton(
              label: 'പുതിയ പരിചാരകനെ ചേർക്കുക (Add Caregiver)',
              icon: Icons.person_add_alt_1_rounded,
              backgroundColor: SahaayiColors.secondary,
              textColor: SahaayiColors.primaryDark,
              onPressed: _showAddCaregiverSheet,
            ),
          ],
        ),
      ),
    );
  }
}
