import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../features/profile/profile_controller.dart';
import '../features/startup/startup_gate.dart';
import 'router.dart';

class BeakstormRunApp extends ConsumerWidget {
  const BeakstormRunApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Beakstorm Run',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ref.watch(
        profileControllerProvider.select((profile) => profile.themeMode),
      ),
      routerConfig: ref.watch(routerProvider),
      // The gate wraps the navigator, so the launch screen covers the whole app
      // until initialisation genuinely finishes.
      builder: (context, child) =>
          StartupGate(builder: (context) => child ?? const SizedBox.shrink()),
    );
  }
}
