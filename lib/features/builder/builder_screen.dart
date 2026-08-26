import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/duration_format.dart';
import '../../core/utils/id.dart';
import '../../core/widgets/beak_button.dart';
import '../../core/widgets/beak_card.dart';
import '../../core/widgets/beak_pill.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/tempo_strip.dart';
import '../../data/workout_repository.dart';
import '../../domain/auto_route.dart';
import '../../domain/stage_marker.dart';
import '../../domain/tempo.dart';
import '../../domain/workout.dart';
import '../../domain/workout_stage.dart';
import '../../domain/workout_templates.dart';
import '../../domain/workout_validation.dart';
import 'widgets/stage_editor_sheet.dart';
import 'widgets/stage_spine_tile.dart';

/// Creates and edits a route.
///
/// Opens empty, from a built-in template (`templateKey`) or on a saved route
/// (`workoutId`). Nothing is written to storage until Save.
class BuilderScreen extends ConsumerStatefulWidget {
  const BuilderScreen({super.key, this.workoutId, this.templateKey});

  final String? workoutId;
  final String? templateKey;

  @override
  ConsumerState<BuilderScreen> createState() => _BuilderScreenState();
}

class _BuilderScreenState extends ConsumerState<BuilderScreen> {
  final _name = TextEditingController();

  List<WorkoutStage> _stages = [];
  Map<String, int> _repeats = {};

  /// Stage ids picked for a new block. Empty means the builder is not in
  /// selection mode.
  final Set<String> _selection = {};
  bool _selecting = false;

  String _id = newId();
  String? _templateKey;
  DateTime _createdAt = DateTime.now();

  bool _loading = true;
  bool _dirty = false;
  bool _showIssues = false;

  bool get _isEditing => widget.workoutId != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final id = widget.workoutId;

    if (id != null) {
      final existing = await ref.read(workoutRepositoryProvider).findById(id);
      if (!mounted) return;

      if (existing != null) {
        setState(() {
          _id = existing.id;
          _name.text = existing.name;
          _stages = List.of(existing.stages);
          _repeats = Map.of(existing.repeats);
          _templateKey = existing.templateKey;
          _createdAt = existing.createdAt;
          _loading = false;
        });
        return;
      }
    }

    final template = templateByKey(widget.templateKey);
    if (template != null) {
      final copy = template.toWorkout(
        id: _id,
        idFor: (_) => newId(),
        now: DateTime.now(),
      );

      setState(() {
        _name.text = copy.name;
        _stages = List.of(copy.stages);
        _templateKey = template.key;
        _loading = false;
        // A template is a suggestion, not a saved route: leaving now should
        // still warn that the copy would be lost.
        _dirty = true;
      });
      return;
    }

