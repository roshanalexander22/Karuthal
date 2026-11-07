import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('വ്യക്തിഗത വിവരങ്ങൾ (Memory)')),
      body: profileAsync.when(
        data: (fields) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: fields.length,
          itemBuilder: (context, i) {
            final f = fields[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                title: Text(f['field']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(f['value']!, style: const TextStyle(fontSize: 18)),
                trailing: const Icon(Icons.check_circle, color: Colors.green),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
