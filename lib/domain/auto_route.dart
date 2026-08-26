import 'stage_marker.dart';
import 'tempo.dart';
import 'workout_stage.dart';

/// How hard the generated route should be.
enum RouteEffort {
  easy('Easy', 'Conversational the whole way', Tempo.easyRun),
  moderate('Moderate', 'Steady work with real recovery', Tempo.run),
  hard('Hard', 'Short, sharp efforts', Tempo.fastRun);

  const RouteEffort(this.label, this.description, this.workingTempo);

  final String label;
  final String description;
  final Tempo workingTempo;

  /// Length of one working stage in an interval route. Harder efforts are
  /// necessarily shorter.
  Duration get workLength => switch (this) {
    RouteEffort.easy => const Duration(minutes: 3),
    RouteEffort.moderate => const Duration(minutes: 2),
    RouteEffort.hard => const Duration(seconds: 45),
  };

  /// Step rhythm suggested for the working stages. Higher effort, quicker feet.
  int get cadence => switch (this) {
    RouteEffort.easy => 165,
    RouteEffort.moderate => 172,
    RouteEffort.hard => 180,
  };

  Duration get restLength => switch (this) {
    RouteEffort.easy => const Duration(seconds: 60),
    RouteEffort.moderate => const Duration(seconds: 90),
    RouteEffort.hard => const Duration(seconds: 75),
  };
}

/// A generated route, before it is given a name and saved.
class AutoRoute {
  const AutoRoute({required this.stages, required this.repeats});

  final List<WorkoutStage> stages;
  final Map<String, int> repeats;
}

/// Lays out a sensible session for the time available.
///
/// The shape follows how people actually train: walk in, do the work, walk out.
/// It is a starting point, not a prescription, and every stage stays editable.
AutoRoute buildAutoRoute({
  required Duration total,
  required RouteEffort effort,
  required bool intervals,
  required String Function() idFor,
}) {
  final totalSeconds = total.inSeconds.clamp(600, 7200);

  final warmUp = _clampSeconds((totalSeconds * 0.18).round(), 120, 420);
  final coolDown = _clampSeconds((totalSeconds * 0.14).round(), 120, 300);
  final working = totalSeconds - warmUp - coolDown;

  final stages = <WorkoutStage>[
    WorkoutStage(
      id: idFor(),
      tempo: Tempo.walk,
      duration: Duration(seconds: warmUp),
      note: 'Warm up',
    ),
  ];

  final repeats = <String, int>{};

  if (intervals) {
    final work = effort.workLength.inSeconds;
    final rest = effort.restLength.inSeconds;
    final rounds = (working / (work + rest)).floor().clamp(2, 12);
    final group = idFor();

    stages
      ..add(
        WorkoutStage(
          id: idFor(),
          tempo: effort.workingTempo,
          duration: Duration(seconds: work),
          marker: StageMarker.tempoChange,
          groupId: group,
          cadence: effort.cadence,
        ),
      )
      ..add(
        WorkoutStage(
          id: idFor(),
          tempo: Tempo.recovery,
          duration: Duration(seconds: rest),
          marker: StageMarker.recovery,
          groupId: group,
        ),
      );

    repeats[group] = rounds;

    // Whatever the rounds do not fill becomes easy running rather than being
    // silently dropped, so the route really lasts as long as it promised.
    final leftover = working - rounds * (work + rest);
    if (leftover >= 60) {
      stages.add(
        WorkoutStage(
          id: idFor(),
          tempo: Tempo.easyRun,
          duration: Duration(seconds: leftover),
          note: 'Easy finish',
          cadence: 165,
        ),
      );
    }
  } else {
    // A long steady effort is split so there is something to aim at along the
    // way instead of one undifferentiated block.
    final pieces = working > 1500 ? 3 : (working > 780 ? 2 : 1);
    final piece = working ~/ pieces;

    for (var i = 0; i < pieces; i++) {
      stages.add(
        WorkoutStage(
          id: idFor(),
          tempo: i == 0 ? Tempo.easyRun : effort.workingTempo,
          duration: Duration(
            seconds: i == pieces - 1 ? working - piece * i : piece,
          ),
          marker: i == 0 ? StageMarker.none : StageMarker.checkpoint,
          cadence: i == 0 ? 165 : effort.cadence,
        ),
      );
    }
  }

  stages.add(
    WorkoutStage(
      id: idFor(),
      tempo: Tempo.walk,
      duration: Duration(seconds: coolDown),
      note: 'Cool down',
    ),
  );

  return AutoRoute(stages: stages, repeats: repeats);
}

int _clampSeconds(int value, int min, int max) =>
    value < min ? min : (value > max ? max : value);
