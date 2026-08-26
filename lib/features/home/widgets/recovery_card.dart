import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/beak_card.dart';
import '../../../data/session_repository.dart';
import '../../../domain/recovery_advisor.dart';

/// One line on how today should be approached, read from the runner's own
/// recent sessions and diary ratings.
class RecoveryCard extends ConsumerWidget {
  const RecoveryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final advice = ref.watch(recoveryAdviceProvider).value;
    if (advice == null) return const SizedBox.shrink();

    final colors = context.colors;
    final tint = switch (advice.level) {
      RecoveryLevel.fresh => colors.walk,
      RecoveryLevel.normal => colors.accent,
      RecoveryLevel.caution => colors.fastRun,
      RecoveryLevel.rest => colors.recovery,
    };

    final icon = switch (advice.level) {
      RecoveryLevel.fresh => Icons.bolt_rounded,
      RecoveryLevel.normal => Icons.check_circle_outline_rounded,
      RecoveryLevel.caution => Icons.trending_down_rounded,
      RecoveryLevel.rest => Icons.self_improvement_rounded,
    };

    final headline = switch (advice.level) {
      RecoveryLevel.fresh => 'Fresh legs',
      RecoveryLevel.normal => 'Good to go',
      RecoveryLevel.caution => 'Take it easy',
      RecoveryLevel.rest => 'Time to recover',
    };

    return BeakCard(
      padding: const EdgeInsets.symmetric(
        horizontal: Insets.lg,
        vertical: Insets.md,
      ),
      child: Row(
        children: [
          Container(
            height: 38,
            width: 38,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.16),
              borderRadius: Corners.cardRadius,
            ),
            child: Icon(icon, size: 20, color: tint),
          ),
          const SizedBox(width: Insets.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(headline, style: context.text.titleSmall),
                const SizedBox(height: 2),
                Text(
                  advice.message,
                  style: context.text.bodySmall?.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
