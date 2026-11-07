import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../shared/widgets/sahaayi_button.dart';
import '../../../shared/widgets/sahaayi_text_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('രജിസ്റ്റർ (Register)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            SahaayiTextField(controller: _nameController, label: 'പേര് (Full Name)'),
            const SizedBox(height: 16),
            SahaayiTextField(controller: _emailController, label: 'ഇമെയിൽ (Email)'),
            const SizedBox(height: 16),
            SahaayiTextField(controller: _passwordController, label: 'പാസ്‌വേഡ് (Password)', obscureText: true),
            const SizedBox(height: 32),
            SahaayiButton(
              label: 'രജിസ്റ്റർ ചെയ്യുക',
              onPressed: () {
                context.pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
