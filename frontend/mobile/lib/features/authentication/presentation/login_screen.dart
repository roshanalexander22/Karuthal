import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/sahaayi_button.dart';
import '../../../shared/widgets/sahaayi_text_field.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController(text: 'user@sahaayi.in');
  final _passwordController = TextEditingController(text: 'Password123!');

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('ലോഗിൻ (Login)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Text(
              'സഹായിലേക്ക് സ്വാഗതം',
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('മുതിർന്നവർക്കായുള്ള എഐ സഹായി', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 32),
            SahaayiTextField(
              controller: _emailController,
              label: 'ഇമെയിൽ (Email)',
              prefixIcon: Icons.email,
            ),
            const SizedBox(height: 20),
            SahaayiTextField(
              controller: _passwordController,
              label: 'പാസ്‌വേഡ് (Password)',
              obscureText: true,
              prefixIcon: Icons.lock,
            ),
            const SizedBox(height: 32),
            SahaayiButton(
              label: 'പ്രവേശിക്കുക (Sign In)',
              isLoading: authState.isLoading,
              onPressed: () async {
                final success = await ref.read(authProvider.notifier).login(
                  _emailController.text,
                  _passwordController.text,
                );
                if (success && mounted) {
                  context.go('/');
                }
              },
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () => context.push('/auth/register'),
              child: const Text('പുതിയ അക്കൗണ്ട് ഉണ്ടാക്കുക (Register)', style: TextStyle(fontSize: 18)),
            )
          ],
        ),
      ),
    );
  }
}
