import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_dimens.dart';
import '../theme/app_theme.dart';

@immutable
class DockItem {
  const DockItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// The app's primary navigation.
///
/// A floating frosted capsule rather than a full-width tab bar: it sits within
/// thumb reach, keeps the artwork visible behind it, and the selected item
/// widens to reveal its label so only one caption is ever on screen.
class FeatherDock extends StatelessWidget {
  const FeatherDock({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onSelect,
  });

  final List<DockItem> items;
  final int currentIndex;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Insets.xl,
        0,
        Insets.xl,
        Layout.dockBottomInset + MediaQuery.paddingOf(context).bottom * 0.4,
      ),
      // heightFactor keeps the dock shrink-wrapped: Scaffold hands its bottom
      // bar loose constraints, and a plain Center would stretch to fill them.
      child: Align(
        alignment: Alignment.bottomCenter,
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: Layout.maxContentWidth),
          child: ClipRRect(
            borderRadius: Corners.pillRadius,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: Container(
                height: Layout.dockHeight,
                padding: const EdgeInsets.symmetric(horizontal: Insets.sm),
                decoration: BoxDecoration(
                  color: colors.canvasElevated.withValues(alpha: 0.86),
                  borderRadius: Corners.pillRadius,
                  border: Border.all(color: colors.borderStrong),
                  boxShadow: [
                    BoxShadow(
                      color: colors.shadow,
                      blurRadius: 28,
                      offset: const Offset(0, 12),
                      spreadRadius: -10,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (var i = 0; i < items.length; i++)
                      _DockButton(
                        item: items[i],
                        selected: i == currentIndex,
                        onTap: () {
                          if (i == currentIndex) return;
                          HapticFeedback.selectionClick();
                          onSelect(i);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DockButton extends StatelessWidget {
  const _DockButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final DockItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: Motion.fast,
          curve: Motion.enter,
          height: 46,
          padding: EdgeInsets.symmetric(horizontal: selected ? 16 : 14),
          decoration: BoxDecoration(
            gradient: selected ? colors.accentSweep : null,
            borderRadius: Corners.pillRadius,
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: colors.accent.withValues(alpha: 0.3),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                      spreadRadius: -6,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                item.icon,
                size: 21,
                color: selected ? colors.onAccent : colors.textMuted,
              ),
              // The label only exists on the selected item, so the dock stays
              // uncluttered and the current section is unmistakable.
              ClipRect(
                child: AnimatedAlign(
                  duration: Motion.fast,
                  curve: Motion.enter,
                  alignment: Alignment.centerLeft,
                  widthFactor: selected ? 1 : 0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: Insets.sm),
                    child: Text(
                      item.label,
                      maxLines: 1,
                      style: context.text.labelMedium?.copyWith(
                        color: colors.onAccent,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
