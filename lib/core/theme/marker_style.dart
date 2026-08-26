import 'package:flutter/material.dart';

import '../../domain/stage_marker.dart';
import '../../domain/tempo.dart';
import '../assets/app_images.dart';
import 'app_colors.dart';

/// Where a stage sits relative to the run, which decides how its artwork looks.
enum MarkerState { pending, active, passed }

/// Presentation for the domain enums.
///
/// Kept out of `lib/domain` so the model stays free of Flutter and the artwork
/// can be re-mapped without touching business rules.
extension TempoStyle on Tempo {
  Color color(AppColors colors) => switch (this) {
    Tempo.walk => colors.walk,
    Tempo.easyRun => colors.easyRun,
    Tempo.run => colors.run,
    Tempo.fastRun => colors.fastRun,
    Tempo.recovery => colors.recovery,
    Tempo.stop => colors.stop,
  };

  /// The moulded badge, used wherever there is room to show it.
  String get badge => switch (this) {
    Tempo.walk => AppImages.tempoWalk,
    Tempo.easyRun => AppImages.tempoEasyRun,
    Tempo.run => AppImages.tempoRun,
    Tempo.fastRun => AppImages.tempoFastRun,
    Tempo.recovery => AppImages.featherCream,
    Tempo.stop => AppImages.checkpointPending,
  };

  /// Flat fallback for dense rows where a 3D badge would be illegible.
  IconData get icon => switch (this) {
    Tempo.walk => Icons.directions_walk_rounded,
    Tempo.easyRun => Icons.directions_run_rounded,
    Tempo.run => Icons.local_fire_department_rounded,
    Tempo.fastRun => Icons.bolt_rounded,
    Tempo.recovery => Icons.air_rounded,
    Tempo.stop => Icons.pause_rounded,
  };

  /// Relative effort, used for bar heights on the route strip.
  double get intensity => switch (this) {
    Tempo.stop => 0.16,
    Tempo.recovery => 0.32,
    Tempo.walk => 0.46,
    Tempo.easyRun => 0.64,
    Tempo.run => 0.82,
    Tempo.fastRun => 1,
  };
}

extension StageMarkerStyle on StageMarker {
  String? image(MarkerState state) => switch (this) {
    StageMarker.none => null,
    StageMarker.checkpoint => switch (state) {
      MarkerState.pending => AppImages.eggPending,
      MarkerState.active => AppImages.eggActive,
      MarkerState.passed => AppImages.eggPassed,
    },
    StageMarker.tempoChange => switch (state) {
      MarkerState.pending => AppImages.coinPending,
      MarkerState.active => AppImages.coinActive,
      MarkerState.passed => AppImages.coinPassed,
    },
    StageMarker.recovery => switch (state) {
      MarkerState.pending => AppImages.featherLight,
      MarkerState.active => AppImages.featherGold,
      MarkerState.passed => AppImages.featherCream,
    },
  };

  IconData get icon => switch (this) {
    StageMarker.none => Icons.remove_rounded,
    StageMarker.checkpoint => Icons.egg_outlined,
    StageMarker.tempoChange => Icons.change_circle_outlined,
    StageMarker.recovery => Icons.air_rounded,
  };
}

/// Node artwork for a position on the route spine.
String stageNodeImage(MarkerState state, {required bool isFinish}) {
  if (isFinish) return AppImages.checkpointFinish;

  return switch (state) {
    MarkerState.pending => AppImages.checkpointPending,
    MarkerState.active => AppImages.checkpointActive,
    MarkerState.passed => AppImages.checkpointDone,
  };
}
