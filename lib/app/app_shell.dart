import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_dimens.dart';
import '../core/widgets/feather_dock.dart';

/// Frame around the main sections: content runs full height behind a floating
/// dock, so the artwork backdrops are never cut off by a solid bar.
class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _items = [
    DockItem(icon: Icons.home_rounded, label: 'Home'),
    DockItem(icon: Icons.route_rounded, label: 'Routes'),
    DockItem(icon: Icons.insights_rounded, label: 'Activity'),
    DockItem(icon: Icons.person_rounded, label: 'You'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: shell,
      bottomNavigationBar: FeatherDock(
        items: _items,
        currentIndex: shell.currentIndex,
        onSelect: (index) => shell.goBranch(
          index,
          // Tapping the active tab again returns it to its first screen.
          initialLocation: index == shell.currentIndex,
        ),
      ),
    );
  }
}

/// Bottom padding that keeps scrollable content clear of the floating dock.
double dockClearance(BuildContext context) =>
    Layout.dockHeight +
    Layout.dockBottomInset +
    MediaQuery.paddingOf(context).bottom * 0.4 +
    Insets.lg;
