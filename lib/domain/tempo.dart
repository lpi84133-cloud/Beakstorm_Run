/// The activity modes a stage can use.
///
/// Deliberately small: six modes cover interval training without turning the
/// builder into a form. Names are the ones runners already use.
enum Tempo {
  walk('Walk', 'Easy walking pace to warm up or cool down'),
  easyRun('Easy Run', 'Conversational pace, breathing stays comfortable'),
  run('Run', 'Steady working pace you can hold'),
  fastRun('Fast Run', 'Hard effort for short bursts'),
  recovery('Recovery', 'Very light movement between efforts'),
  stop('Stop', 'Standing rest, stretching or a drink');

  const Tempo(this.label, this.description);

  final String label;
  final String description;

  /// Modes that count as real work when checking a route is worth running.
  bool get isActive => this != Tempo.stop;

  /// Modes that carry effort, used for the intensity share in statistics.
  bool get isEffort =>
      this == Tempo.easyRun || this == Tempo.run || this == Tempo.fastRun;
}
