import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/accessible_button.dart';
import '../../../shared/widgets/accessible_card.dart';
import '../../../shared/widgets/sahaayi_button.dart';
import '../providers/autofill_provider.dart';

class AutofillScreen extends ConsumerWidget {
  const AutofillScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(autofillProvider);
    final notifier = ref.read(autofillProvider.notifier);

    return Scaffold(
      backgroundColor: SahaayiColors.background,
      appBar: AppBar(
        title: const Text('സ്മാർട്ട് ഫോം (Smart Autofill)'),
        backgroundColor: SahaayiColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: SahaayiColors.textMain),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Service Status Card
              AccessibleCard(
                backgroundColor: state.isAccessibilityActive
                    ? SahaayiColors.secondary
                    : SahaayiColors.rose,
                border: BorderSide(
                  color: state.isAccessibilityActive
                      ? SahaayiColors.primary
                      : SahaayiColors.emergency,
                  width: 1.5,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          state.isAccessibilityActive
                              ? Icons.check_circle_rounded
                              : Icons.warning_amber_rounded,
                          color: state.isAccessibilityActive
                              ? SahaayiColors.primaryDark
                              : SahaayiColors.emergency,
                          size: 30,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            state.isAccessibilityActive
                                ? 'സഹായ സേവനം സജീവം (Active)'
                                : 'സഹായ സേവനം ഓഫാണ് (Permission Required)',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: state.isAccessibilityActive
                                  ? SahaayiColors.primaryDark
                                  : SahaayiColors.emergency,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      state.isAccessibilityActive
                          ? 'സഹായിക്ക് സ്ക്രീൻ പരിശോധിച്ച് ഫോമുകൾ പൂരിപ്പിക്കാൻ പൂർണ്ണ അനുമതിയുണ്ട്.'
                          : 'മറ്റു ആപ്പുകളിലെ ഫോമുകൾ പൂരിപ്പിക്കാൻ ആൻഡ്രോയിഡ് ക്രമീകരണങ്ങളിൽ സഹായി ആക്സസിബിലിറ്റി സർവീസ് ഓൺ ചെയ്യുക.',
                      style: const TextStyle(
                          fontSize: 15, color: SahaayiColors.textMain),
                    ),
                    if (!state.isAccessibilityActive) ...[
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: SahaayiColors.emergency,
                          side: const BorderSide(
                              color: SahaayiColors.emergency, width: 1.5),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        icon: const Icon(Icons.settings_outlined, size: 22),
                        label: const Text(
                            'ക്രമീകരണങ്ങൾ തുറക്കുക (Open Settings)',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () => notifier.openSettings(),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Safety & Privacy Guarantee Note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: SahaayiColors.border),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.shield_outlined,
                        color: SahaayiColors.primaryDark, size: 26),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'സുരക്ഷിത ഫോം ഫില്ലർ',
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: SahaayiColors.textMain),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'സഹായി പാസ്‌വേഡ്, ഒ.ടി.പി, ബാങ്കിംഗ് പിൻ എന്നിവ ഒരിക്കലും വായിക്കുകയോ പൂരിപ്പിക്കുകയോ ചെയ്യില്ല. നിങ്ങൾ ഉറപ്പുവരുത്തിയ വിവരങ്ങൾ മാത്രമേ ഉപയോഗിക്കൂ.',
                            style: TextStyle(
                                fontSize: 14,
                                color: SahaayiColors.textSecondary,
                                height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 3. Scan & Match Trigger Button
              AccessibleButton(
                label: state.status == AutofillStatus.scanning
                    ? 'സ്ക്രീൻ പരിശോധിക്കുന്നു...'
                    : 'സ്ക്രീൻ പരിശോധിച്ച് ഫോം കണ്ടെത്തുക',
                icon: Icons.document_scanner_rounded,
                backgroundColor: SahaayiColors.primary,
                isLoading: state.status == AutofillStatus.scanning,
                onPressed: state.status == AutofillStatus.scanning ||
                        state.status == AutofillStatus.injecting
                    ? null
                    : () => notifier.scanScreenAndMatch(),
              ),

              // Feedback messages
              if (state.errorMessage != null) ...[
                const SizedBox(height: 16),
                AccessibleCard(
                  backgroundColor: SahaayiColors.rose,
                  border: const BorderSide(color: SahaayiColors.emergency),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: SahaayiColors.emergency, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.errorMessage!,
                          style: const TextStyle(
                              color: SahaayiColors.emergency,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              if (state.successMessage != null) ...[
                const SizedBox(height: 16),
                AccessibleCard(
                  backgroundColor: SahaayiColors.secondary,
                  border: const BorderSide(color: SahaayiColors.primary),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: SahaayiColors.primaryDark, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          state.successMessage!,
                          style: const TextStyle(
                              color: SahaayiColors.primaryDark,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // 4. Proposed matches list
              if (state.proposals.isNotEmpty) ...[
                const SizedBox(height: 24),
                const Text(
                  'കണ്ടെത്തിയ വിവരങ്ങൾ:',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: SahaayiColors.textMain),
                ),
                const SizedBox(height: 4),
                const Text(
                  'പൂരിപ്പിക്കാൻ ആഗ്രഹിക്കുന്നവ ടിക്ക് ചെയ്യുക:',
                  style: TextStyle(
                      fontSize: 15, color: SahaayiColors.textSecondary),
                ),
                const SizedBox(height: 12),

                ...state.proposals.map((proposal) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: AccessibleCard(
                      backgroundColor: Colors.white,
                      border: BorderSide(
                        color: proposal.isConfirmed
                            ? SahaayiColors.primary
                            : SahaayiColors.border,
                        width: proposal.isConfirmed ? 2 : 1,
                      ),
                      onTap: () => notifier.toggleProposal(proposal.nodeId),
                      child: Row(
                        children: [
                          Checkbox(
                            value: proposal.isConfirmed,
                            activeColor: SahaayiColors.primary,
                            onChanged: (_) =>
                                notifier.toggleProposal(proposal.nodeId),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  proposal.profileFieldName.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: SahaayiColors.primaryDark,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  proposal.proposedValue,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: SahaayiColors.textMain,
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

                // Confirm and Inject Button
                SahaayiButton(
                  label: state.status == AutofillStatus.injecting
                      ? 'പൂരിപ്പിക്കുന്നു...'
                      : 'സ്ഥിരീകരിച്ച് പൂരിപ്പിക്കുക (Confirm & Fill)',
                  icon: Icons.check_circle_rounded,
                  backgroundColor: SahaayiColors.primary,
                  isLoading: state.status == AutofillStatus.injecting,
                  onPressed: state.status == AutofillStatus.injecting
                      ? null
                      : () => notifier.confirmAndInject(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
