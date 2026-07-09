import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';
import 'home_shell.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final auth = ref.read(authControllerProvider);
    final ok = await auth.register(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _passwordController.text,
    );

    if (!mounted || !ok) {
      return;
    }

    await ref.read(appControllerProvider).bootstrap();

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomeShell()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Text('Start Simulation', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Full Name'),
                          validator: (value) => (value == null || value.isEmpty) ? 'Name is required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator: (value) => (value == null || value.isEmpty) ? 'Email is required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: (value) => (value == null || value.length < 6) ? 'Minimum 6 chars' : null,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: auth.loading ? null : _submit,
                          child: Text(auth.loading ? 'Creating...' : 'Register'),
                        ),
                        if (auth.error != null) ...<Widget>[
                          const SizedBox(height: 10),
                          Text(auth.error!, style: TextStyle(color: Theme.of(context).colorScheme.error), textAlign: TextAlign.center),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
