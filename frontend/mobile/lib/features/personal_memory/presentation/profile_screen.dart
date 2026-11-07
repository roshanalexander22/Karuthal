import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/accessible_card.dart';
import '../../../shared/widgets/sahaayi_button.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showEditFieldDialog(
      BuildContext context, WidgetRef ref, String field, String currentValue) {
    final controller = TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          field,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: SahaayiColors.textMain),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(fontSize: 17, color: SahaayiColors.textMain),
          decoration: InputDecoration(
            labelText: 'വിവരം മാറ്റുക (Edit Value)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('റദ്ദാക്കുക (Cancel)'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SahaayiColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () {
              final newVal = controller.text.trim();
              if (newVal.isNotEmpty) {
                ref
                    .read(profileNotifierProvider.notifier)
                    .upsertField(field, newVal);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('വിവരം വിജയകരമായി പുതുക്കി!'),
                    backgroundColor: SahaayiColors.success,
                  ),
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text('സേവ് ചെയ്യുക (Save)'),
          ),
        ],
      ),
    );
  }

  void _showAddFieldSheet(BuildContext context, WidgetRef ref) {
    final fieldCtrl = TextEditingController();
    final valueCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
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
            const Text(
              'പുതിയ വിവരം ചേർക്കുക (Add Field)',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: SahaayiColors.textMain,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: fieldCtrl,
              decoration: InputDecoration(
                labelText: 'വിവരത്തിന്റെ പേര് (Field Name)',
                hintText: 'ഉദാ: പെൻഷൻ നമ്പർ / ആധാർ / റേഷൻ കാർഡ്',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: valueCtrl,
              decoration: InputDecoration(
                labelText: 'വിവരം (Value)',
                hintText: 'നമ്പർ അല്ലെങ്കിൽ വിവരങ്ങൾ',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
            const SizedBox(height: 20),
            SahaayiButton(
              label: 'സേവ് ചെയ്യുക (Save to Memory)',
              icon: Icons.check_circle_outline_rounded,
              onPressed: () {
                final name = fieldCtrl.text.trim();
                final val = valueCtrl.text.trim();
                if (name.isEmpty || val.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('എല്ലാ വിവരങ്ങളും നൽകുക')),
                  );
                  return;
                }
                ref
                    .read(profileNotifierProvider.notifier)
                    .upsertField(name, val);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('വിവരം വിജയകരമായി ചേർത്തു!'),
                    backgroundColor: SahaayiColors.success,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: SahaayiColors.background,
      appBar: AppBar(
        title: const Text('വ്യക്തിഗത വിവരങ്ങൾ (Profile)'),
        backgroundColor: SahaayiColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: SahaayiColors.textMain),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined,
                color: SahaayiColors.textMain),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: profileAsync.when(
          data: (fields) {
            return ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              children: [
                // 1. User Identity Banner
                Container(
                  padding: const EdgeInsets.all(22.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(color: SahaayiColors.border),
                    boxShadow: const [
                      BoxShadow(
                          color: Color(0x08000000),
                          blurRadius: 10,
                          offset: Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: SahaayiColors.secondary,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: SahaayiColors.primary, width: 2.5),
                        ),
                        child: const Icon(Icons.person,
                            color: SahaayiColors.primaryDark, size: 40),
                      ),
                      const SizedBox(width: 18),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'മാധവൻ നായർ',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: SahaayiColors.textMain,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'പ്രായം: 74 വയസ്സ് • കോട്ടയം',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: SahaayiColors.textSecondary),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.verified_user_rounded,
                                    color: SahaayiColors.primaryDark, size: 18),
                                SizedBox(width: 6),
                                Text(
                                  'അക്കൗണ്ട് ഉറപ്പുവരുത്തി',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: SahaayiColors.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'പരിശോധിച്ചുറപ്പിച്ച വിവരങ്ങൾ',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                        color: SahaayiColors.textMain,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle_outline_rounded,
                          color: SahaayiColors.primaryDark, size: 28),
                      tooltip: 'പുതിയ വിവരം ചേർക്കുക',
                      onPressed: () => _showAddFieldSheet(context, ref),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'ഈ വിവരങ്ങൾ ഫോമുകൾ പൂരിപ്പിക്കുമ്പോൾ സഹായി ഉപയോഗിക്കും:',
                  style: TextStyle(
                      fontSize: 14, color: SahaayiColors.textSecondary),
                ),
                const SizedBox(height: 12),

                ...fields.map((f) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: AccessibleCard(
                      backgroundColor: Colors.white,
                      onTap: () => _showEditFieldDialog(
                          context, ref, f['field']!, f['value']!),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: SahaayiColors.accent,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.bookmark_outline_rounded,
                                color: Color(0xFF2B6CB0), size: 24),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  f['field']!,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: SahaayiColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  f['value']!,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                    color: SahaayiColors.textMain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.copy_rounded,
                                size: 20, color: SahaayiColors.textSecondary),
                            tooltip: 'കോപ്പി ചെയ്യുക',
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: f['value']!));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content:
                                        Text('${f['field']} കോപ്പി ചെയ്തു!')),
                              );
                            },
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: SahaayiColors.secondary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.check_rounded,
                                    color: SahaayiColors.primaryDark, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  'ഉറപ്പിച്ചു',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: SahaayiColors.primaryDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Button to add information
                SahaayiButton(
                  label: 'പുതിയ വിവരം ചേർക്കുക (Add Information)',
                  icon: Icons.add_rounded,
                  backgroundColor: SahaayiColors.secondary,
                  textColor: SahaayiColors.primaryDark,
                  onPressed: () => _showAddFieldSheet(context, ref),
                ),

                const SizedBox(height: 20),

                // Caregiver info card
                AccessibleCard(
                  backgroundColor: SahaayiColors.lavender.withAlpha(80),
                  onTap: () => context.push('/caregiver'),
                  child: const Row(
                    children: [
                      Icon(Icons.family_restroom_rounded,
                          color: Color(0xFF6B46C1), size: 30),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'കെയർഗിവർ വിവരങ്ങൾ (Caregiver Sync)',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: SahaayiColors.textMain),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'അടിയന്തിര സാഹചര്യങ്ങളിൽ ബന്ധപ്പെടേണ്ടവർ',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: SahaayiColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.arrow_forward_ios_rounded,
                          size: 16, color: SahaayiColors.textSecondary),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            );
          },
          loading: () => const Center(
              child: CircularProgressIndicator(color: SahaayiColors.primary)),
          error: (e, _) => Center(child: Text('പിശക്: $e')),
        ),
      ),
    );
  }
}
