import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/audio/cadence_metronome.dart';
import '../../../core/theme/app_dimens.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/marker_style.dart';
import '../../../core/utils/duration_format.dart';
import '../../../core/utils/id.dart';
import '../../../core/widgets/beak_button.dart';
import '../../../core/widgets/section_header.dart';
import '../../../domain/stage_marker.dart';
import '../../../domain/tempo.dart';
import '../../../domain/workout_stage.dart';
import '../../../domain/workout_validation.dart';

/// What the sheet hands back: the edited stage, or a request to remove it.
class StageEditorResult {
  const StageEditorResult.saved(this.stage) : delete = false;
  const StageEditorResult.deleted() : stage = null, delete = true;

  final WorkoutStage? stage;
  final bool delete;
}

Future<StageEditorResult?> showStageEditor(
  BuildContext context, {
  WorkoutStage? stage,
  required int position,
}) {
  return showModalBottomSheet<StageEditorResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: context.colors.canvasElevated,
    shape: const RoundedRectangleBorder(borderRadius: Corners.sheetRadius),
    builder: (context) => _StageEditorSheet(stage: stage, position: position),
  );
}

class _StageEditorSheet extends StatefulWidget {
  const _StageEditorSheet({required this.stage, required this.position});

  final WorkoutStage? stage;
  final int position;

  @override
  State<_StageEditorSheet> createState() => _StageEditorSheetState();
}

class _StageEditorSheetState extends State<_StageEditorSheet> {
  late Tempo _tempo = widget.stage?.tempo ?? Tempo.run;
  late Duration _duration = widget.stage?.duration ?? const Duration(minutes: 2);
  late StageMarker _marker = widget.stage?.marker ?? StageMarker.none;
  late int? _cadence = widget.stage?.cadence;
  late final TextEditingController _note = TextEditingController(
    text: widget.stage?.note ?? '',
  );

  bool get _isNew => widget.stage == null;

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _nudge(int seconds) {
    final next = Duration(seconds: _duration.inSeconds + seconds);
    if (next < kMinStageDuration || next > kMaxStageDuration) {
      HapticFeedback.heavyImpact();
      return;
    }

    HapticFeedback.selectionClick();
    setState(() => _duration = next);
  }

  void _save() {
    final note = _note.text.trim();

    Navigator.of(context).pop(
      StageEditorResult.saved(
        WorkoutStage(
          id: widget.stage?.id ?? newId(),
          tempo: _tempo,
          duration: _duration,
          marker: _marker,
          note: note.isEmpty ? null : note,
          cadence: _cadence,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
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
            SectionHeader(
              title: _isNew ? 'New stage' : 'Stage ${widget.position + 1}',
              eyebrow: 'Effort and length',
            ),
            const SizedBox(height: Insets.xl),
            _TempoPicker(
              value: _tempo,
              onChanged: (tempo) {
                HapticFeedback.selectionClick();
                setState(() => _tempo = tempo);
              },
            ),
            const SizedBox(height: Insets.md),
            Text(
              _tempo.description,
              style: context.text.bodySmall?.copyWith(color: colors.textMuted),
            ),
            const SizedBox(height: Insets.xxl),
            _DurationField(
              duration: _duration,
              onNudge: _nudge,
              onPreset: (value) {
                HapticFeedback.selectionClick();
                setState(() => _duration = value);
              },
            ),
            const SizedBox(height: Insets.xxl),
            _CadencePicker(
              value: _cadence,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                setState(() => _cadence = value);
              },
            ),
            const SizedBox(height: Insets.xxl),
            Text('Marker', style: context.text.titleSmall),
            const SizedBox(height: Insets.sm),
            Text(
              'Optional. Markers only help you read the route; they do not '
              'change the timer.',
              style: context.text.bodySmall?.copyWith(color: colors.textMuted),
            ),
            const SizedBox(height: Insets.md),
            _MarkerPicker(
              value: _marker,
              onChanged: (marker) {
                HapticFeedback.selectionClick();
                setState(() => _marker = marker);
              },
            ),
            const SizedBox(height: Insets.xxl),
            Text('Note', style: context.text.titleSmall),
            const SizedBox(height: Insets.md),
            TextField(
              controller: _note,
              maxLength: 40,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                hintText: 'Outer lap, up the hill, …',
                counterText: '',
              ),
            ),
            const SizedBox(height: Insets.xl),
            Row(
              children: [
                if (!_isNew) ...[
                  BeakButton(
                    label: 'Remove',
                    icon: Icons.delete_outline_rounded,
                    variant: BeakButtonVariant.ghost,
                    expand: false,
                    onPressed: () => Navigator.of(
                      context,
                    ).pop(const StageEditorResult.deleted()),
                  ),
                  const SizedBox(width: Insets.md),
                ],
                Expanded(
                  child: BeakButton(
                    label: _isNew ? 'Add stage' : 'Save stage',
                    icon: Icons.check_rounded,
                    onPressed: _save,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Sets the step rhythm the metronome ticks during this stage.
class _CadencePicker extends StatelessWidget {
  const _CadencePicker({required this.value, required this.onChanged});

  final int? value;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text('Cadence', style: context.text.titleSmall)),
            Switch.adaptive(
              value: value != null,
              onChanged: (on) => onChanged(on ? 170 : null),
            ),
          ],
        ),
        Text(
          'A steady tick to land your steps on, in steps per minute. Most '
          'runners settle between 160 and 180.',
          style: context.text.bodySmall?.copyWith(color: colors.textMuted),
        ),
        if (value != null) ...[
          const SizedBox(height: Insets.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$value',
                style: context.text.displaySmall?.copyWith(
                  color: colors.accent,
                ),
              ),
              const SizedBox(width: Insets.xs),
              Text('steps / min', style: context.text.labelMedium),
            ],
          ),
          Slider.adaptive(
            value: value!.toDouble(),
            min: kMinCadence.toDouble(),
            max: kMaxCadence.toDouble(),
            divisions: (kMaxCadence - kMinCadence) ~/ kCadenceStep,
            onChanged: (raw) => onChanged(raw.round()),
          ),
        ],
      ],
    );
  }
}

