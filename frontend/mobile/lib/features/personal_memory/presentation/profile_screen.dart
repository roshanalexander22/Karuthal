import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_field.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddOrEditDialog({ProfileFieldModel? existing}) {
    final nameCtrl = TextEditingController(text: existing?.fieldName ?? '');
    final valCtrl = TextEditingController(text: existing?.fieldValue ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          existing == null ? 'വിവരം ചേർക്കുക (Add Field)' : 'മാറ്റം വരുത്തുക (Edit Field)',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameCtrl,
              enabled: existing == null,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                labelText: 'വിവരത്തിന്റെ പേര് (Field Name)',
                hintText: 'ഉദാ: Ration Card Number',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valCtrl,
              style: const TextStyle(fontSize: 18),
              decoration: const InputDecoration(
                labelText: 'വിവരം (Value)',
                hintText: 'കൃത്യമായ നമ്പർ അല്ലെങ്കിൽ വിവരം',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('റദ്ദാക്കുക (Cancel)', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(120, 50),
              backgroundColor: const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              if (nameCtrl.text.trim().isNotEmpty && valCtrl.text.trim().isNotEmpty) {
                ref.read(profileNotifierProvider.notifier).upsertField(
                  nameCtrl.text.trim(),
                  valCtrl.text.trim(),
                  isVerified: true,
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('വിവരം വിജയകരമായി സൂക്ഷിച്ചു (Saved successfully)'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text('സൂക്ഷിക്കുക (Save)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showConfirmDraftDialog(ProfileFieldModel field) {
    final editCtrl = TextEditingController(text: field.fieldValue);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'കരട് സ്ഥിരീകരിക്കുക (Verify Draft)',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ഫീൽഡ്: ${field.fieldName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            const SizedBox(height: 12),
            const Text(
              'OCR വഴി കണ്ടെത്തിയ വിവരത്തിൽ തെറ്റുണ്ടെങ്കിൽ തിരുത്താം:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: editCtrl,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'ശരിയായ വിവരം',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('പിന്നീട് (Later)', style: TextStyle(fontSize: 16)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(140, 52),
              backgroundColor: Colors.green[800],
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('സ്ഥിരീകരിക്കുക (Verify)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            onPressed: () {
              ref.read(profileNotifierProvider.notifier).verifyField(
                field.fieldName,
                editedValue: editCtrl.text.trim(),
              );
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('വിവരം സ്ഥിരീകരിച്ചു! ഇനി ഇത് ഓട്ടോഫില്ലിനായി ഉപയോഗിക്കാം.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFieldCard(ProfileFieldModel field) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    field.fieldName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF263238)),
                  ),
                ),
                if (field.isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green, width: 1.5),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle, size: 18, color: Colors.green),
                        SizedBox(width: 4),
                        Text('സ്ഥിരീകരിച്ചത്', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber[800]!, width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.warning_amber_rounded, size: 18, color: Colors.amber[900]),
                        const SizedBox(width: 4),
                        Text('കരട് (Review)', style: TextStyle(color: Colors.amber[900], fontWeight: FontWeight.bold, fontSize: 14)),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              field.fieldValue,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!field.isVerified) ...[
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[800],
                      foregroundColor: Colors.white,
                      minimumSize: const Size(150, 48),
                    ),
                    icon: const Icon(Icons.check, size: 20),
                    label: const Text('പരിശോധിച്ച് ഉറപ്പാക്കുക', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    onPressed: () => _showConfirmDraftDialog(field),
                  ),
                  const SizedBox(width: 12),
                ],
                IconButton(
                  tooltip: 'തിരുത്തുക',
                  icon: const Icon(Icons.edit, color: Colors.blueGrey, size: 28),
                  onPressed: () => _showAddOrEditDialog(existing: field),
                ),
                IconButton(
                  tooltip: 'ഒഴിവാക്കുക',
                  icon: const Icon(Icons.delete_outline, color: Colors.red, size: 28),
                  onPressed: () {
                    ref.read(profileNotifierProvider.notifier).deleteField(field.fieldName);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('വ്യക്തിഗത വിവരങ്ങൾ (Memory)', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        bottom: TabBar(
          controller: _tabController,
          labelStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          tabs: [
            Tab(text: 'സ്ഥിരീകരിച്ചവ (${state.verifiedFields.length})'),
            Tab(text: 'കരട് വിവരങ്ങൾ (${state.draftFields.length})'),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                // 1. Verified Fields Tab
                state.verifiedFields.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.verified_user_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            const Text('സ്ഥിരീകരിച്ച വിവരങ്ങൾ ഒന്നും ചേർത്തിട്ടില്ല.', style: TextStyle(fontSize: 18)),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _showAddOrEditDialog(),
                              child: const Text('വിവരം ചേർക്കുക', style: TextStyle(fontSize: 16)),
                            )
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.verifiedFields.length,
                        itemBuilder: (context, i) => _buildFieldCard(state.verifiedFields[i]),
                      ),

                // 2. Draft Fields Tab
                state.draftFields.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.document_scanner_outlined, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 12),
                            const Text(
                              'പുതിയ കരട് വിവരങ്ങൾ ഒന്നും ലഭ്യമല്ല.\nഡോക്യുമെന്റ് സ്കാൻ ചെയ്യുമ്പോൾ ഇവിടെ കാണാം.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: state.draftFields.length,
                        itemBuilder: (context, i) => _buildFieldCard(state.draftFields[i]),
                      ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('വിവരം ചേർക്കുക', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        onPressed: () => _showAddOrEditDialog(),
      ),
    );
  }
}
