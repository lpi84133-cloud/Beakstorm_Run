import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import 'dash_boot.dart';
import 'squall_coordinator.dart';

class SquallShell extends StatelessWidget {
  const SquallShell({super.key, required this.coordinator});

  final SquallCoordinator coordinator;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Beakstorm Run',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      home: DashBoot(coordinator: coordinator),
    );
  }
}
