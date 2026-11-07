import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/sahaayi_button.dart';
import '../../../shared/widgets/sahaayi_text_field.dart';
import '../providers/auth_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: SahaayiColors.background,
      appBar: AppBar(
        title: const Text('പുതിയ അക്കൗണ്ട് (Register)'),
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
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'സഹായി കുടുംബത്തിലേക്ക് സ്വാഗതം',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: SahaayiColors.textMain,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'നിങ്ങളുടെ വിവരങ്ങൾ സുരക്ഷിതമായി ഇവിടെ സൂക്ഷിക്കാം.',
                  style: TextStyle(
                      fontSize: 15, color: SahaayiColors.textSecondary),
                ),
                const SizedBox(height: 24),
                if (authState.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: SahaayiColors.rose,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: SahaayiColors.emergency.withAlpha(100)),
                    ),
                    child: Text(
                      authState.errorMessage!,
                      style: const TextStyle(
                          color: SahaayiColors.emergency,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                SahaayiTextField(
                  controller: _nameController,
                  label: 'പൂർണ്ണ നാമം (Full Name)',
                  hint: 'ഉദാ: മാധവൻ നായർ',
                  prefixIcon: Icons.person_outline_rounded,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'ദയവായി പേര് നൽകുക'
                      : null,
                ),
                const SizedBox(height: 18),
                SahaayiTextField(
                  controller: _emailController,
                  label: 'ഇമെയിൽ (Email Address)',
                  hint: 'example@sahaayi.in',
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email_outlined,
                  validator: (v) {
                    if (v == null || !v.contains('@'))
                      return 'സാധുവായ ഇമെയിൽ നൽകുക';
                    return null;
                  },
                ),
                const SizedBox(height: 18),
                SahaayiTextField(
                  controller: _phoneController,
                  label: 'ഫോൺ നമ്പർ (Phone Number)',
                  hint: '+91 9876543210',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icons.phone_outlined,
                ),
                const SizedBox(height: 18),
                SahaayiTextField(
                  controller: _passwordController,
                  label: 'പാസ്‌വേഡ് (Password)',
                  hint: 'കുറഞ്ഞത് 8 അക്ഷരങ്ങൾ',
                  obscureText: _obscurePassword,
                  prefixIcon: Icons.lock_outline_rounded,
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.length < 8)
                      return 'പാസ്‌വേഡ് കുറഞ്ഞത് 8 അക്ഷരങ്ങൾ വേണം';
                    return null;
                  },
                ),
                const SizedBox(height: 32),
                SahaayiButton(
                  label: 'രജിസ്റ്റർ ചെയ്യുക (Register)',
                  icon: Icons.check_circle_outline_rounded,
                  isLoading: authState.isLoading,
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;

                    final ok = await ref.read(authProvider.notifier).register(
                          _emailController.text.trim(),
                          _passwordController.text.trim(),
                          _nameController.text.trim(),
                          phone: _phoneController.text.trim().isEmpty
                              ? null
                              : _phoneController.text.trim(),
                          languagePreference: 'ml',
                        );

                    if (ok && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('രജിസ്ട്രേഷൻ വിജയകരം! സ്വാഗതം.'),
                          backgroundColor: SahaayiColors.success,
                        ),
                      );
                      context.go('/');
                    }
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
