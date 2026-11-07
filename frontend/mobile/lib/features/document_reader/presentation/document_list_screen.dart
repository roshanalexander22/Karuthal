import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/accessible_card.dart';
import '../providers/document_provider.dart';

class DocumentListScreen extends ConsumerWidget {
  const DocumentListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docsAsync = ref.watch(documentListProvider);

    return Scaffold(
      backgroundColor: SahaayiColors.background,
      appBar: AppBar(
        title: const Text('സൂക്ഷിച്ച രേഖകൾ (Documents)'),
        backgroundColor: SahaayiColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: SahaayiColors.textMain),
          onPressed: () => context.pop(),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          height: 58,
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: SahaayiColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18)),
              elevation: 3,
            ),
            icon: const Icon(Icons.add_photo_alternate_rounded, size: 26),
            label: const Text(
              'പുതിയ രേഖ ചേർക്കുക (Upload)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            onPressed: () => context.push('/documents/upload'),
          ),
        ),
      ),
      body: SafeArea(
        child: docsAsync.when(
          data: (docs) {
            if (docs.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: const BoxDecoration(
                          color: SahaayiColors.secondary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.folder_open_rounded,
                          size: 64,
                          color: SahaayiColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'രേഖകളൊന്നും ചേർത്തിട്ടില്ല',
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: SahaayiColors.textMain),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'നിങ്ങളുടെ ഐഡന്റിറ്റി കാർഡോ മെഡിക്കൽ കുറിപ്പുകളോ ഇവിടെ ചേർക്കാം.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 16, color: SahaayiColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 90),
              itemCount: docs.length,
              itemBuilder: (context, i) {
                final doc = docs[i];
                final isVerified = doc['status'] == 'VERIFIED';

                return AccessibleCard(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (ctx) => Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.description_rounded,
                                    color: SahaayiColors.primary, size: 28),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    doc['name']?.toString() ?? 'Document',
                                    style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 28),
                            Text('വിഭാഗം (Category): ${doc['category']}'),
                            const SizedBox(height: 8),
                            Text(
                                'സ്ഥിതി (Status): ${isVerified ? "പരിശോധിച്ചുറപ്പിച്ചു" : "പരിശോധനയിൽ"}'),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              height: 52,
                              child: OutlinedButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('അടയ്ക്കുക (Close)'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isVerified
                              ? SahaayiColors.secondary
                              : SahaayiColors.accent,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          doc['category'] == 'PRESCRIPTION'
                              ? Icons.medical_services_rounded
                              : Icons.badge_rounded,
                          color: isVerified
                              ? SahaayiColors.primaryDark
                              : const Color(0xFF2B6CB0),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc['name']?.toString() ?? 'രേഖ',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: SahaayiColors.textMain,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'വിഭാഗം: ${doc['category']}',
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: SahaayiColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isVerified
                              ? SahaayiColors.secondary
                              : SahaayiColors.accent,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isVerified
                                  ? Icons.check_circle_rounded
                                  : Icons.pending_actions_rounded,
                              size: 16,
                              color: isVerified
                                  ? SahaayiColors.primaryDark
                                  : const Color(0xFF2B6CB0),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isVerified ? 'ഉറപ്പിച്ചു' : 'പരിശോധനയിൽ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: isVerified
                                    ? SahaayiColors.primaryDark
                                    : const Color(0xFF2B6CB0),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(
            child: CircularProgressIndicator(color: SahaayiColors.primary),
          ),
          error: (e, _) => Center(
            child: Text(
              'രേഖകൾ ലോഡ് ചെയ്യുന്നതിൽ പിശക്: $e',
              style: const TextStyle(color: SahaayiColors.emergency),
            ),
          ),
        ),
      ),
    );
  }
}
