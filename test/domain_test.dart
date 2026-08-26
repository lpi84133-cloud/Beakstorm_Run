import 'package:beakstorm_run/core/utils/duration_format.dart';
import 'package:beakstorm_run/domain/auto_route.dart';
import 'package:beakstorm_run/domain/milestones.dart';
import 'package:beakstorm_run/domain/recovery_advisor.dart';
import 'package:beakstorm_run/domain/session.dart';
import 'package:beakstorm_run/domain/statistics.dart';
import 'package:beakstorm_run/domain/stage_marker.dart';
import 'package:beakstorm_run/domain/tempo.dart';
import 'package:beakstorm_run/domain/training_plan.dart';
import 'package:beakstorm_run/domain/workout.dart';
import 'package:beakstorm_run/domain/workout_stage.dart';
import 'package:beakstorm_run/domain/workout_templates.dart';
import 'package:beakstorm_run/domain/workout_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('templates', () {
    test('all five ship and every one is runnable as delivered', () {
      expect(workoutTemplates, hasLength(5));

      for (final template in workoutTemplates) {
        expect(
          validateRoute(name: template.name, stages: template.stages),
          isEmpty,
          reason: '${template.name} would be rejected by the builder',
        );
        expect(template.totalDuration.inMinutes, greaterThanOrEqualTo(10));
        expect(template.stages.any((s) => s.tempo.isActive), isTrue);
      }
    });

    test('stage ids are unique inside a template', () {
      for (final template in workoutTemplates) {
        final ids = template.stages.map((stage) => stage.id).toSet();
        expect(ids, hasLength(template.stages.length), reason: template.name);
      }
    });

    test('converting to a workout regenerates stage ids', () {
      final template = workoutTemplates.first;
      final workout = template.toWorkout(
        id: 'w1',
        idFor: (index) => 'stage-$index',
        now: DateTime(2026, 8, 25),
      );

      expect(workout.templateKey, template.key);
      expect(workout.stages.first.id, 'stage-0');
      expect(workout.totalDuration, template.totalDuration);
    });
  });

  group('repeat blocks', () {
    Workout routeWith(List<WorkoutStage> stages, Map<String, int> repeats) {
      final now = DateTime(2026, 8, 25);
      return Workout(
        id: 'w',
        name: 'Intervals',
        stages: stages,
        repeats: repeats,
        createdAt: now,
        updatedAt: now,
      );
    }

    WorkoutStage stage(String id, Tempo tempo, int seconds, {String? group}) =>
        WorkoutStage(
          id: id,
          tempo: tempo,
          duration: Duration(seconds: seconds),
          groupId: group,
        );

    test('a block is unrolled into the stages actually run', () {
      final route = routeWith([
        stage('warm', Tempo.walk, 60),
        stage('work', Tempo.run, 120, group: 'g'),
        stage('rest', Tempo.recovery, 60, group: 'g'),
        stage('cool', Tempo.walk, 60),
      ], {'g': 3});

      expect(route.stages, hasLength(4));
      expect(route.runStages, hasLength(8));
      expect(route.totalDuration, const Duration(seconds: 60 * 2 + 180 * 3));
      // Repeated stages need distinct ids so the timer can tell laps apart.
      expect(
        route.runStages.map((s) => s.id).toSet(),
        hasLength(route.runStages.length),
      );
    });

    test('a count of one behaves as a plain sequence', () {
      final route = routeWith([
        stage('work', Tempo.run, 120, group: 'g'),
        stage('rest', Tempo.recovery, 60, group: 'g'),
      ], {'g': 1});

      expect(route.runStages.map((s) => s.id), ['work', 'rest']);
    });

    test('splitting a block by a drag releases the stray stage', () {
      final normalized = normalizeGroups([
        stage('a', Tempo.run, 60, group: 'g'),
        stage('b', Tempo.run, 60, group: 'g'),
        stage('c', Tempo.walk, 60),
        stage('d', Tempo.run, 60, group: 'g'),
      ]);

      expect(normalized.map((s) => s.groupId), ['g', 'g', null, null]);
    });

    test('a block reduced to one stage is dissolved', () {
      final normalized = normalizeGroups([
        stage('a', Tempo.run, 60, group: 'g'),
        stage('b', Tempo.walk, 60),
      ]);

      expect(normalized.first.groupId, isNull);
    });
  });

  group('auto route', () {
    var counter = 0;
    String nextId() => 'id-${counter++}';

    setUp(() => counter = 0);

    test('the generated route lasts roughly what was asked for', () {
      for (final minutes in [10, 25, 45, 90]) {
        for (final intervals in [true, false]) {
          final route = buildAutoRoute(
            total: Duration(minutes: minutes),
            effort: RouteEffort.moderate,
            intervals: intervals,
            idFor: nextId,
          );

          final now = DateTime(2026, 8, 25);
          final workout = Workout(
            id: 'w',
            name: 'Auto',
            stages: route.stages,
            repeats: route.repeats,
            createdAt: now,
            updatedAt: now,
          );

          final drift =
              (workout.totalDuration.inSeconds - minutes * 60).abs();
          expect(
            drift,
            lessThanOrEqualTo(120),
            reason: '$minutes min, intervals: $intervals',
          );
        }
      }
    });

    test('it always warms up and cools down with walking', () {
      final route = buildAutoRoute(
        total: const Duration(minutes: 30),
        effort: RouteEffort.hard,
        intervals: true,
        idFor: nextId,
      );

      expect(route.stages.first.tempo, Tempo.walk);
      expect(route.stages.last.tempo, Tempo.walk);
      expect(route.repeats.values.single, greaterThanOrEqualTo(2));
    });

    test('what it produces passes the builder rules', () {
      final route = buildAutoRoute(
        total: const Duration(minutes: 20),
        effort: RouteEffort.easy,
        intervals: false,
        idFor: nextId,
      );

      expect(validateRoute(name: 'Auto', stages: route.stages), isEmpty);
    });
  });

  group('validation', () {
    WorkoutStage stage(String id, Tempo tempo, int seconds) => WorkoutStage(
      id: id,
      tempo: tempo,
      duration: Duration(seconds: seconds),
    );

    test('an empty route cannot be started', () {
      final issues = validateRoute(name: 'Morning', stages: []);
      expect(issues, hasLength(1));
      expect(issues.single.message, contains('at least one stage'));
    });

    test('a route of only rest is rejected', () {
      final issues = validateRoute(
        name: 'Rest day',
        stages: [stage('a', Tempo.stop, 300)],
      );
      expect(issues.map((i) => i.message), anyElement(contains('all rest')));
    });

    test('a too-short stage is reported against that stage', () {
      final issues = validateRoute(
        name: 'Morning',
        stages: [stage('a', Tempo.run, 2)],
      );
      expect(issues.single.stageId, 'a');
    });

    test('a plain valid route reports nothing', () {
      expect(
        validateRoute(
          name: 'Morning',
          stages: [stage('a', Tempo.walk, 120), stage('b', Tempo.run, 300)],
        ),
        isEmpty,
      );
    });
  });

  group('statistics', () {
    RunSession session(
      DateTime day,
      int minutes, {
      bool finished = true,
      int? effort,
    }) {
      return RunSession(
        id: day.millisecondsSinceEpoch,
        workoutId: 'w',
        workoutName: 'Morning',
        startedAt: day,
        endedAt: day.add(Duration(minutes: minutes)),
        plannedDuration: Duration(minutes: minutes),
        actualDuration: Duration(minutes: minutes),
        completedStages: 4,
        totalStages: 4,
        finishedRoute: finished,
        timePerTempo: {
          Tempo.run: Duration(minutes: minutes ~/ 2),
          Tempo.walk: Duration(minutes: minutes - minutes ~/ 2),
        },
        effort: effort,
      );
    }

    final now = DateTime(2026, 8, 26, 9);

    test('empty history produces an empty result, not a crash', () {
      final stats = buildStats(
        range: StatsRange.week,
        sessions: const [],
        now: now,
      );
      expect(stats.isEmpty, isTrue);
      expect(stats.streakDays, 0);
    });

    test('totals and averages come from sessions inside the window', () {
      final stats = buildStats(
        range: StatsRange.week,
        sessions: [
          session(DateTime(2026, 8, 24, 8), 20),
          session(DateTime(2026, 8, 26, 7), 40),
          // Previous week, must be excluded.
          session(DateTime(2026, 8, 18, 7), 90),
        ],
        now: now,
      );

      expect(stats.sessionCount, 2);
      expect(stats.totalTime, const Duration(minutes: 60));
      expect(stats.averageTime, const Duration(minutes: 30));
      expect(stats.longestTime, const Duration(minutes: 40));
      expect(stats.buckets, hasLength(7));
    });

    test('a streak survives a gap of less than a day', () {
      final stats = buildStats(
        range: StatsRange.week,
        sessions: [
          session(DateTime(2026, 8, 25, 8), 20),
          session(DateTime(2026, 8, 24, 8), 20),
        ],
        now: now,
      );
      expect(stats.streakDays, 2);
    });

    test('a two-day gap ends the streak', () {
      final stats = buildStats(
        range: StatsRange.week,
        sessions: [session(DateTime(2026, 8, 23, 8), 20)],
        now: now,
      );
      expect(stats.streakDays, 0);
    });

    test('average effort ignores sessions that skipped the diary', () {
      final stats = buildStats(
        range: StatsRange.week,
        sessions: [
          session(DateTime(2026, 8, 24, 8), 20, effort: 2),
          session(DateTime(2026, 8, 25, 8), 20, effort: 4),
          session(DateTime(2026, 8, 26, 8), 20),
        ],
        now: now,
      );

      expect(stats.averageEffort, 3);
    });

    test('average effort is null when nobody has rated a run', () {
      final stats = buildStats(
        range: StatsRange.week,
        sessions: [session(DateTime(2026, 8, 24, 8), 20)],
        now: now,
      );

      expect(stats.averageEffort, isNull);
    });
  });

  group('recovery advice', () {
    final now = DateTime(2026, 8, 26, 9);

    RunSession run(
      DateTime day, {
      int? effort,
      int minutes = 30,
      double effortShare = 0.3,
    }) {
      final effortSeconds = (minutes * 60 * effortShare).round();

      return RunSession(
        id: day.millisecondsSinceEpoch,
        workoutId: 'w',
        workoutName: 'Run',
        startedAt: day,
        endedAt: day.add(Duration(minutes: minutes)),
        plannedDuration: Duration(minutes: minutes),
        actualDuration: Duration(minutes: minutes),
        completedStages: 4,
        totalStages: 4,
        finishedRoute: true,
        timePerTempo: {
          Tempo.run: Duration(seconds: effortSeconds),
          Tempo.walk: Duration(seconds: minutes * 60 - effortSeconds),
        },
        effort: effort,
      );
    }

    test('an empty history invites a first run instead of warning', () {
      final advice = buildRecoveryAdvice(sessions: const [], now: now);
      expect(advice.level, RecoveryLevel.fresh);
    });

    test('two hard days inside three calls for recovery', () {
      final advice = buildRecoveryAdvice(
        sessions: [
          run(DateTime(2026, 8, 25, 8), effort: 5),
          run(DateTime(2026, 8, 24, 8), effort: 4),
        ],
        now: now,
      );

      expect(advice.level, RecoveryLevel.rest);
    });

    test('one hard day yesterday only suggests going easy', () {
      final advice = buildRecoveryAdvice(
        sessions: [
          run(DateTime(2026, 8, 25, 8), effort: 5),
          run(DateTime(2026, 8, 20, 8), effort: 2),
        ],
        now: now,
      );

      expect(advice.level, RecoveryLevel.caution);
    });

    test('a gap of several days reads as fresh', () {
      final advice = buildRecoveryAdvice(
        sessions: [run(DateTime(2026, 8, 20, 8), effort: 3)],
        now: now,
      );

      expect(advice.level, RecoveryLevel.fresh);
    });

    test('easy recent training needs no adjustment', () {
      final advice = buildRecoveryAdvice(
        sessions: [run(DateTime(2026, 8, 25, 8), effort: 2)],
        now: now,
      );

      expect(advice.level, RecoveryLevel.normal);
    });

    test('an unrated run falls back to how much of it was effort', () {
      final hard = buildRecoveryAdvice(
        sessions: [run(DateTime(2026, 8, 25, 8), effortShare: 0.8)],
        now: now,
      );
      final gentle = buildRecoveryAdvice(
        sessions: [run(DateTime(2026, 8, 25, 8), effortShare: 0.2)],
        now: now,
      );

      expect(hard.level, RecoveryLevel.caution);
      expect(gentle.level, RecoveryLevel.normal);
    });

    test('a short run is never counted as hard on tempo alone', () {
      final advice = buildRecoveryAdvice(
        sessions: [
          run(DateTime(2026, 8, 25, 8), minutes: 8, effortShare: 0.9),
        ],
        now: now,
      );

      expect(advice.level, RecoveryLevel.normal);
    });
  });

  group('milestones', () {
    RunSession run(DateTime day, {int minutes = 30, int stages = 4}) {
      return RunSession(
        id: day.millisecondsSinceEpoch,
        workoutId: 'w',
        workoutName: 'Run',
        startedAt: day,
        endedAt: day.add(Duration(minutes: minutes)),
        plannedDuration: Duration(minutes: minutes),
        actualDuration: Duration(minutes: minutes),
        completedStages: stages,
        totalStages: stages,
        finishedRoute: true,
        timePerTempo: const {},
      );
    }

    test('an empty history has no records', () {
      expect(computeMilestones(const []).isEmpty, isTrue);
    });

    test('keeps the best run and the day it happened', () {
      final best = computeMilestones([
        run(DateTime(2026, 8, 20), minutes: 25, stages: 4),
        run(DateTime(2026, 8, 22), minutes: 55, stages: 9),
        run(DateTime(2026, 8, 24), minutes: 30, stages: 6),
      ]);

      expect(best.longestRun, const Duration(minutes: 55));
      expect(best.longestRunAt, DateTime(2026, 8, 22));
      expect(best.mostStages, 9);
      expect(best.totalSessions, 3);
      expect(best.finishedRoutes, 3);
    });

    test('the best streak survives a later gap', () {
      final best = computeMilestones([
        run(DateTime(2026, 8, 10)),
        run(DateTime(2026, 8, 11)),
        run(DateTime(2026, 8, 12)),
        // Gap, then a shorter streak that must not lower the record.
        run(DateTime(2026, 8, 20)),
        run(DateTime(2026, 8, 21)),
      ]);

      expect(best.bestStreak, 3);
    });

    test('two runs on one day count as a single day', () {
      final best = computeMilestones([
        run(DateTime(2026, 8, 10, 7)),
        run(DateTime(2026, 8, 10, 19)),
      ]);

      expect(best.bestStreak, 1);
      expect(best.totalSessions, 2);
    });
  });

  group('run diary', () {
    test('copyWith keeps the id assigned on save', () {
      final session = RunSession(
        id: 0,
        workoutId: 'w',
        workoutName: 'Morning',
        startedAt: DateTime(2026, 8, 26),
        endedAt: DateTime(2026, 8, 26, 0, 30),
        plannedDuration: const Duration(minutes: 30),
        actualDuration: const Duration(minutes: 30),
        completedStages: 4,
        totalStages: 4,
        finishedRoute: true,
        timePerTempo: const {},
      );

      final saved = session.copyWith(id: 7);
      final rated = saved.copyWith(effort: 3, note: 'Slept badly');

      expect(rated.id, 7);
      expect(rated.effort, 3);
      expect(rated.note, 'Slept badly');
    });
  });

  group('duration formatting', () {
    test('clock pads seconds and only shows hours when needed', () {
      expect(const Duration(seconds: 45).clock, '0:45');
      expect(const Duration(minutes: 4, seconds: 5).clock, '4:05');
      expect(const Duration(hours: 1, minutes: 4, seconds: 30).clock, '1:04:30');
    });

    test('compact drops precision that would be noise', () {
      expect(const Duration(seconds: 45).compact, '45s');
      expect(const Duration(minutes: 12).compact, '12 min');
      expect(const Duration(hours: 1, minutes: 20).compact, '1 h 20 min');
      expect(const Duration(hours: 2).compact, '2 h');
    });
  });

  test('markers carry no scoring behaviour, only labels', () {
    for (final marker in StageMarker.values) {
      expect(marker.label, isNotEmpty);
      expect(marker.description, isNotEmpty);
    }
  });

  group('training plan', () {
    TrainingPlan plan({
      int weeks = 4,
      int perWeek = 3,
      Map<String, DateTime> completed = const {},
    }) {
      return buildTrainingPlan(
        weeks: weeks,
        sessionsPerWeek: perWeek,
        effort: RouteEffort.moderate,
        baseMinutes: 30,
        startedAt: DateTime(2026, 1, 5),
        completed: completed,
      );
    }

    test('lays out every week and session', () {
      final built = plan();

      expect(built.totalSessions, 12);
      expect(built.sessionsIn(1).length, 3);
      expect(built.sessions.first.key, 'w1-s1');
      expect(built.sessions.every((session) => session.stages.isNotEmpty), isTrue);
    });

    test('grows through the plan and eases off at the end', () {
      final built = plan();

      final firstWeek = built.sessionsIn(1).first.duration;
      final peak = built.sessionsIn(3).first.duration;
      final last = built.sessionsIn(4).first.duration;

      expect(peak, greaterThan(firstWeek));
      expect(last, lessThan(peak));
    });

    test('regenerating with the same settings gives the same session keys', () {
      expect(
        plan().sessions.map((session) => session.key),
        plan().sessions.map((session) => session.key),
      );
    });

    test('points at the first unfinished session', () {
      final done = {'w1-s1': DateTime(2026, 1, 5)};
      final built = plan(completed: done);

      expect(built.doneCount, 1);
      expect(built.nextSession?.key, 'w1-s2');
      expect(built.currentWeek, 1);
      expect(built.progress, closeTo(1 / 12, 0.001));
    });

    test('is complete once every session is ticked off', () {
      final keys = plan().sessions.map((session) => session.key);
      final built = plan(
        completed: {for (final key in keys) key: DateTime(2026, 2, 1)},
      );

      expect(built.isComplete, isTrue);
      expect(built.nextSession, isNull);
    });

    test('interval sessions carry a cadence target on the working stage', () {
      final intervals = plan().sessions.firstWhere(
        (session) => session.focus == PlanFocus.intervals,
      );

      expect(
        intervals.stages.any((stage) => stage.cadence != null),
        isTrue,
      );
    });
  });
}
