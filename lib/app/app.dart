import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/app_theme.dart';
import '../features/profile/profile_controller.dart';
import '../features/startup/startup_gate.dart';
import 'router.dart';

class BeakstormRunApp extends ConsumerWidget {
  const BeakstormRunApp({super.key, this.skipStartupGate = false});

  /// Gray-flow boot already showed the launch screen and finished the
  /// startup tasks. Skip the gate so organic users are not shown it twice.
  final bool skipStartupGate;

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
      builder: (context, child) {
        final page = child ?? const SizedBox.shrink();
        if (skipStartupGate) return page;
        return StartupGate(builder: (context) => page);
      },
    );
  }
}
