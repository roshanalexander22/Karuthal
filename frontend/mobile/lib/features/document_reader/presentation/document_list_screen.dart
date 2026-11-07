import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/document_provider.dart';

class DocumentListScreen extends ConsumerWidget {
  const DocumentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(documentListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('രേഖകൾ (Documents)')),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('പുതിയ രേഖ (Upload)'),
        onPressed: () => context.push('/documents/upload'),
      ),
      body: docsAsync.when(
        data: (docs) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final doc = docs[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(Icons.description, size: 36, color: Colors.teal),
                title: Text(doc['name'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                subtitle: Text('തരം: ${doc['category']} | പദവി: ${doc['status']}'),
                trailing: const Icon(Icons.arrow_forward_ios),
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