    setState(() {
      _name.text = 'My route';
      _stages = [
        WorkoutStage(
          id: newId(),
          tempo: Tempo.walk,
          duration: const Duration(minutes: 3),
          note: 'Warm up',
        ),
        WorkoutStage(
          id: newId(),
          tempo: Tempo.run,
          duration: const Duration(minutes: 5),
          marker: StageMarker.tempoChange,
        ),
        WorkoutStage(
          id: newId(),
          tempo: Tempo.walk,
          duration: const Duration(minutes: 2),
          note: 'Cool down',
        ),
      ];
      _loading = false;
    });
  }

  Workout _draft(DateTime now) => Workout(
    id: _id,
    name: _name.text.trim(),
    stages: _stages,
    repeats: _repeats,
    templateKey: _templateKey,
    createdAt: _createdAt,
    updatedAt: now,
  );

  List<RouteIssue> get _issues => validateRoute(
    name: _name.text,
    stages: _stages,
    expandedCount: _draft(DateTime.now()).runStages.length,
  );

  Future<void> _editStage(int index) async {
    final result = await showStageEditor(
      context,
      stage: _stages[index],
      position: index,
    );
    if (result == null) return;

    setState(() {
      _dirty = true;
      if (result.delete) {
        _stages.removeAt(index);
        _stages = normalizeGroups(_stages);
      } else {
        _stages[index] = result.stage!.copyWith(
          groupId: _stages[index].groupId,
        );
      }
    });
  }

  Future<void> _addStage() async {
    if (_stages.length >= kMaxStages) {
      _notify('A route can hold up to $kMaxStages stages.');
      return;
    }

    final result = await showStageEditor(context, position: _stages.length);
    if (result == null || result.stage == null) return;

    setState(() {
      _stages.add(result.stage!);
      _dirty = true;
    });
  }

  void _reorder(int oldIndex, int newIndex) {
    setState(() {
      _stages.insert(newIndex, _stages.removeAt(oldIndex));
      _stages = normalizeGroups(_stages);
      _dirty = true;
    });
    HapticFeedback.selectionClick();
  }

  /// Replaces the whole route with a generated one. Confirmed first, because it
  /// throws away whatever is on screen.
  Future<void> _autoBuild() async {
    final generated = await showModalBottomSheet<AutoRoute>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: context.colors.canvasElevated,
      shape: const RoundedRectangleBorder(borderRadius: Corners.sheetRadius),
      builder: (context) => const _AutoRouteSheet(),
    );

    if (generated == null) return;

    setState(() {
      _stages = List.of(generated.stages);
      _repeats = Map.of(generated.repeats);
      _showIssues = false;
      _dirty = true;
    });
  }

  String _markerLabel() {
    final count = _stages
        .where((stage) => stage.marker != StageMarker.none)
        .length;
    return count == 1 ? '1 marker' : '\$count markers';
  }

  BlockPosition _blockPosition(int index) {
    final group = _stages[index].groupId;
    if (group == null) return BlockPosition.none;

    final startsHere = index == 0 || _stages[index - 1].groupId != group;
    final endsHere =
        index == _stages.length - 1 || _stages[index + 1].groupId != group;

    if (startsHere) return BlockPosition.first;
    if (endsHere) return BlockPosition.last;
    return BlockPosition.middle;
  }

  void _toggleSelectionMode() {
    setState(() {
      _selecting = !_selecting;
      _selection.clear();
    });
  }

  void _toggleSelected(String stageId) {
    setState(() {
      if (!_selection.remove(stageId)) _selection.add(stageId);
    });
  }

  /// Wraps the picked stages into a block. They have to sit next to each other,
  /// because a block that jumps around the route would be unreadable.
  void _createBlock() {
    final indices =
        _stages
            .asMap()
            .entries
            .where((entry) => _selection.contains(entry.value.id))
            .map((entry) => entry.key)
            .toList()
          ..sort();

    if (indices.length < 2) {
      _notify('Pick at least two stages to repeat together.');
      return;
    }

    if (indices.last - indices.first != indices.length - 1) {
      _notify('Stages in a block have to be next to each other.');
      return;
    }

    final group = newId();

    setState(() {
      for (final index in indices) {
        _stages[index] = _stages[index].copyWith(groupId: group);
      }
      _repeats = {..._repeats, group: 4};
      _selecting = false;
      _selection.clear();
      _dirty = true;
    });

    HapticFeedback.mediumImpact();
  }

  Future<void> _editBlock(String group) async {
    var times = _repeats[group] ?? 2;

    final result = await showDialog<int>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Repeat block'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'How many times should these stages run?',
                style: context.text.bodyMedium,
              ),
              const SizedBox(height: Insets.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton.filledTonal(
                    onPressed: times > 1
                        ? () => setDialogState(() => times--)
                        : null,
                    icon: const Icon(Icons.remove_rounded),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Insets.xl),
                    child: Text('×\$times', style: context.text.displaySmall),
                  ),
                  IconButton.filledTonal(
                    onPressed: times < 20
                        ? () => setDialogState(() => times++)
                        : null,
                    icon: const Icon(Icons.add_rounded),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(1),
              child: const Text('Ungroup'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(times),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );

    if (result == null) return;

    setState(() {
      _dirty = true;

      if (result <= 1) {
        _stages = [
          for (final stage in _stages)
            stage.groupId == group ? stage.copyWith(clearGroup: true) : stage,
        ];
        _repeats = {..._repeats}..remove(group);
        return;
      }

      _repeats = {..._repeats, group: result};
    });
  }

  Future<void> _save() async {
    final issues = _issues;
    if (issues.isNotEmpty) {
      setState(() => _showIssues = true);
      _notify(issues.first.message);
      return;
    }

    final now = DateTime.now();

    await ref
        .read(workoutRepositoryProvider)
        .save(
          Workout(
            id: _id,
            name: _name.text.trim(),
            stages: _stages,
            repeats: _repeats,
            templateKey: _templateKey,
            createdAt: _createdAt,
            updatedAt: now,
          ),
        );

    if (!mounted) return;
    _dirty = false;
    context.pop();
  }

  void _notify(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<bool> _confirmDiscard() async {
    if (!_dirty) return true;

    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('This route has edits that have not been saved.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: context.colors.danger),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return discard ?? false;
  }

  Future<void> _closeIfDiscarded() async {
    if (!await _confirmDiscard()) return;
    if (!mounted) return;
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final draft = _draft(DateTime.now());
    final expanded = draft.runStages;
    final issues = _issues;

    return PopScope(
      canPop: !_dirty,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _closeIfDiscarded();
      },
      child: Scaffold(
        backgroundColor: colors.canvas,
        appBar: AppBar(
          title: Text(_isEditing ? 'Edit route' : 'New route'),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: _closeIfDiscarded,
          ),
          actions: [
            IconButton(
              onPressed: _loading ? null : _autoBuild,
              tooltip: 'Build it for me',
              icon: const Icon(Icons.auto_awesome_rounded),
            ),
            TextButton(
              onPressed: _loading ? null : _save,
              style: TextButton.styleFrom(foregroundColor: colors.accent),
              child: const Text('Save'),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator.adaptive())
            : SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: Layout.maxContentWidth,
                    ),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(
                        Insets.xl,
                        Insets.lg,
                        Insets.xl,
                        Insets.xxxl,
                      ),
                      children: [
                        TextField(
                          controller: _name,
                          textCapitalization: TextCapitalization.sentences,
                          maxLength: 40,
                          style: context.text.headlineMedium,
                          decoration: const InputDecoration(
                            hintText: 'Route name',
                            counterText: '',
                            filled: false,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (_) => setState(() => _dirty = true),
                        ),
                        const SizedBox(height: Insets.md),
                        Wrap(
                          spacing: Insets.sm,
                          runSpacing: Insets.sm,
                          children: [
                            BeakPill(
                              label: draft.totalDuration.compact,
                              icon: Icons.schedule_rounded,
                            ),
                            BeakPill(
                              label: expanded.length == 1
                                  ? '1 stage'
                                  : '${expanded.length} stages',
                              icon: Icons.layers_rounded,
                              color: colors.easyRun,
                            ),
                            BeakPill(
                              label: _markerLabel(),
                              icon: Icons.flag_rounded,
                              color: colors.walk,
                            ),
                          ],
                        ),
                        const SizedBox(height: Insets.lg),
                        BeakCard(
                          padding: const EdgeInsets.all(Insets.md),
                          child: TempoStrip(stages: expanded),
                        ),
                        if (_showIssues && issues.isNotEmpty) ...[
                          const SizedBox(height: Insets.lg),
                          _IssueList(issues: issues),
                        ],
                        const SizedBox(height: Insets.xl),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _selecting
                                    ? 'Pick the stages that repeat together. '
                                          'They have to be next to each other.'
                                    : 'Hold a stage to reorder it. Tap to '
                                          'change tempo, length or marker.',
                                style: context.text.bodySmall?.copyWith(
                                  color: colors.textMuted,
                                ),
                              ),
                            ),
                            const SizedBox(width: Insets.sm),
                            TextButton.icon(
                              onPressed: _stages.length < 2
                                  ? null
                                  : _toggleSelectionMode,
                              icon: Icon(
                                _selecting
                                    ? Icons.close_rounded
                                    : Icons.repeat_rounded,
                                size: 18,
                              ),
                              label: Text(_selecting ? 'Cancel' : 'Repeat'),
                              style: TextButton.styleFrom(
                                foregroundColor: colors.accent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Insets.lg),
                        ReorderableListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          buildDefaultDragHandles: false,
                          itemCount: _stages.length,
                          onReorderItem: _reorder,
                          itemBuilder: (context, index) {
                            final stage = _stages[index];
                            final group = stage.groupId;

                            final tile = StageSpineTile(
                              stage: stage,
                              index: index,
                              isFirst: index == 0,
                              isLast: index == _stages.length - 1,
                              block: _blockPosition(index),
                              repeatTimes: group == null
                                  ? null
                                  : _repeats[group],
                              onRepeatTap: group == null
                                  ? null
                                  : () => _editBlock(group),
                              selected: _selecting
                                  ? _selection.contains(stage.id)
                                  : null,
                              onTap: _selecting
                                  ? () => _toggleSelected(stage.id)
                                  : () => _editStage(index),
                              trailing: _selecting
                                  ? null
                                  : Icon(
                                      Icons.drag_indicator_rounded,
                                      size: 18,
                                      color: colors.textMuted,
                                    ),
                            );

                            // Dragging is off while picking, so a tap can never
                            // be mistaken for the start of a reorder.
                            return _selecting
                                ? KeyedSubtree(key: ValueKey(stage.id), child: tile)
                                : ReorderableDelayedDragStartListener(
                                    key: ValueKey(stage.id),
                                    index: index,
                                    child: tile,
                                  );
                          },
                        ),
                        if (_selecting) ...[
                          const SizedBox(height: Insets.sm),
                          BeakButton(
                            label: _selection.length < 2
                                ? 'Pick stages to repeat'
                                : 'Repeat ${_selection.length} stages',
                            icon: Icons.repeat_rounded,
                            onPressed: _selection.length < 2
                                ? null
                                : _createBlock,
                          ),
                        ],
                        const SizedBox(height: Insets.sm),
                        BeakButton(
                          label: 'Add stage',
                          icon: Icons.add_rounded,
                          variant: BeakButtonVariant.secondary,
                          onPressed: _addStage,
                        ),
                        const SizedBox(height: Insets.xl),
                        BeakButton(
                          label: _isEditing ? 'Save changes' : 'Save route',
                          icon: Icons.check_rounded,
                          onPressed: _save,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

/// Asks the two questions that decide a session — how long, and how hard — and
/// shows the resulting shape before it is accepted.
class _AutoRouteSheet extends StatefulWidget {
  const _AutoRouteSheet();

  @override
  State<_AutoRouteSheet> createState() => _AutoRouteSheetState();
}

class _AutoRouteSheetState extends State<_AutoRouteSheet> {
  int _minutes = 30;
  RouteEffort _effort = RouteEffort.moderate;
  bool _intervals = true;

  AutoRoute get _preview => buildAutoRoute(
    total: Duration(minutes: _minutes),
    effort: _effort,
    intervals: _intervals,
    idFor: newId,
  );

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final preview = _preview;

    final expanded = Workout(
      id: 'preview',
      name: 'preview',
      stages: preview.stages,
      repeats: preview.repeats,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ).runStages;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        Insets.xl,
        Insets.md,
        Insets.xl,
        Insets.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: colors.borderStrong,
                borderRadius: Corners.pillRadius,
              ),
            ),
          ),
          const SizedBox(height: Insets.xl),
          const SectionHeader(
            title: 'Build it for me',
            eyebrow: 'Time and effort',
          ),
          const SizedBox(height: Insets.xl),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$_minutes',
                style: context.text.displaySmall?.copyWith(
                  color: colors.accent,
                ),
              ),
              const SizedBox(width: Insets.xs),
              Text('minutes', style: context.text.labelMedium),
            ],
          ),
          Slider.adaptive(
            value: _minutes.toDouble(),
            min: 10,
            max: 90,
            divisions: 16,
            onChanged: (value) => setState(() => _minutes = value.round()),
          ),
          const SizedBox(height: Insets.md),
          Text('Effort', style: context.text.titleSmall),
          const SizedBox(height: Insets.md),
          Wrap(
            spacing: Insets.sm,
            children: [
              for (final effort in RouteEffort.values)
                ChoiceChip(
                  label: Text(effort.label),
                  selected: effort == _effort,
                  onSelected: (_) => setState(() => _effort = effort),
                ),
            ],
          ),
          const SizedBox(height: Insets.sm),
          Text(
            _effort.description,
            style: context.text.bodySmall?.copyWith(color: colors.textMuted),
          ),
          const SizedBox(height: Insets.md),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _intervals,
            onChanged: (value) => setState(() => _intervals = value),
            title: const Text('Intervals'),
            subtitle: const Text('Repeat a work and recovery block'),
          ),
          const SizedBox(height: Insets.lg),
          BeakCard(
            padding: const EdgeInsets.all(Insets.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TempoStrip(stages: expanded),
                const SizedBox(height: Insets.md),
                Text(
                  '${expanded.length} stages'
                  '${preview.repeats.isEmpty ? '' : '  ·  ${preview.repeats.values.first} rounds'}',
                  style: context.text.bodySmall?.copyWith(
                    color: colors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Insets.xl),
          BeakButton(
            label: 'Use this route',
            icon: Icons.check_rounded,
            onPressed: () => Navigator.of(context).pop(_preview),
          ),
        ],
      ),
    );
  }
}

class _IssueList extends StatelessWidget {
  const _IssueList({required this.issues});

  final List<RouteIssue> issues;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BeakCard(
      color: colors.danger.withValues(alpha: 0.12),
      borderColor: colors.danger.withValues(alpha: 0.4),
      elevated: false,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final issue in issues)
            Padding(
              padding: const EdgeInsets.only(bottom: Insets.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    size: 16,
                    color: colors.danger,
                  ),
                  const SizedBox(width: Insets.sm),
                  Expanded(
                    child: Text(
                      issue.message,
                      style: context.text.bodySmall?.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
