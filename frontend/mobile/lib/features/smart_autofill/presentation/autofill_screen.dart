import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/widgets/accessible_button.dart';
import '../../../shared/widgets/accessible_card.dart';
import '../providers/autofill_provider.dart';

class AutofillScreen extends ConsumerWidget {
  const AutofillScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(autofillProvider);
    final notifier = ref.read(autofillProvider.notifier);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('സ്മാർട്ട് ഫോം (Smart Autofill)'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Card
            AccessibleCard(
              backgroundColor: state.isAccessibilityActive
                  ? theme.colorScheme.primaryContainer.withAlpha(80)
                  : theme.colorScheme.errorContainer.withAlpha(80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        state.isAccessibilityActive
                            ? Icons.check_circle_outline
                            : Icons.warning_amber_rounded,
                        color: state.isAccessibilityActive
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.isAccessibilityActive
                              ? 'സഹായ സേവനം സജീവം'
                              : 'സഹായ സേവനം ഓഫ് ചെയ്തിരിക്കുന്നു',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    state.isAccessibilityActive
                        ? 'സഹായിക്ക് സ്ക്രീൻ പരിശോധിച്ച് ഫോമുകൾ പൂരിപ്പിക്കാൻ അനുമതിയുണ്ട്.'
                        : 'സ്ക്രീൻ വിവരങ്ങൾ വായിക്കാൻ ക്രമീകരണങ്ങളിൽ സഹായി ആക്സസിബിലിറ്റി സർവീസ് ഓൺ ചെയ്യുക.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  if (!state.isAccessibilityActive) ...[
                    const SizedBox(height: 14),
                    AccessibleButton(
                      label: 'ക്രമീകരണങ്ങൾ തുറക്കുക',
                      icon: Icons.settings,
                      minHeight: 48,
                      onPressed: () => notifier.openSettings(),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Scan Screen Action
            AccessibleButton(
              label: state.status == AutofillStatus.scanning
                  ? 'സ്ക്രീൻ പരിശോധിക്കുന്നു...'
                  : 'സ്ക്രീൻ പരിശോധിച്ച് ഫോം കണ്ടെത്തുക',
              icon: Icons.document_scanner_outlined,
              isLoading: state.status == AutofillStatus.scanning,
              onPressed: state.status == AutofillStatus.scanning || state.status == AutofillStatus.injecting
                  ? null
                  : () => notifier.scanScreenAndMatch(),
            ),

            // Error Message
            if (state.errorMessage != null) ...[
              const SizedBox(height: 16),
              AccessibleCard(
                backgroundColor: theme.colorScheme.errorContainer,
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: theme.colorScheme.error, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: TextStyle(color: theme.colorScheme.onErrorContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Success Message
            if (state.successMessage != null) ...[
              const SizedBox(height: 16),
              AccessibleCard(
                backgroundColor: theme.colorScheme.tertiaryContainer,
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: theme.colorScheme.tertiary, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.successMessage!,
                        style: TextStyle(color: theme.colorScheme.onTertiaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Detected Proposals List
            if (state.proposals.isNotEmpty) ...[
              const SizedBox(height: 24),
              Text(
                'കണ്ടെത്തിയ വിവരങ്ങൾ (${state.proposals.length})',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'പൂരിപ്പിക്കാൻ ആഗ്രഹിക്കുന്ന വിവരങ്ങൾ പരിശോധിച്ച് ഉറപ്പുവരുത്തുക:',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 12),
              ...state.proposals.map((proposal) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: AccessibleCard(
                    onTap: () => notifier.toggleProposal(proposal.nodeId),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: proposal.isConfirmed,
                          onChanged: (_) => notifier.toggleProposal(proposal.nodeId),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                proposal.profileFieldName.toUpperCase(),
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                proposal.proposedValue,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              AccessibleButton(
                label: state.status == AutofillStatus.injecting
                    ? 'പൂരിപ്പിക്കുന്നു...'
                    : 'സ്ഥിരീകരിച്ച് പൂരിപ്പിക്കുക',
                icon: Icons.check,
                backgroundColor: theme.colorScheme.primary,
                isLoading: state.status == AutofillStatus.injecting,
                onPressed: state.status == AutofillStatus.injecting
                    ? null
                    : () => notifier.confirmAndInject(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
