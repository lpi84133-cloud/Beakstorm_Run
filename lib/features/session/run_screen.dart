import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../core/assets/app_images.dart';
import '../../core/assets/app_sounds.dart';
import '../../core/audio/audio_cue_service.dart';
import '../../core/audio/cadence_metronome.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/marker_style.dart';
import '../../core/utils/duration_format.dart';
import '../../core/widgets/beak_button.dart';
import '../../core/widgets/beak_card.dart';
import '../../core/widgets/page_backdrop.dart';
import '../../core/widgets/tempo_strip.dart';
import '../../data/plan_repository.dart';
import '../../data/session_repository.dart';
import '../../data/workout_repository.dart';
import '../../domain/session.dart';
import '../../domain/stage_marker.dart';
import '../../domain/tempo.dart';
import '../../domain/workout.dart';
import '../../domain/workout_stage.dart';
import '../../domain/workout_validation.dart';
import '../profile/profile_controller.dart';

/// Runs a saved route: one stage at a time, counting down, with the whole route
/// visible above the timer.
///
/// The clock is driven by wall time rather than by counting ticks, so a stalled
/// frame or a backgrounded app can never make the workout drift.
class RunScreen extends ConsumerStatefulWidget {
  const RunScreen({super.key, required this.workoutId, this.planSessionKey});

  final String workoutId;

  /// Set when the run comes from the training plan. The route is generated on
  /// the spot and the session is ticked off the plan when it finishes.
  final String? planSessionKey;

  @override
  ConsumerState<RunScreen> createState() => _RunScreenState();
}

class _RunScreenState extends ConsumerState<RunScreen> {
  Workout? _workout;

  /// The route with every repeated block already unrolled: what the timer walks
  /// through, and what mid-run adjustments are applied to.
  List<WorkoutStage> _stages = [];

  Timer? _timer;

  int _index = 0;
  DateTime _stageStartedAt = DateTime.now();
  DateTime _sessionStartedAt = DateTime.now();
  Duration _elapsedInStage = Duration.zero;
  Duration _completedBefore = Duration.zero;

  /// Seconds actually spent at each tempo, so the summary reflects the run and
  /// not the plan.
  final Map<Tempo, Duration> _timePerTempo = {};

  bool _paused = false;
  bool _finished = false;
  bool _warned = false;

  /// Muting is per run, not a saved preference: the tick is welcome on a track
  /// and unwelcome on a quiet street.
  bool _metronomeMuted = false;

