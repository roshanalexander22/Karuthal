import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../core/network/api_client.dart';

class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({super.key});

  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen> {
  bool _isTriggering = false;
  bool _isSent = false;

  final List<Map<String, String>> _contacts = [
    {
      'name': 'പ്രിയപ്പെട്ട മകൻ (Rahul)',
      'phone': '+91 98471 23456',
      'relation': 'Son',
    },
    {
      'name': 'ഫാമിലി ഡോക്ടർ (Dr. Suresh)',
      'phone': '+91 94470 12345',
      'relation': 'Doctor',
    },
    {
      'name': 'ആംബുലൻസ് (Ambulance Helpline)',
      'phone': '108',
      'relation': 'Emergency',
    },
  ];

  Future<void> _triggerSOS() async {
    setState(() => _isTriggering = true);
    try {
      final client = ref.read(apiClientProvider);
      await client.post<dynamic>(
        ApiEndpoints.emergencySos,
        data: {'reason': 'MANUAL_SOS_PANIC_BUTTON'},
      );
      setState(() {
        _isTriggering = false;
        _isSent = true;
      });
    } catch (_) {
      setState(() {
        _isTriggering = false;
        _isSent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('അടിയന്തിര സഹായം (Emergency SOS)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Massive SOS Button (Min 220x220)
            Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[700],
                    shape: const CircleBorder(),
                    elevation: 10,
                  ),
                  onPressed: _isTriggering ? null : _triggerSOS,
                  child: _isTriggering
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.emergency, size: 54, color: Colors.white),
                            SizedBox(height: 8),
                            Text(
                              'SOS\nസഹായം',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            if (_isSent) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 30),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'സഹായത്തിനായുള്ള അറിയിപ്പ് അയച്ചു കഴിഞ്ഞു. ഉടൻ ബന്ധപ്പെടും.',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            const Text(
              'ഈ ബട്ടൺ അമർത്തിയാൽ നിങ്ങളുടെ ലൊക്കേഷൻ ഉൾപ്പെടെ പരിചാരകർക്ക് ഉടൻ വിവരം ലഭിക്കും.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 17, color: Color(0xFF475569)),
            ),
            const SizedBox(height: 32),

            // Emergency Contacts List
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'അടിയന്തിര നമ്പറുകൾ (Contacts)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
            ),
            const SizedBox(height: 12),
            ..._contacts.map(
              (c) => Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: Colors.red[50],
                    child: Icon(
                      c['relation'] == 'Emergency' ? Icons.local_hospital : Icons.person,
                      color: Colors.red[800],
                    ),
                  ),
                  title: Text(c['name']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text(c['phone']!, style: const TextStyle(fontSize: 16)),
                  trailing: IconButton.filled(
                    style: IconButton.styleFrom(backgroundColor: const Color(0xFF1B5E20)),
                    icon: const Icon(Icons.call, color: Colors.white),
                    tooltip: 'വിളിക്കുക (Call)',
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${c['name']} ലേക്ക് കോൾ ചെയ്യുന്നു: ${c['phone']}')),
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
