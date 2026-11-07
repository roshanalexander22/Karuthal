import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/accessible_card.dart';
import '../../../shared/widgets/sahaayi_button.dart';
import '../../authentication/providers/auth_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  String _selectedLanguage = 'ml';
  String _fontSize = 'large';
  double _speechSpeed = 0.85;
  bool _highContrast = false;
  bool _audioFeedback = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SahaayiColors.background,
      appBar: AppBar(
        title: const Text('ക്രമീകരണങ്ങൾ (Settings)'),
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
            // User summary chip
            AccessibleCard(
              backgroundColor: SahaayiColors.secondary,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: SahaayiColors.primary,
                    child:
                        const Icon(Icons.person, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'മാധവൻ നായർ',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: SahaayiColors.textMain,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'madhavan.nair@example.com',
                          style: TextStyle(
                            fontSize: 14,
                            color: SahaayiColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section 1: Language & Voice
            const Text(
              'ഭാഷയും ശബ്ദവും (Language & Voice)',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: SahaayiColors.textMain,
              ),
            ),
            const SizedBox(height: 12),

            AccessibleCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ആപ്പ് ഭാഷ (App Language)',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: SahaayiColors.textMain,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(
                            child: Text(
                              'മലയാളം',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          selected: _selectedLanguage == 'ml',
                          selectedColor: SahaayiColors.primary,
                          labelStyle: TextStyle(
                            color: _selectedLanguage == 'ml'
                                ? Colors.white
                                : SahaayiColors.textMain,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedLanguage = 'ml');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(
                            child: Text(
                              'English',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                          selected: _selectedLanguage == 'en',
                          selectedColor: SahaayiColors.primary,
                          labelStyle: TextStyle(
                            color: _selectedLanguage == 'en'
                                ? Colors.white
                                : SahaayiColors.textMain,
                          ),
                          onSelected: (val) {
                            if (val) setState(() => _selectedLanguage = 'en');
                          },
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'വായനാ വേഗത (Speech Speed)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: SahaayiColors.textMain,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: SahaayiColors.secondary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_speechSpeed.toStringAsFixed(2)}x (ശുപാർശ)',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: SahaayiColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _speechSpeed,
                    min: 0.5,
                    max: 1.5,
                    divisions: 10,
                    activeColor: SahaayiColors.primary,
                    inactiveColor: SahaayiColors.border,
                    label: '${_speechSpeed.toStringAsFixed(2)}x',
                    onChanged: (val) => setState(() => _speechSpeed = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section 2: Display & Accessibility
            const Text(
              'കാഴ്ചയും സൗകര്യവും (Accessibility)',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: SahaayiColors.textMain,
              ),
            ),
            const SizedBox(height: 12),

            AccessibleCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.format_size_rounded,
                        color: SahaayiColors.primary, size: 28),
                    title: const Text(
                      'അക്ഷര വലിപ്പം (Font Size)',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      _fontSize == 'large'
                          ? 'വലുത് (മുതിർന്നവർക്ക് അനുയോജ്യം)'
                          : 'സാധാരണ',
                      style: TextStyle(
                          fontSize: 14, color: SahaayiColors.textSecondary),
                    ),
                    trailing: DropdownButton<String>(
                      value: _fontSize,
                      underline: const SizedBox(),
                      items: const [
                        DropdownMenuItem(
                            value: 'regular', child: Text('സാധാരണ')),
                        DropdownMenuItem(
                            value: 'large', child: Text('വലുത് (Large)')),
                        DropdownMenuItem(
                            value: 'xlarge', child: Text('വളരെ വലുത്')),
                      ],
                      onChanged: (val) {
                        if (val != null) setState(() => _fontSize = val);
                      },
                    ),
                  ),
                  const Divider(height: 20),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: SahaayiColors.primary,
                    title: const Text(
                      'ശബ്ദ നിർദ്ദേശങ്ങൾ (Audio Feedback)',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'ഓരോ ബട്ടൺ അമർത്തുമ്പോഴും പേര് വായിക്കുക',
                      style: TextStyle(
                          fontSize: 14, color: SahaayiColors.textSecondary),
                    ),
                    value: _audioFeedback,
                    onChanged: (val) => setState(() => _audioFeedback = val),
                  ),
                  const Divider(height: 20),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeThumbColor: SahaayiColors.primary,
                    title: const Text(
                      'ഉയർന്ന തെളിച്ചം (High Contrast)',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'വായന എളുപ്പമാക്കാൻ ബോർഡറുകൾ കടുപ്പിക്കുക',
                      style: TextStyle(
                          fontSize: 14, color: SahaayiColors.textSecondary),
                    ),
                    value: _highContrast,
                    onChanged: (val) => setState(() => _highContrast = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Section 3: Caregiver & Fall Detection
            const Text(
              'സുരക്ഷയും പരിചരണവും (Safety & Caregiver)',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: SahaayiColors.textMain,
              ),
            ),
            const SizedBox(height: 12),

            AccessibleCard(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.people_outline_rounded,
                        color: SahaayiColors.primary, size: 28),
                    title: const Text(
                      'പരിചാരകരെ നിയന്ത്രിക്കുക (Caregivers)',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'അടിയന്തിര ഫോൺ നമ്പറുകളും അറിയിപ്പുകളും',
                      style: TextStyle(
                          fontSize: 14, color: SahaayiColors.textSecondary),
                    ),
                    trailing:
                        const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => context.push('/caregiver'),
                  ),
                  const Divider(height: 12),
                  ListTile(
                    leading: const Icon(Icons.warning_amber_rounded,
                        color: Color(0xFFE65100), size: 28),
                    title: const Text(
                      'വീഴ്ച കണ്ടെത്തൽ (Fall Detection)',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      'സെൻസർ നിരീക്ഷണ നില പരിശോധിക്കുക',
                      style: TextStyle(
                          fontSize: 14, color: SahaayiColors.textSecondary),
                    ),
                    trailing:
                        const Icon(Icons.arrow_forward_ios_rounded, size: 16),
                    onTap: () => context.push('/fall-detection'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Logout Action Button
            SahaayiButton(
              label: 'ലോഗ് ഔട്ട് ചെയ്യുക (Log Out)',
              icon: Icons.logout_rounded,
              backgroundColor: const Color(0xFFFEE2E2),
              textColor: const Color(0xFFDC2626),
              onPressed: () => _confirmLogout(context),
            ),

            const SizedBox(height: 24),
            Center(
              child: Text(
                'സഹായി (Sahaayi) v1.0.0\nപ്രായമായവർക്കുള്ള സമഗ്ര ഡിജിറ്റൽ സഹായി',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: SahaayiColors.textSecondary.withValues(alpha: 0.8),
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'പുറത്തു കടക്കണോ?',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: SahaayiColors.textMain),
        ),
        content: const Text(
          'സഹായി ആപ്പിൽ നിന്ന് ലോഗ് ഔട്ട് ചെയ്യാൻ തീർച്ചയാണോ?',
          style: TextStyle(fontSize: 16, color: SahaayiColors.textMain),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'റദ്ദാക്കുക (Cancel)',
              style:
                  TextStyle(fontSize: 16, color: SahaayiColors.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              await ref.read(authProvider.notifier).logout();
              if (mounted) {
                context.go('/auth/login');
              }
            },
            child: const Text('ലോഗ് ഔട്ട്',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
