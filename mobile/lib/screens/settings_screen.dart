import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  final _apiBaseUrlController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _apiBaseUrlController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final settings = ref.watch(settingsControllerProvider);

    final user = auth.user;
    if (user == null) {
      return const Center(child: Text('No user session'));
    }

    if (_nameController.text.isEmpty) {
      _nameController.text = user.name;
    }
    if (_apiBaseUrlController.text.isEmpty && settings.apiBaseUrl.isNotEmpty) {
      _apiBaseUrlController.text = settings.apiBaseUrl;
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: <Widget>[
        Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Backend Connection', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                TextField(
                  controller: _apiBaseUrlController,
                  decoration: const InputDecoration(
                    labelText: 'API Base URL',
                    hintText: 'http://192.168.1.25:3001',
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'On a physical phone, do not use localhost. Use your computer LAN IP and keep backend running.',
                ),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: settings.savingApiBaseUrl
                      ? null
                      : () async {
                          final ok = await ref.read(settingsControllerProvider).saveApiBaseUrl(
                                _apiBaseUrlController.text,
                              );
                          if (!mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                ok
                                    ? 'Backend URL saved'
                                    : 'Invalid URL. Example: http://192.168.1.25:3001',
                              ),
                            ),
                          );
                        },
                  child: Text(settings.savingApiBaseUrl ? 'Saving...' : 'Save Backend URL'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Profile', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Name')),
                const SizedBox(height: 10),
                TextField(enabled: false, decoration: InputDecoration(labelText: 'Email', hintText: user.email)),
                const SizedBox(height: 10),
                TextField(controller: _currentPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'Current password')),
                const SizedBox(height: 10),
                TextField(controller: _newPasswordController, obscureText: true, decoration: const InputDecoration(labelText: 'New password')),
                const SizedBox(height: 10),
                TextField(controller: _confirmController, obscureText: true, decoration: const InputDecoration(labelText: 'Confirm new password')),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: auth.loading
                      ? null
                      : () async {
                          if (_newPasswordController.text.isNotEmpty && _newPasswordController.text != _confirmController.text) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
                            }
                            return;
                          }

                          final ok = await ref.read(authControllerProvider).updateProfile(
                                name: _nameController.text.trim(),
                                currentPassword: _currentPasswordController.text,
                                newPassword: _newPasswordController.text,
                              );

                          if (!mounted) {
                            return;
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(ok ? 'Profile updated' : (auth.error ?? 'Update failed'))),
                          );
                        },
                  child: Text(auth.loading ? 'Saving...' : 'Save Changes'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('Appearance', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                DropdownButtonFormField<ThemeMode>(
                  value: settings.themeMode,
                  items: const <DropdownMenuItem<ThemeMode>>[
                    DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                    DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                    DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(settingsControllerProvider).setTheme(value);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