class _TempoPicker extends StatelessWidget {
  const _TempoPicker({required this.value, required this.onChanged});

  final Tempo value;
  final ValueChanged<Tempo> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Wrap(
      spacing: Insets.sm,
      runSpacing: Insets.sm,
      children: [
        for (final tempo in Tempo.values)
          GestureDetector(
            onTap: () => onChanged(tempo),
            child: AnimatedContainer(
              duration: Motion.fast,
              curve: Motion.enter,
              padding: const EdgeInsets.symmetric(
                horizontal: Insets.md,
                vertical: Insets.sm + 2,
              ),
              decoration: BoxDecoration(
                color: tempo == value
                    ? tempo.color(colors).withValues(alpha: 0.2)
                    : colors.surface,
                borderRadius: Corners.pillRadius,
                border: Border.all(
                  color: tempo == value
                      ? tempo.color(colors)
                      : colors.border,
                  width: tempo == value ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(tempo.icon, size: 16, color: tempo.color(colors)),
                  const SizedBox(width: Insets.sm),
                  Text(
                    tempo.label,
                    style: context.text.labelMedium?.copyWith(
                      color: tempo == value
                          ? colors.textPrimary
                          : colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _DurationField extends StatelessWidget {
  const _DurationField({
    required this.duration,
    required this.onNudge,
    required this.onPreset,
  });

  final Duration duration;
  final ValueChanged<int> onNudge;
  final ValueChanged<Duration> onPreset;

  static const _presets = [
    Duration(seconds: 30),
    Duration(minutes: 1),
    Duration(minutes: 2),
    Duration(minutes: 5),
    Duration(minutes: 10),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Duration', style: context.text.titleSmall),
        const SizedBox(height: Insets.md),
        Row(
          children: [
            _NudgeButton(icon: Icons.remove_rounded, onTap: () => onNudge(-15)),
            Expanded(
              child: Center(
                child: Text(
                  duration.clock,
                  style: context.text.displaySmall?.copyWith(
                    color: colors.accent,
                  ),
                ),
              ),
            ),
            _NudgeButton(icon: Icons.add_rounded, onTap: () => onNudge(15)),
          ],
        ),
        const SizedBox(height: Insets.lg),
        Wrap(
          spacing: Insets.sm,
          children: [
            for (final preset in _presets)
              ChoiceChip(
                label: Text(preset.compact),
                selected: preset == duration,
                onSelected: (_) => onPreset(preset),
              ),
          ],
        ),
      ],
    );
  }
}

class _NudgeButton extends StatelessWidget {
  const _NudgeButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        width: 52,
        decoration: BoxDecoration(
          color: colors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: colors.border),
        ),
        child: Icon(icon, color: colors.textPrimary),
      ),
    );
  }
}

class _MarkerPicker extends StatelessWidget {
  const _MarkerPicker({required this.value, required this.onChanged});

  final StageMarker value;
  final ValueChanged<StageMarker> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      children: [
        for (final marker in StageMarker.values)
          GestureDetector(
            onTap: () => onChanged(marker),
            child: Container(
              margin: const EdgeInsets.only(bottom: Insets.sm),
              padding: const EdgeInsets.all(Insets.md),
              decoration: BoxDecoration(
                color: marker == value ? colors.accentSoft : colors.surface,
                borderRadius: Corners.cardRadius,
                border: Border.all(
                  color: marker == value ? colors.accent : colors.border,
                ),
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: marker.image(MarkerState.active) == null
                        ? Icon(marker.icon, size: 18, color: colors.textMuted)
                        : Image.asset(
                            marker.image(MarkerState.active)!,
                            filterQuality: FilterQuality.medium,
                          ),
                  ),
                  const SizedBox(width: Insets.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(marker.label, style: context.text.labelLarge),
                        Text(
                          marker.description,
                          style: context.text.bodySmall?.copyWith(
                            color: colors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (marker == value)
                    Icon(Icons.check_circle_rounded, color: colors.accent),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
