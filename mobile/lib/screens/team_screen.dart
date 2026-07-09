import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';

class TeamScreen extends ConsumerWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final app = ref.watch(appControllerProvider);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.read(appControllerProvider).loadTeam(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text('Team Management', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            ...app.team.map(
              (member) => Card(
                child: ListTile(
                  leading: CircleAvatar(child: Text(member.name.isEmpty ? 'U' : member.name[0].toUpperCase())),
                  title: Text(member.name),
                  subtitle: Text('${member.email}\n${member.role.name.toUpperCase()} • Level ${member.level}'),
                  isThreeLine: true,
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddMember(context, ref),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add Member'),
      ),
    );
  }

  Future<void> _showAddMember(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String role = 'STUDENT';

    final ok = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Team Member'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                    TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
                    TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: role,
                      items: const <DropdownMenuItem<String>>[
                        DropdownMenuItem(value: 'STUDENT', child: Text('Student')),
                        DropdownMenuItem(value: 'COACH', child: Text('Coach')),
                        DropdownMenuItem(value: 'ADMIN', child: Text('Admin')),
                      ],
                      onChanged: (value) => setState(() => role = value ?? 'STUDENT'),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Add')),
              ],
            );
          },
        );
      },
    );

    if (ok != true) {
      return;
    }

    await ref.read(appControllerProvider).addTeamMember(
          name: nameController.text.trim(),
          email: emailController.text.trim(),
          password: passwordController.text,
          role: role,
        );
  }
}
