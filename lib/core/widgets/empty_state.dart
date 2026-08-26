import 'package:flutter/material.dart';

import '../assets/app_images.dart';
import '../theme/app_dimens.dart';
import '../theme/app_theme.dart';
import 'beak_button.dart';

/// Shown where a list has nothing in it yet.
///
/// Always paired with the action that fills it, so an empty screen still tells
/// the user what to do next.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.image = AppImages.illustrationEmpty,
    this.actionLabel,
    this.onAction,
    this.compact = false,
  });

  final String title;
  final String message;
  final String image;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          image,
          height: compact ? 96 : 148,
          filterQuality: FilterQuality.medium,
        ),
        const SizedBox(height: Insets.lg),
        Text(
          title,
          textAlign: TextAlign.center,
          style: context.text.titleMedium,
        ),
        const SizedBox(height: Insets.sm),
        Text(
          message,
          textAlign: TextAlign.center,
          style: context.text.bodyMedium?.copyWith(color: colors.textSecondary),
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: Insets.xl),
          BeakButton(
            label: actionLabel!,
            onPressed: onAction,
            icon: Icons.add_rounded,
            expand: false,
          ),
        ],
      ],
    );
  }
}
