import 'package:flutter/foundation.dart';

import 'session.dart';

/// A rough read on whether recent training has been light or heavy. Not a
/// medical judgement, just training common sense applied to the runner's own
/// history: nothing here compares one runner to another.
enum RecoveryLevel { fresh, normal, caution, rest }

@immutable
class RecoveryAdvice {
  const RecoveryAdvice({required this.level, required this.message});

  final RecoveryLevel level;
  final String message;
}

/// Reads the last few days of history and suggests whether today suits a hard
/// effort, an easy one, or a day off.
///
/// The rule set is deliberately simple and stated in the message itself, so
/// the advice reads as reasoning a runner could reach on their own rather
/// than an opaque score.
RecoveryAdvice buildRecoveryAdvice({
  required List<RunSession> sessions,
  required DateTime now,
}) {
  if (sessions.isEmpty) {
    return const RecoveryAdvice(
      level: RecoveryLevel.fresh,
      message: 'No runs logged yet. Any effort today is a good start.',
    );
  }

  final sorted = [...sessions]
    ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  final last = sorted.first;

  final today = DateTime(now.year, now.month, now.day);
  final lastDay = DateTime(
    last.startedAt.year,
    last.startedAt.month,
    last.startedAt.day,
  );
  final daysSinceLast = today.difference(lastDay).inDays;

  final recentWindow = today.subtract(const Duration(days: 2));
  final hardRecently = sorted
      .where((session) {
        final day = DateTime(
          session.startedAt.year,
          session.startedAt.month,
          session.startedAt.day,
        );
        return !day.isBefore(recentWindow) && _isHard(session);
      })
      .length;

  if (hardRecently >= 2) {
    return const RecoveryAdvice(
      level: RecoveryLevel.rest,
      message:
          'Two hard sessions in the last three days. An easy run or a full '
          'rest day would suit today.',
    );
  }

  if (daysSinceLast <= 1 && _isHard(last)) {
    return const RecoveryAdvice(
      level: RecoveryLevel.caution,
      message:
          'Your last session was hard. Today is a good day to keep the '
          'pace easy.',
    );
  }

  if (daysSinceLast >= 4) {
    return const RecoveryAdvice(
      level: RecoveryLevel.fresh,
      message:
          "It's been a few days since your last run. You're fresh for a "
          'solid effort today.',
    );
  }

  return const RecoveryAdvice(
    level: RecoveryLevel.normal,
    message:
        'Nothing in your recent training suggests easing off. Run whatever '
        'you have planned.',
  );
}

/// A session counts as hard by its own diary rating when there is one, and
/// otherwise by how much of it was spent at an effort tempo: a proxy that
/// keeps the advice useful even for runs nobody rated.
bool _isHard(RunSession session) {
  final effort = session.effort;
  if (effort != null) return effort >= 4;

  if (session.actualDuration.inMinutes < 12) return false;

  final totalSeconds = session.actualDuration.inSeconds;
  if (totalSeconds == 0) return false;

  final share = session.effortDuration.inSeconds / totalSeconds;
  return share >= 0.55;
}
