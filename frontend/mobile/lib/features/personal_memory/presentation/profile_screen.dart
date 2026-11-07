import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  void _showEditDialog(BuildContext context, WidgetRef ref, [MemoryFieldItem? item]) {
    final nameCtrl = TextEditingController(text: item?.fieldName ?? '');
    final valCtrl = TextEditingController(text: item?.fieldValue ?? '');
    bool isVerified = item?.isVerified ?? true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(item == null ? 'പുതിയ വിവരം ചേർക്കുക (Add Field)' : 'വിവരം തിരുത്തുക / സ്ഥിരീകരിക്കുക'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                readOnly: item != null,
                decoration: const InputDecoration(labelText: 'ഫീൽഡ് പേര് (Field Name, e.g. full_name, phone)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: valCtrl,
                decoration: const InputDecoration(labelText: 'വിവരം / മൂല്യം (Value)'),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('വിവരം കൃത്യമാണെന്ന് സ്ഥിരീകരിച്ചു (Verified)'),
                subtitle: const Text('സ്മാർട്ട് ഫോം പൂരിപ്പിക്കലിന് ഉപയോഗിക്കും', style: TextStyle(fontSize: 12)),
                value: isVerified,
                onChanged: (v) => setDialogState(() => isVerified = v),
              ),
            ],
          ),
          actions: [
            if (item != null)
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () async {
                  Navigator.pop(ctx);
                  await ref.read(profileRepositoryProvider).deleteField(item.fieldName);
                  ref.invalidate(profileProvider);
                },
                child: const Text('ഒഴിവാക്കുക (Delete)'),
              ),
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('റദ്ദാക്കുക (Cancel)'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameCtrl.text.trim().isNotEmpty && valCtrl.text.trim().isNotEmpty) {
                  Navigator.pop(ctx);
                  await ref.read(profileRepositoryProvider).upsertField(
                    nameCtrl.text.trim(),
                    valCtrl.text.trim(),
                    isVerified: isVerified,
                  );
                  ref.invalidate(profileProvider);
                }
              },
              child: const Text('സേവ് ചെയ്യുക (Save)'),
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
      appBar: AppBar(
        title: const Text('വ്യക്തിഗത വിവരങ്ങൾ (Personal Memory)'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('പുതിയ ഫീൽഡ് (Add Field)'),
        onPressed: () => _showEditDialog(context, ref),
      ),
      body: profileAsync.when(
        data: (fields) {
          if (fields.isEmpty) {
            return const Center(
              child: Text(
                'വ്യക്തിഗത വിവരങ്ങൾ ഒന്നും ലഭ്യമല്ല.\nരേഖകൾ അപ്‌ലോഡ് ചെയ്യുമ്പോൾ ഇവിടെ സ്വയം ചേർക്കപ്പെടും.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            );
          }

          final verified = fields.where((f) => f.isVerified).toList();
          final unverified = fields.where((f) => !f.isVerified).toList();

          return RefreshIndicator(
            onRefresh: () async => ref.refresh(profileProvider),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (unverified.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.warning_amber_rounded, color: Colors.orange),
                      const SizedBox(width: 8),
                      Text(
                        'സ്ഥിരീകരിക്കാത്ത വിവരങ്ങൾ (Draft from OCR - ${unverified.length})',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepOrange),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...unverified.map(
                    (f) => Card(
                      color: Colors.orange.withValues(alpha: 0.05),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: Colors.orange.withValues(alpha: 0.4)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        title: Text(f.fieldName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(f.fieldValue, style: const TextStyle(fontSize: 17)),
                        trailing: ElevatedButton.icon(
                          icon: const Icon(Icons.check, size: 16),
                          label: const Text('സ്ഥിരീകരിക്കുക (Verify)'),
                          onPressed: () => _showEditDialog(context, ref, f),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                Row(
                  children: [
                    const Icon(Icons.verified, color: Colors.green),
                    const SizedBox(width: 8),
                    Text(
                      'സ്ഥിരീകരിച്ച വിവരങ്ങൾ (Verified Memory - ${verified.length})',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ...verified.map(
                  (f) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      title: Text(f.fieldName, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(f.fieldValue, style: const TextStyle(fontSize: 18)),
                      trailing: const Icon(Icons.check_circle, color: Colors.green, size: 28),
                      onTap: () => _showEditDialog(context, ref, f),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
