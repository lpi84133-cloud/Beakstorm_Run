import 'package:flutter/material.dart';

import '../../domain/stage_marker.dart';
import '../../domain/workout_stage.dart';
import '../theme/app_dimens.dart';
import '../theme/app_theme.dart';
import '../theme/marker_style.dart';

/// A route seen at a glance: one column per stage, width proportional to its
/// duration and height to its effort.
///
/// This is the shape a saved route is recognised by, so it appears on cards,
/// in previews and above the running timer rather than a generic list.
class TempoStrip extends StatelessWidget {
  const TempoStrip({
    super.key,
    required this.stages,
    this.height = 46,
    this.activeIndex,
    this.showMarkers = true,
  });

  final List<WorkoutStage> stages;
  final double height;

  /// When set, stages before it are dimmed and this one is highlighted.
  final int? activeIndex;
  final bool showMarkers;

  @override
  Widget build(BuildContext context) {
    if (stages.isEmpty) return SizedBox(height: height);

    final colors = context.colors;

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < stages.length; i++)
            Expanded(
              // Very short stages would otherwise collapse to nothing, so the
              // flex has a floor.
              flex: stages[i].duration.inSeconds.clamp(15, 1 << 20),
              child: Padding(
                padding: EdgeInsets.only(right: i == stages.length - 1 ? 0 : 2),
                child: _StageColumn(
                  stage: stages[i],
                  height: height,
                  showMarker: showMarkers,
                  state: activeIndex == null
                      ? MarkerState.pending
                      : i < activeIndex!
                      ? MarkerState.passed
                      : i == activeIndex!
                      ? MarkerState.active
                      : MarkerState.pending,
                  baseline: colors.border,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _StageColumn extends StatelessWidget {
  const _StageColumn({
    required this.stage,
    required this.height,
    required this.state,
    required this.showMarker,
    required this.baseline,
  });

  final WorkoutStage stage;
  final double height;
  final MarkerState state;
  final bool showMarker;
  final Color baseline;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = stage.tempo.color(colors);

    final opacity = switch (state) {
      MarkerState.passed => 0.4,
      MarkerState.pending => 0.85,
      MarkerState.active => 1.0,
    };

    final marker = showMarker && stage.marker != StageMarker.none
        ? stage.marker.image(state)
        : null;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        FractionallySizedBox(
          heightFactor: stage.tempo.intensity,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  color.withValues(alpha: opacity),
                  color.withValues(alpha: opacity * 0.62),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Corners.xs,
                bottom: Radius.circular(3),
              ),
              border: state == MarkerState.active
                  ? Border.all(color: colors.textPrimary, width: 1.4)
                  : null,
            ),
            child: const SizedBox.expand(),
          ),
        ),
        if (marker != null)
          Positioned(
            top: 0,
            child: Image.asset(
              marker,
              height: height * 0.34,
              filterQuality: FilterQuality.medium,
            ),
          ),
      ],
    );
  }
}
