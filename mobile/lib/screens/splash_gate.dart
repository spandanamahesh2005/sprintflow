import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/app_state.dart';
import 'backend_setup_screen.dart';
import 'home_shell.dart';
import 'login_screen.dart';
import 'tutorial_screen.dart';

class SplashGate extends ConsumerStatefulWidget {
  const SplashGate({super.key});

  @override
  ConsumerState<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends ConsumerState<SplashGate> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final settings = ref.read(settingsControllerProvider);
    final tutorial = ref.read(tutorialControllerProvider);
    final auth = ref.read(authControllerProvider);
    final app = ref.read(appControllerProvider);

    await settings.loadPreferences();
    await tutorial.load();
    await auth.restoreSession();

    if (auth.isAuthenticated) {
      await app.bootstrap();
      await auth.refreshProfile();
    }

    if (mounted) {
      setState(() => _loaded = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final settings = ref.watch(settingsControllerProvider);
    final tutorial = ref.watch(tutorialControllerProvider);
    final auth = ref.watch(authControllerProvider);

    if (!settings.backendConfigured) {
      return BackendSetupScreen(
        onConfigured: () {
          if (mounted) {
            setState(() {});
          }
        },
      );
    }

    if (!tutorial.seen) {
      return TutorialScreen(
        onDone: () async {
          await ref.read(tutorialControllerProvider).markSeen();
          if (mounted) {
            setState(() {});
          }
        },
      );
    }

    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    return const HomeShell();
  }
}
