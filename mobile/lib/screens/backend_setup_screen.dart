import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';

class BackendSetupScreen extends ConsumerStatefulWidget {
  const BackendSetupScreen({super.key, required this.onConfigured});

  final VoidCallback onConfigured;

  @override
  ConsumerState<BackendSetupScreen> createState() => _BackendSetupScreenState();
}

class _BackendSetupScreenState extends ConsumerState<BackendSetupScreen> {
  final _baseUrlController = TextEditingController();

  @override
  void dispose() {
    _baseUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsControllerProvider);
    if (_baseUrlController.text.isEmpty && settings.apiBaseUrl.isNotEmpty) {
      _baseUrlController.text = settings.apiBaseUrl;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Configure Backend')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text('Backend URL required', style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      const Text(
                        'Enter your PC LAN address so the phone can reach the backend. Do not use localhost on a physical phone.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _baseUrlController,
                        decoration: const InputDecoration(
                          labelText: 'API Base URL',
                          hintText: 'http://192.168.1.25:3001',
                        ),
                      ),
                      const SizedBox(height: 12),
                      FilledButton(
                        onPressed: settings.savingApiBaseUrl
                            ? null
                            : () async {
                                final ok = await ref.read(settingsControllerProvider).saveApiBaseUrl(
                                      _baseUrlController.text,
                                    );
                                if (!mounted || !ok) {
                                  return;
                                }
                                widget.onConfigured();
                              },
                        child: Text(settings.savingApiBaseUrl ? 'Saving...' : 'Save & Continue'),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () async {
                          await ref.read(settingsControllerProvider).markBackendConfigured();
                          if (mounted) {
                            widget.onConfigured();
                          }
                        },
                        child: const Text('Use later'),
                      ),
                    ],
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