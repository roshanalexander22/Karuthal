import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../app/theme.dart';
import '../../../shared/widgets/sahaayi_button.dart';
import '../../../shared/widgets/sahaayi_text_field.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(text: 'elder_care@sahaayi.in');
  final _passwordController = TextEditingController(text: 'SecurePassword123!');
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: SahaayiColors.background,
      appBar: AppBar(
        backgroundColor: SahaayiColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded,
              color: SahaayiColors.textMain),
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Branding Badge
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: SahaayiColors.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(color: SahaayiColors.primary, width: 2),
                  ),
                  child: const Icon(
                    Icons.handshake_outlined,
                    color: SahaayiColors.primaryDark,
                    size: 40,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 2. Titles
              const Text(
                'സഹായിലേക്ക് സ്വാഗതം',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: SahaayiColors.textMain,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'മുതിർന്നവർക്കായുള്ള എഐ സഹായി\n(Sahaayi Elder Companion)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: SahaayiColors.textSecondary,
                  height: 1.3,
                ),
              ),

              const SizedBox(height: 32),

              // 3. Error Banner (if any)
              if (authState.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: SahaayiColors.rose,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: SahaayiColors.emergency.withAlpha(100)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: SahaayiColors.emergency, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          authState.errorMessage!,
                          style: const TextStyle(
                            color: SahaayiColors.emergency,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // 4. Form Fields
              SahaayiTextField(
                controller: _emailController,
                label: 'ഇമെയിൽ വിലാസം (Email)',
                hint: 'example@sahaayi.in',
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email_outlined,
              ),

              const SizedBox(height: 20),

              SahaayiTextField(
                controller: _passwordController,
                label: 'പാസ്‌വേഡ് (Password)',
                hint: 'രഹസ്യവാക്ക് നൽകുക',
                obscureText: _obscurePassword,
                prefixIcon: Icons.lock_outline_rounded,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: SahaayiColors.textSecondary,
                  ),
                  onPressed: () {
                    setState(() => _obscurePassword = !_obscurePassword);
                  },
                ),
              ),

              const SizedBox(height: 32),

              // 5. Submit Button
              SahaayiButton(
                label: 'പ്രവേശിക്കുക (Sign In)',
                icon: Icons.login_rounded,
                isLoading: authState.isLoading,
                onPressed: () async {
                  final email = _emailController.text.trim();
                  final pwd = _passwordController.text.trim();
                  if (email.isEmpty || pwd.isEmpty) return;

                  final ok =
                      await ref.read(authProvider.notifier).login(email, pwd);
                  if (ok && mounted) {
                    context.go('/');
                  }
                },
              ),

              const SizedBox(height: 20),

              // 6. Navigation to Register
              OutlinedButton(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  side: const BorderSide(
                      color: SahaayiColors.primary, width: 1.5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => context.push('/auth/register'),
                child: const Text(
                  'പുതിയ അക്കൗണ്ട് ഉണ്ടാക്കുക (Register)',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: SahaayiColors.primaryDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
