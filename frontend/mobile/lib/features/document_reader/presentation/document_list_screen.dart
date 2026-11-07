import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/document_provider.dart';
import '../repositories/document_repository.dart';
import '../../text_to_speech/services/tts_service.dart';

class DocumentListScreen extends ConsumerWidget {
  const DocumentListScreen({super.key});

  void _showDocumentDetails(BuildContext context, WidgetRef ref, DocumentItem doc) {
    final tts = TTSService();
    tts.init();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          builder: (c, scrollCtrl) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: ListView(
                controller: scrollCtrl,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          doc.originalFilename,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up, size: 30, color: Colors.teal),
                        onPressed: () {
                          if (doc.extractedText != null) {
                            tts.speak(doc.extractedText!);
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('തരം: ${doc.documentCategory} | സ്റ്റാറ്റസ്: ${doc.ocrStatus}'),
                  const Divider(height: 24),
                  const Text('വായിച്ചെടുത്ത അക്ഷരങ്ങൾ (Extracted Text):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      doc.extractedText ?? 'ടെക്സ്റ്റ് ലഭ്യമല്ല',
                      style: const TextStyle(fontSize: 16, height: 1.4),
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade700, foregroundColor: Colors.white),
                    icon: const Icon(Icons.delete),
                    label: const Text('രേഖ ഒഴിവാക്കുക (Delete)'),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      await ref.read(documentRepositoryProvider).deleteDocument(doc.id);
                      ref.invalidate(documentListProvider);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

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
        data: (docs) {
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'രേഖകളൊന്നും അപ്‌ലോഡ് ചെയ്തിട്ടില്ല.\nപുതിയ രേഖ ചേർക്കാൻ + അമർത്തുക.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.refresh(documentListProvider),
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: docs.length,
              itemBuilder: (context, i) {
                final doc = docs[i];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(Icons.description, size: 36, color: Colors.teal),
                    title: Text(doc.originalFilename, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    subtitle: Text('തരം: ${doc.documentCategory} | പദവി: ${doc.ocrStatus}'),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showDocumentDetails(context, ref, doc),
                  ),
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
