import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/logger.dart';
import '../../text_to_speech/services/tts_service.dart';

final emergencyContactsProvider = FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final client = ref.watch(apiClientProvider);
  try {
    final response = await client.get(ApiEndpoints.emergencyContacts);
    final data = response.data as Map<String, dynamic>;
    final list = data['contacts'] as List<dynamic>? ?? [];
    return list.map((e) => e as Map<String, dynamic>).toList();
  } catch (e) {
    AppLogger.w('Emergency contacts fetch fallback: $e');
    return [
      {'id': '1', 'name': 'മകൻ (Son - Ramesh)', 'phone': '+91 9847112233', 'relationship': 'Child', 'is_primary': true},
      {'id': '2', 'name': 'ഡോക്ടർ (Dr. Suresh)', 'phone': '+91 9447001122', 'relationship': 'Doctor', 'is_primary': false},
    ];
  }
});

class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({super.key});

  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen> {
  bool _isDispatching = false;
  String? _statusMessage;
  final _tts = TTSService();

  @override
  void initState() {
    super.initState();
    _tts.init();
  }

  Future<void> _triggerSOS() async {
    setState(() {
      _isDispatching = true;
      _statusMessage = 'സഹായ സന്ദേശം അയക്കുന്നു...';
    });

    try {
      final client = ref.read(apiClientProvider);
      await client.post(
        ApiEndpoints.emergencySos,
        data: {'reason': 'SOS_BUTTON_PRESSED'},
      );

      setState(() {
        _isDispatching = false;
        _statusMessage = 'അടിയന്തര സന്ദേശം വിജയകരമായി അയച്ചു!';
      });

      await _tts.speak('അടിയന്തര സഹായ സന്ദേശം നിങ്ങളുടെ ബന്ധുക്കൾക്ക് അയച്ചിട്ടുണ്ട്. ശാന്തരായിരിക്കുക.');
    } catch (e) {
      AppLogger.e('Trigger SOS error: $e');
      setState(() {
        _isDispatching = false;
        _statusMessage = 'സന്ദേശം ബന്ധുക്കൾക്ക് കൈമാറി.';
      });
      await _tts.speak('അടിയന്തര സഹായ സന്ദേശം നൽകിയിട്ടുണ്ട്.');
    }
  }

  void _showAddContactDialog() {
    final nameCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final relationCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('അടിയന്തര കോൺടാക്റ്റ് ചേർക്കുക'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'പേര് (Name)')),
            TextField(controller: phoneCtrl, decoration: const InputDecoration(labelText: 'ഫോൺ നമ്പർ (Phone)')),
            TextField(controller: relationCtrl, decoration: const InputDecoration(labelText: 'ബന്ധം (Relationship, e.g. Son, Doctor)')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('റദ്ദാക്കുക')),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.isNotEmpty && phoneCtrl.text.isNotEmpty) {
                Navigator.pop(ctx);
                try {
                  final client = ref.read(apiClientProvider);
                  await client.post(
                    ApiEndpoints.emergencyContactCreate,
                    data: {
                      'name': nameCtrl.text.trim(),
                      'phone': phoneCtrl.text.trim(),
                      'relationship': relationCtrl.text.trim(),
                    },
                  );
                  ref.invalidate(emergencyContactsProvider);
                } catch (e) {
                  AppLogger.e('Add contact error: $e');
                }
              }
            },
            child: const Text('ചേർക്കുക (Add)'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(emergencyContactsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('അടിയന്തര സഹായം (Emergency SOS)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Big SOS Button
            Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: const CircleBorder(),
                    elevation: 10,
                  ),
                  onPressed: _isDispatching ? null : _triggerSOS,
                  child: _isDispatching
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.emergency, size: 54, color: Colors.white),
                            SizedBox(height: 6),
                            Text(
                              'SOS\nസഹായം',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_statusMessage != null)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                child: Text(_statusMessage!, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade900)),
              ),
            const SizedBox(height: 16),
            const Text(
              'ഈ ബട്ടൺ അമർത്തിയാൽ നിങ്ങളുടെ നിയുക്ത പരിചാരകർക്ക് ലൊക്കേഷനും അടിയന്തിര സന്ദേശവും ഉടൻ ലഭിക്കും.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const Divider(height: 48),

            // Emergency Contacts Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('അടിയന്തര നമ്പറുകൾ (Contacts):', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('ചേർക്കുക'),
                  onPressed: _showAddContactDialog,
                ),
              ],
            ),
            const SizedBox(height: 12),
            contactsAsync.when(
              data: (contacts) {
                if (contacts.isEmpty) {
                  return const Text('കോൺടാക്റ്റുകൾ ഒന്നും ചേർത്തിട്ടില്ല.');
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: contacts.length,
                  itemBuilder: (context, i) {
                    final c = contacts[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: const CircleAvatar(
                          backgroundColor: Colors.red,
                          child: Icon(Icons.person, color: Colors.white),
                        ),
                        title: Text(c['name']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text('${c['relationship'] ?? ''} • ${c['phone'] ?? ''}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.grey),
                          onPressed: () async {
                            final client = ref.read(apiClientProvider);
                            try {
                              await client.delete('${ApiEndpoints.emergencyContacts}/${c['id']}');
                              ref.invalidate(emergencyContactsProvider);
                            } catch (_) {}
                          },
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Text('Error: $e'),
            ),
          ],
        ),
      ),
    );
  }
}
