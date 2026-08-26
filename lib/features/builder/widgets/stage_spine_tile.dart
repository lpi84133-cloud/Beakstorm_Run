import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/marker_style.dart';
import '../../../core/utils/duration_format.dart';
import '../../../domain/stage_marker.dart';
import '../../../domain/workout_stage.dart';

enum BlockPosition { none, first, middle, last }

/// One stage on the route spine.
///
/// The rail on the left is the road: a continuous line with a node per stage,
/// which is what makes a route readable as a shape rather than a list of rows.
class StageSpineTile extends StatelessWidget {
  const StageSpineTile({
    super.key,
    required this.stage,
    required this.index,
    required this.isFirst,
    required this.isLast,
    this.onTap,
    this.trailing,
    this.state = MarkerState.pending,
    this.block = BlockPosition.none,
    this.repeatTimes,
    this.onRepeatTap,
    this.selected,
  });

  final WorkoutStage stage;
  final int index;
  final bool isFirst;
  final bool isLast;
  final VoidCallback? onTap;
  final Widget? trailing;
  final MarkerState state;

  /// Where this stage sits inside a repeated block, which decides whether the
  /// bracket opens, continues or closes here.
  final BlockPosition block;
  final int? repeatTimes;
  final VoidCallback? onRepeatTap;

  /// Non-null while the builder is picking stages for a new block.
  final bool? selected;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tint = stage.tempo.color(colors);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (block == BlockPosition.first && repeatTimes != null)
          Padding(
            padding: const EdgeInsets.only(left: 48, bottom: Insets.sm),
            child: _RepeatChip(times: repeatTimes!, onTap: onRepeatTap),
          ),
        _body(context, colors, tint),
      ],
    );
  }

  Widget _body(BuildContext context, AppColors colors, Color tint) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 48,
            child: _Rail(
              isFirst: isFirst,
              isLast: isLast,
              tint: tint,
              block: block,
              accent: colors.accent,
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: Insets.md),
              child: Material(
                color: colors.surface,
                borderRadius: Corners.cardRadius,
                child: InkWell(
                  onTap: onTap,
                  borderRadius: Corners.cardRadius,
                  splashColor: colors.accentSoft,
                  child: Container(
                    padding: const EdgeInsets.all(Insets.md),
                    decoration: BoxDecoration(
                      borderRadius: Corners.cardRadius,
                      border: Border.all(
                        color: selected == true
                            ? colors.accent
                            : state == MarkerState.active
                            ? tint
                            : colors.border,
                        width: selected == true || state == MarkerState.active
                            ? 1.6
                            : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        if (selected != null) ...[
                          Icon(
                            selected!
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 22,
                            color: selected!
                                ? colors.accent
                                : colors.textMuted,
                          ),
                          const SizedBox(width: Insets.md),
                        ],
                        Container(
                          height: 38,
                          width: 38,
                          decoration: BoxDecoration(
                            color: tint.withValues(alpha: 0.16),
                            borderRadius: Corners.cardRadius,
                          ),
                          child: Icon(stage.tempo.icon, size: 19, color: tint),
                        ),
                        const SizedBox(width: Insets.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                stage.tempo.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.titleSmall,
                              ),
                              Text(
                                stage.note ?? stage.marker.summary,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: context.text.bodySmall?.copyWith(
                                  color: colors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: Insets.sm),
                        Text(
                          stage.duration.clock,
                          style: context.text.titleMedium?.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        if (trailing != null) ...[
                          const SizedBox(width: Insets.xs),
                          trailing!,
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

extension on StageMarker {
  /// Fallback caption when the stage has no note of its own.
  String get summary => this == StageMarker.none ? 'No marker' : label;
}

/// Chip that opens the block's repeat count for editing.
class _RepeatChip extends StatelessWidget {
  const _RepeatChip({required this.times, this.onTap});

  final int times;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: Insets.md,
          vertical: Insets.xs,
        ),
        decoration: BoxDecoration(
          color: colors.accentSoft,
          borderRadius: Corners.pillRadius,
          border: Border.all(color: colors.accent.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.repeat_rounded, size: 14, color: colors.accent),
            const SizedBox(width: Insets.xs + 2),
            Text(
              'Repeat block  ×$times',
              style: context.text.labelMedium?.copyWith(color: colors.accent),
            ),
          ],
        ),
      ),
    );
  }
}

class _Rail extends StatelessWidget {
  const _Rail({
    required this.isFirst,
    required this.isLast,
    required this.tint,
    required this.block,
    required this.accent,
  });

  final bool isFirst;
  final bool isLast;
  final Color tint;
  final BlockPosition block;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Positioned(
          top: isFirst ? 26 : 0,
          bottom: isLast ? 12 : 0,
          child: Container(width: 3, color: colors.route),
        ),
        // Bracket down the left edge marking the stages that repeat together.
        if (block != BlockPosition.none)
          Positioned(
            left: 2,
            top: block == BlockPosition.first ? 6 : 0,
            bottom: block == BlockPosition.last ? 18 : 0,
            child: Container(
              width: 8,
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: accent, width: 2),
                  top: block == BlockPosition.first
                      ? BorderSide(color: accent, width: 2)
                      : BorderSide.none,
                  bottom: block == BlockPosition.last
                      ? BorderSide(color: accent, width: 2)
                      : BorderSide.none,
                ),
              ),
            ),
          ),
        Positioned(
          top: 18,
          child: Container(
            height: 16,
            width: 16,
            decoration: BoxDecoration(
              color: tint,
              shape: BoxShape.circle,
              border: Border.all(color: colors.canvas, width: 3),
            ),
          ),
        ),
      ],
    );
  }
}
