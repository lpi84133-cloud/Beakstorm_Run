/// Optional visual landmark placed on a stage.
///
/// Markers are a reading aid for a long route and nothing else: they carry no
/// score, no reward and no effect on the timer.
enum StageMarker {
  none('None', 'No marker'),
  checkpoint('Checkpoint', 'Splits a long route into parts'),
  tempoChange('Tempo change', 'Highlights where the effort shifts'),
  recovery('Recovery point', 'Marks where you ease off');

  const StageMarker(this.label, this.description);

  final String label;
  final String description;
}
