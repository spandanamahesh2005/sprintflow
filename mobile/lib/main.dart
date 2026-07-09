import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/app_state.dart';
import 'screens/splash_gate.dart';

void main() {
  runApp(const ProviderScope(child: AgileSimMobileApp()));
}

class AgileSimMobileApp extends ConsumerWidget {
  const AgileSimMobileApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsControllerProvider);

    return MaterialApp(
      title: 'Agile Sprint Master',
      debugShowCheckedModeBanner: false,
      themeMode: settings.themeMode,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      home: const SplashGate(),
    );
  }
}
