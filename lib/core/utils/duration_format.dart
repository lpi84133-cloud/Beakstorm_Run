/// Duration formatting used across the timer, cards and statistics.
///
/// One place for all of it, so a stage reads the same in the builder as it does
/// mid-run.
extension DurationFormat on Duration {
  /// `4:30` for stages, `1:04:30` once an hour is involved.
  String get clock {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);

    final paddedSeconds = seconds.toString().padLeft(2, '0');
    if (hours == 0) return '$minutes:$paddedSeconds';

    return '$hours:${minutes.toString().padLeft(2, '0')}:$paddedSeconds';
  }

  /// `45s`, `12 min`, `1 h 20 min` — for summaries where precision to the
  /// second would be noise.
  String get compact {
    if (inSeconds < 60) return '${inSeconds}s';
    if (inMinutes < 60) return '$inMinutes min';

    final minutes = inMinutes.remainder(60);
    if (minutes == 0) return '$inHours h';
    return '$inHours h $minutes min';
  }

  /// Just the number, for a [StatTile] that shows its unit separately.
  String get minutesOnly => inMinutes.toString();
}
