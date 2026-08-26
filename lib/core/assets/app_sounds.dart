/// Short functional cues. Paths are relative to the assets root because
/// audioplayers' AssetSource prepends `assets/` itself.
abstract final class AppSounds {
  static const _dir = 'sounds';

  // Interface.
  static const buttonTap = '$_dir/button_tap.mp3';
  static const menuOpen = '$_dir/menu_open.mp3';
  static const menuClose = '$_dir/menu_close.mp3';
  static const saved = '$_dir/successful_save.mp3';
  static const error = '$_dir/error_action.mp3';

  // Route builder.
  static const stageAdded = '$_dir/route_segment_added.mp3';
  static const stageRemoved = '$_dir/route_segment_removed.mp3';

  // Session.
  static const workoutStart = '$_dir/workout_start.mp3';
  static const stageChange = '$_dir/stage_change.mp3';
  static const timerWarning = '$_dir/timer_warning.mp3';
  static const checkpointReached = '$_dir/checkpoint_reached.mp3';
  static const pause = '$_dir/pause_workout.mp3';
  static const resume = '$_dir/resume_workout.mp3';
  static const workoutComplete = '$_dir/workout_complete.mp3';

  /// Cues loaded into the player pool during startup so the first stage change
  /// is not delayed by a cold decode.
  static const warmUpOnStartup = <String>[
    buttonTap,
    stageChange,
    timerWarning,
    workoutComplete,
  ];
}
