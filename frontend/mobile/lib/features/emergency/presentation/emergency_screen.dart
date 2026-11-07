import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/accessible_card.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  bool _alertTriggered = false;

  final List<Map<String, String>> _emergencyContacts = [
    {
      'name': 'അരുൺ മാധവൻ (മകൻ / Son)',
      'relation': 'പ്രാഥമിക പരിചാരകൻ (Primary)',
      'phone': '+91 98470 12345',
    },
    {
      'name': 'ഡോ. സുരേഷ് മേനോൻ',
      'relation': 'കുടുംബ ഡോക്ടർ (Family Doctor)',
      'phone': '+91 94471 56789',
    },
    {
      'name': 'മെഡിക്കൽ ആംബുലൻസ് (Ambulance)',
      'relation': 'അടിയന്തിര സേവനം (Emergency 108)',
      'phone': '108',
    },
  ];

  void _triggerSos() {
    setState(() => _alertTriggered = true);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'അടിയന്തിര സന്ദേശം പരിചാരകർക്ക് അയച്ചു! GPS ലൊക്കേഷൻ പങ്കുവെച്ചു.',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFFDC2626),
        duration: Duration(seconds: 5),
      ),
    );
  }

  void _markSafe() {
    setState(() => _alertTriggered = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'നിങ്ങൾ സുരക്ഷിതനാണെന്ന് പരിചാരകരെ അറിയിച്ചു.',
          style: TextStyle(fontSize: 16),
        ),
        backgroundColor: SahaayiColors.primaryDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SahaayiColors.background,
      appBar: AppBar(
        title: const Text('അടിയന്തിര സഹായം (Emergency SOS)'),
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
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _alertTriggered
                    ? const Color(0xFFFEE2E2)
                    : SahaayiColors.accent,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _alertTriggered
                      ? const Color(0xFFDC2626)
                      : const Color(0xFF93C5FD),
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _alertTriggered
                        ? Icons.warning_rounded
                        : Icons.location_on_rounded,
                    color: _alertTriggered
                        ? const Color(0xFFDC2626)
                        : const Color(0xFF2563EB),
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _alertTriggered
                          ? 'അടിയന്തിര അലേർട്ട് സജീവമാണ്. പരിചാരകർക്ക് ലൊക്കേഷൻ അയച്ചു.'
                          : 'ലൊക്കേഷൻ ലഭ്യമാണ്: കോട്ടയം, കേരളം. ഒറ്റ ടാപ്പിൽ സഹായം വിളിക്കാം.',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _alertTriggered
                            ? const Color(0xFF991B1B)
                            : const Color(0xFF1E40AF),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // Big SOS Button
            Center(
              child: GestureDetector(
                onTap: _alertTriggered ? null : _triggerSos,
                child: Container(
                  width: 190,
                  height: 190,
                  decoration: BoxDecoration(
                    color: _alertTriggered
                        ? const Color(0xFFDC2626)
                        : const Color(0xFFEF4444),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withValues(alpha: 0.35),
                        blurRadius: 24,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.touch_app_rounded,
                            color: Colors.white, size: 40),
                        const SizedBox(height: 6),
                        Text(
                          _alertTriggered
                              ? 'അലേർട്ട് അയച്ചു\n(Sent)'
                              : 'സഹായം\n(SOS)',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),
            Text(
              _alertTriggered
                  ? 'പരിചാരകരുടെ മറുപടിക്കായി കാത്തിരിക്കുന്നു...'
                  : 'അടിയന്തിര ഘട്ടങ്ങളിൽ ബട്ടൺ അമർത്തുക',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: SahaayiColors.textSecondary,
              ),
            ),

            if (_alertTriggered) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: SahaayiColors.primaryDark,
                  side: const BorderSide(
                      color: SahaayiColors.primaryDark, width: 2),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: _markSafe,
                icon: const Icon(Icons.check_circle_outline),
                label: const Text(
                  'ഞാൻ ഇപ്പോൾ സുരക്ഷിതനാണ് (I am Safe)',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Emergency Contact Cards
            Row(
              children: const [
                Icon(Icons.call_rounded,
                    color: SahaayiColors.primaryDark, size: 22),
                SizedBox(width: 8),
                Text(
                  'നേരിട്ട് വിളിക്കാൻ (Quick Call)',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: SahaayiColors.textMain,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ..._emergencyContacts.map((contact) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: AccessibleCard(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: SahaayiColors.secondary,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.phone_in_talk_rounded,
                            color: SahaayiColors.primaryDark,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                contact['name']!,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: SahaayiColors.textMain,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                contact['relation']!,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: SahaayiColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                contact['phone']!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: SahaayiColors.primaryDark,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SahaayiColors.primary,
                            minimumSize: const Size(54, 48),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    '${contact['name']} ലേക്ക് കോൾ ചെയ്യുന്നു... (${contact['phone']})'),
                              ),
                            );
                          },
                          child: const Icon(Icons.call,
                              color: Colors.white, size: 22),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
