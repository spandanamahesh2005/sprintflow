import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';
import 'home_shell.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final auth = ref.read(authControllerProvider);
    final ok = await auth.login(_emailController.text.trim(), _passwordController.text);

    if (!mounted || !ok) {
      return;
    }

    await ref.read(appControllerProvider).bootstrap();

    if (mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const HomeShell()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);

    return Scaffold(
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
                        Text('Welcome Back', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) => (value == null || value.isEmpty) ? 'Email is required' : null,
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _passwordController,
                          decoration: const InputDecoration(labelText: 'Password'),
                          obscureText: true,
                          validator: (value) => (value == null || value.isEmpty) ? 'Password is required' : null,
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: auth.loading ? null : _submit,
                          child: Text(auth.loading ? 'Signing in...' : 'Sign In'),
                        ),
                        if (auth.error != null) ...<Widget>[
                          const SizedBox(height: 10),
                          Text(auth.error!, style: TextStyle(color: Theme.of(context).colorScheme.error), textAlign: TextAlign.center),
                        ],
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const RegisterScreen()));
                          },
                          child: const Text('No account? Register'),
                        ),
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