  /// True from the moment the route is loaded until the 3-2-1 finishes, so
  /// the clock and every sensor stay off until the runner is actually moving.
  bool _counting = true;
  static const _countdownFrom = 3;
  int _count = _countdownFrom;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _countdownTimer?.cancel();
    ref.read(cadenceMetronomeProvider).stop();
    WakelockPlus.disable();
    super.dispose();
  }

  int? get _targetCadence =>
      _stages.isEmpty || _metronomeMuted ? null : _stages[_index].cadence;

  /// Keeps the tick in step with the stage on screen: running at the stage's
  /// cadence, silent when the stage has none, paused with the timer.
  void _syncMetronome() {
    final metronome = ref.read(cadenceMetronomeProvider);
    final profile = ref.read(profileControllerProvider);

    metronome
      ..soundEnabled = profile.soundEnabled
      ..hapticsEnabled = profile.hapticsEnabled;

    final target = _targetCadence;

    if (target == null || _paused || _finished) {
      metronome.stop();
      return;
    }

    metronome.start(target);
  }

  Future<void> _load() async {
    final workout = await _resolveWorkout();

    if (!mounted || workout == null) return;

    setState(() {
      _workout = workout;
      _stages = workout.runStages;
    });

    _startCountdown();
  }

  /// Three ticks to get in position before the clock starts. Runs off a wall
  /// clock like everything else here, so a dropped frame cannot stall it.
  void _startCountdown() {
    unawaited(ref.read(audioCueServiceProvider).play(AppSounds.buttonTap));
    HapticFeedback.mediumImpact();

    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _countdownTick(),
    );
  }

  void _countdownTick() {
    if (!mounted) return;

    if (_count <= 1) {
      _countdownTimer?.cancel();
      _beginRun();
      return;
    }

    setState(() => _count--);
    HapticFeedback.mediumImpact();
    unawaited(ref.read(audioCueServiceProvider).play(AppSounds.buttonTap));
  }

  /// Cancels the countdown and leaves the screen. Nothing has started yet, so
  /// there is no session to save.
  void _cancelCountdown() {
    _countdownTimer?.cancel();
    if (mounted) Navigator.of(context).maybePop();
  }

  void _beginRun() {
    if (!mounted) return;

    final now = DateTime.now();

    setState(() {
      _counting = false;
      _sessionStartedAt = now;
      _stageStartedAt = now;
    });

    // The screen has to stay awake: the timer is the whole point of the run.
    unawaited(WakelockPlus.enable());
    unawaited(ref.read(audioCueServiceProvider).play(AppSounds.workoutStart));

    _timer = Timer.periodic(const Duration(milliseconds: 200), (_) => _tick());
    _syncMetronome();
  }

  Future<Workout?> _resolveWorkout() async {
    final planKey = widget.planSessionKey;
    if (planKey == null) {
      return ref.read(workoutRepositoryProvider).findById(widget.workoutId);
    }

    final plan = await ref.read(planRepositoryProvider).active();
    final session = plan?.sessions
        .where((item) => item.key == planKey)
        .firstOrNull;

    return session?.toWorkout(DateTime.now());
  }

  Duration get _stageDuration => _stages[_index].duration;

  Duration get _remaining {
    final left = _stageDuration - _elapsedInStage;
    return left.isNegative ? Duration.zero : left;
  }

  void _tick() {
    if (_paused || _finished || _workout == null) return;

    setState(() {
      _elapsedInStage = DateTime.now().difference(_stageStartedAt);
    });

    final left = _remaining;

    if (left.inSeconds <= 3 && left > Duration.zero && !_warned) {
      _warned = true;
      unawaited(ref.read(audioCueServiceProvider).play(AppSounds.timerWarning));
    }

    if (left == Duration.zero) _advance();
  }

  void _recordStage() {
    final stage = _stages[_index];
    final spent = _elapsedInStage > stage.duration
        ? stage.duration
        : _elapsedInStage;

    _timePerTempo[stage.tempo] =
        (_timePerTempo[stage.tempo] ?? Duration.zero) + spent;
    _completedBefore += spent;
  }

  void _advance() {
    _recordStage();

    if (_index >= _stages.length - 1) {
      _finish(completed: true);
      return;
    }

    final audio = ref.read(audioCueServiceProvider);
    final nextMarker = _stages[_index + 1].marker;

    unawaited(
      audio.play(
        nextMarker == StageMarker.none
            ? AppSounds.stageChange
            : AppSounds.checkpointReached,
      ),
    );
    HapticFeedback.mediumImpact();

    setState(() {
      _index++;
      _warned = false;
      _stageStartedAt = DateTime.now();
      _elapsedInStage = Duration.zero;
    });

    _syncMetronome();
  }

  /// Stretches or trims the stage that is running.
  ///
  /// A plan meets a hill, a crossing or a bad day; being able to bend the
  /// current stage keeps the route usable instead of something to abandon.
  void _adjustStage(int seconds) {
    final stage = _stages[_index];
    final next = stage.duration + Duration(seconds: seconds);

    // Never shorten past what is already done, and keep a stage inside the same
    // bounds the builder enforces.
    if (next < kMinStageDuration ||
        next > kMaxStageDuration ||
        next <= _elapsedInStage) {
      HapticFeedback.heavyImpact();
      return;
    }

    HapticFeedback.selectionClick();

    setState(() {
      _stages = List.of(_stages)..[_index] = stage.copyWith(duration: next);
      _warned = false;
    });
  }

  /// Goes back to the previous stage, undoing the time it contributed so the
  /// summary still matches what was actually done.
  void _stepBack() {
    if (_index == 0) {
      _restartStage();
      return;
    }

    HapticFeedback.mediumImpact();

    setState(() {
      _index--;
      final previous = _stages[_index];
      final credited = _timePerTempo[previous.tempo] ?? Duration.zero;
      final refund = credited < previous.duration
          ? credited
          : previous.duration;

      _timePerTempo[previous.tempo] = credited - refund;
      _completedBefore -= refund;

      _warned = false;
      _elapsedInStage = Duration.zero;
      _stageStartedAt = DateTime.now();
    });

    _syncMetronome();
  }

  void _restartStage() {
    HapticFeedback.selectionClick();

    setState(() {
      _warned = false;
      _elapsedInStage = Duration.zero;
      _stageStartedAt = DateTime.now();
    });
  }

  void _togglePause() {
    final audio = ref.read(audioCueServiceProvider);

    setState(() {
      if (_paused) {
        // Resuming rebases the stage start so the pause costs no stage time.
        _stageStartedAt = DateTime.now().subtract(_elapsedInStage);
        _paused = false;
        unawaited(audio.play(AppSounds.resume));
      } else {
        _paused = true;
        unawaited(audio.play(AppSounds.pause));
      }
    });

    _syncMetronome();
  }

  Future<void> _finish({required bool completed}) async {
    if (_finished) return;

    if (!completed) _recordStage();

    _finished = true;
    _timer?.cancel();
    ref.read(cadenceMetronomeProvider).stop();
    await WakelockPlus.disable();

    final workout = _workout!;
    final now = DateTime.now();

    unawaited(
      ref
          .read(audioCueServiceProvider)
          .play(completed ? AppSounds.workoutComplete : AppSounds.saved),
    );

    final session = RunSession(
      id: 0,
      workoutId: workout.id,
      workoutName: workout.name,
      templateKey: workout.templateKey,
      startedAt: _sessionStartedAt,
      endedAt: now,
      plannedDuration: workout.totalDuration,
      actualDuration: _completedBefore,
      completedStages: completed ? _stages.length : _index + 1,
      totalStages: _stages.length,
      finishedRoute: completed,
      timePerTempo: Map.of(_timePerTempo),
    );

    final savedId = await ref.read(sessionRepositoryProvider).add(session);

    // A plan session counts as done only when the route was seen through, so
    // the schedule stays an honest record of what was actually run.
    final planKey = widget.planSessionKey;
    if (completed && planKey != null) {
      await ref.read(planRepositoryProvider).markDone(planKey);
    }

    if (!mounted) return;

    setState(() {});
    await _showSummary(session.copyWith(id: savedId));
  }

  Future<void> _showSummary(RunSession session) async {
    await showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      useSafeArea: true,
      // The diary makes this sheet taller than one screen fraction can hold,
      // so it is allowed to grow instead of clipping the note field.
      isScrollControlled: true,
      backgroundColor: context.colors.canvasElevated,
      shape: const RoundedRectangleBorder(borderRadius: Corners.sheetRadius),
      builder: (context) => _Summary(session: session),
    );

    if (mounted) context.pop();
  }

  Future<bool> _confirmStop() async {
    final wasPaused = _paused;
    if (!wasPaused) _togglePause();

    final stop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End this run?'),
        content: const Text(
          'What you have done so far will be saved to your history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep going'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('End and save'),
          ),
        ],
      ),
    );

    if (stop != true) {
      if (!wasPaused && mounted) _togglePause();
      return false;
    }

    await _finish(completed: false);
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final workout = _workout;

    if (workout == null) {
      return Scaffold(
        backgroundColor: colors.canvas,
        body: const Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    final stage = _stages[_index];
    final tint = stage.tempo.color(colors);
    final progress = _stageDuration.inMilliseconds == 0
        ? 1.0
        : (_elapsedInStage.inMilliseconds / _stageDuration.inMilliseconds)
              .clamp(0.0, 1.0);

    return PopScope(
      canPop: _finished || _counting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmStop();
      },
      child: Scaffold(
        backgroundColor: colors.canvas,
        body: PageBackdrop(
          image: AppImages.nightRoute,
          height: 420,
          opacity: _paused ? 0.25 : 0.5,
          child: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: Layout.maxContentWidth,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        Insets.xl,
                        Insets.sm,
                        Insets.xl,
                        Insets.xl,
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              IconButton(
                                onPressed: _confirmStop,
                                icon: const Icon(Icons.close_rounded),
                              ),
                              Expanded(
                                child: Text(
                                  workout.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: context.text.titleSmall,
                                ),
                              ),
                              if (stage.cadence == null)
                                const SizedBox(width: 48)
                              else
                                _CadenceToggle(
                                  cadence: stage.cadence!,
                                  muted: _metronomeMuted,
                                  onTap: () {
                                    setState(
                                      () => _metronomeMuted = !_metronomeMuted,
                                    );
                                    _syncMetronome();
                                  },
                                ),
                            ],
                          ),
                          const SizedBox(height: Insets.lg),
                          TempoStrip(
                            stages: _stages,
                            height: 56,
                            activeIndex: _index,
                          ),
                          const Spacer(),
                          Text(
                            'Stage ${_index + 1} of ${_stages.length}',
                            style: context.text.labelMedium?.copyWith(
                              color: colors.textMuted,
                            ),
                          ),
                          const SizedBox(height: Insets.sm),
                          Text(
                            stage.tempo.label,
                            style: context.text.displaySmall?.copyWith(
                              color: tint,
                            ),
                          ),
                          if (stage.note != null)
                            Text(
                              stage.note!,
                              style: context.text.bodyMedium?.copyWith(
                                color: colors.textSecondary,
                              ),
                            ),
                          const SizedBox(height: Insets.xl),
                          _Countdown(
                            remaining: _remaining,
                            progress: progress,
                            tint: tint,
                            paused: _paused,
                          ),
                          const SizedBox(height: Insets.xl),
                          _NextUp(stages: _stages, index: _index),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _LiveControl(
                                icon: Icons.remove_rounded,
                                label: '30 sec',
                                onTap: () => _adjustStage(-30),
                              ),
                              const SizedBox(width: Insets.md),
                              _LiveControl(
                                icon: _index == 0
                                    ? Icons.replay_rounded
                                    : Icons.skip_previous_rounded,
                                label: _index == 0 ? 'Restart' : 'Back',
                                onTap: _stepBack,
                              ),
                              const SizedBox(width: Insets.md),
                              _LiveControl(
                                icon: Icons.add_rounded,
                                label: '30 sec',
                                onTap: () => _adjustStage(30),
                              ),
                            ],
                          ),
                          const SizedBox(height: Insets.lg),
                          Row(
                            children: [
                              Expanded(
                                child: BeakButton(
                                  label: _paused ? 'Resume' : 'Pause',
                                  icon: _paused
                                      ? Icons.play_arrow_rounded
                                      : Icons.pause_rounded,
                                  variant: _paused
                                      ? BeakButtonVariant.primary
                                      : BeakButtonVariant.secondary,
                                  onPressed: _togglePause,
                                ),
                              ),
                              const SizedBox(width: Insets.md),
                              Expanded(
                                child: BeakButton(
                                  label: 'Skip stage',
                                  icon: Icons.skip_next_rounded,
                                  variant: BeakButtonVariant.secondary,
                                  onPressed: _advance,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_counting)
                  Positioned.fill(
                    child: _CountdownOverlay(
                      workoutName: workout.name,
                      count: _count,
                      onCancel: _cancelCountdown,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Shows the stage's step rhythm and silences it for the rest of the run.
class _CadenceToggle extends StatelessWidget {
  const _CadenceToggle({
    required this.cadence,
    required this.muted,
    required this.onTap,
  });

  final int cadence;
  final bool muted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      label: muted ? 'Cadence muted' : 'Cadence $cadence steps per minute',
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Insets.md,
            vertical: Insets.xs + 2,
          ),
          decoration: BoxDecoration(
            color: muted ? colors.surface : colors.accentSoft,
            borderRadius: Corners.pillRadius,
            border: Border.all(
              color: muted
                  ? colors.border
                  : colors.accent.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                muted ? Icons.volume_off_rounded : Icons.graphic_eq_rounded,
                size: 15,
                color: muted ? colors.textMuted : colors.accent,
              ),
              const SizedBox(width: Insets.xs + 2),
              Text(
                '$cadence',
                style: context.text.labelMedium?.copyWith(
                  color: muted ? colors.textMuted : colors.accent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact control for bending the plan mid-run, sized for a tap while moving.
class _LiveControl extends StatelessWidget {
  const _LiveControl({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Semantics(
      button: true,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: Insets.lg,
            vertical: Insets.sm + 2,
          ),
          decoration: BoxDecoration(
            color: colors.surface.withValues(alpha: 0.7),
            borderRadius: Corners.pillRadius,
            border: Border.all(color: colors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: colors.textPrimary),
              const SizedBox(width: Insets.xs + 2),
              Text(
                label,
                style: context.text.labelMedium?.copyWith(
                  color: colors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Covers the run screen with a 3-2-1 count before the clock and every
/// sensor start. Cancelling here leaves no trace: nothing has been recorded
/// yet, so there is nothing to save.
class _CountdownOverlay extends StatelessWidget {
  const _CountdownOverlay({
    required this.workoutName,
    required this.count,
    required this.onCancel,
  });

  final String workoutName;
  final int count;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ColoredBox(
      color: colors.canvas.withValues(alpha: 0.94),
      child: Column(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(right: Insets.sm),
                child: IconButton(
                  onPressed: onCancel,
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    workoutName,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: context.text.titleSmall?.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
                  const SizedBox(height: Insets.xxl),
                  AnimatedSwitcher(
                    duration: Motion.fast,
                    switchInCurve: Motion.emphasized,
                    switchOutCurve: Motion.exit,
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Text(
                      '$count',
                      key: ValueKey(count),
                      style: context.text.displayLarge?.copyWith(
                        fontSize: 96,
                        color: colors.accent,
                      ),
                    ),
                  ),
                  const SizedBox(height: Insets.lg),
                  Text(
                    'Get ready',
                    style: context.text.labelMedium?.copyWith(
                      color: colors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: Insets.xxxl + MediaQuery.paddingOf(context).bottom),
        ],
      ),
    );
  }
}

class _Countdown extends StatelessWidget {
  const _Countdown({
    required this.remaining,
    required this.progress,
    required this.tint,
    required this.paused,
  });

  final Duration remaining;
  final double progress;
  final Color tint;
  final bool paused;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return SizedBox(
      height: 220,
      width: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox.expand(
            child: CircularProgressIndicator(
              value: 1 - progress,
              strokeWidth: 10,
              strokeCap: StrokeCap.round,
              backgroundColor: colors.surface,
              valueColor: AlwaysStoppedAnimation(tint),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                remaining.clock,
                style: context.text.displayMedium?.copyWith(
                  color: colors.textPrimary,
                ),
              ),
              if (paused)
                Text(
                  'Paused',
                  style: context.text.labelMedium?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NextUp extends StatelessWidget {
  const _NextUp({required this.stages, required this.index});

  final List<WorkoutStage> stages;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isLast = index >= stages.length - 1;

    if (isLast) {
      return Text(
        'Last stage',
        style: context.text.labelMedium?.copyWith(color: colors.textMuted),
      );
    }

    final next = stages[index + 1];

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Next  ',
          style: context.text.labelMedium?.copyWith(color: colors.textMuted),
        ),
        Icon(next.tempo.icon, size: 16, color: next.tempo.color(colors)),
        const SizedBox(width: Insets.xs),
        Text(
          '${next.tempo.label}  ·  ${next.duration.clock}',
          style: context.text.labelMedium?.copyWith(
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _Summary extends ConsumerStatefulWidget {
  const _Summary({required this.session});

  final RunSession session;

  @override
  ConsumerState<_Summary> createState() => _SummaryState();
}

class _SummaryState extends ConsumerState<_Summary> {
  int? _effort;
  final _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _done() async {
    final effort = _effort;
    final note = _noteController.text.trim();

    // Nothing to write if the runner left the diary blank, which keeps a
    // quick "Done" tap free of an empty database round trip.
    if (effort != null || note.isNotEmpty) {
      await ref
          .read(sessionRepositoryProvider)
          .updateDiary(widget.session.id, effort: effort, note: note);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final session = widget.session;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        Insets.xl,
        Insets.xl,
        Insets.xl,
        Insets.xl,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              session.finishedRoute
                  ? AppImages.illustrationComplete
                  : AppImages.chickenFinished,
              height: 112,
            ),
            const SizedBox(height: Insets.lg),
            Text(
              session.finishedRoute ? 'Route complete' : 'Run saved',
              style: context.text.headlineSmall,
            ),
            const SizedBox(height: Insets.sm),
            Text(
              '${session.completedStages} of ${session.totalStages} stages  ·  '
              '${session.actualDuration.compact}',
              style: context.text.bodyMedium?.copyWith(
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: Insets.xl),
            BeakCard(
              child: Column(
                children: [
                  for (final entry in session.timePerTempo.entries)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        children: [
                          Icon(
                            entry.key.icon,
                            size: 16,
                            color: entry.key.color(colors),
                          ),
                          const SizedBox(width: Insets.sm),
                          Expanded(
                            child: Text(
                              entry.key.label,
                              style: context.text.bodyMedium,
                            ),
                          ),
                          Text(
                            entry.value.compact,
                            style: context.text.labelMedium?.copyWith(
                              color: colors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: Insets.xl),
            _DiaryFields(
              effort: _effort,
              onEffortChanged: (value) => setState(() => _effort = value),
              noteController: _noteController,
            ),
            const SizedBox(height: Insets.xl),
            BeakButton(
              label: 'Done',
              icon: Icons.check_rounded,
              onPressed: _done,
            ),
          ],
        ),
      ),
    );
  }
}

/// A one-tap effort rating plus a free-text line, answered right after the
/// run while it is still fresh. Both are optional and neither is scored: this
/// is a private log, not a leaderboard.
class _DiaryFields extends StatelessWidget {
  const _DiaryFields({
    required this.effort,
    required this.onEffortChanged,
    required this.noteController,
  });

  final int? effort;
  final ValueChanged<int?> onEffortChanged;
  final TextEditingController noteController;

  static const _faces = [
    Icons.sentiment_very_satisfied_rounded,
    Icons.sentiment_satisfied_rounded,
    Icons.sentiment_neutral_rounded,
    Icons.sentiment_dissatisfied_rounded,
    Icons.sentiment_very_dissatisfied_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('How did it feel?', style: context.text.titleSmall),
        const SizedBox(height: Insets.md),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (var i = 0; i < _faces.length; i++)
              _EffortFace(
                icon: _faces[i],
                label: kEffortLabels[i],
                selected: effort == i + 1,
                onTap: () {
                  HapticFeedback.selectionClick();
                  onEffortChanged(effort == i + 1 ? null : i + 1);
                },
              ),
          ],
        ),
        const SizedBox(height: Insets.lg),
        TextField(
          controller: noteController,
          minLines: 1,
          maxLines: 3,
          maxLength: 200,
          decoration: InputDecoration(
            hintText: 'Anything worth remembering? Sleep, food, weather…',
            filled: false,
            counterText: '',
            border: OutlineInputBorder(
              borderRadius: Corners.cardRadius,
              borderSide: BorderSide(color: colors.border),
            ),
          ),
        ),
      ],
    );
  }
}

class _EffortFace extends StatelessWidget {
  const _EffortFace({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final tint = selected ? colors.accent : colors.textMuted;

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(Insets.sm),
              decoration: BoxDecoration(
                color: selected ? colors.accentSoft : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? colors.accent : colors.border,
                ),
              ),
              child: Icon(icon, color: tint, size: 26),
            ),
          ],
        ),
      ),
    );
  }
}
