import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/app_shell.dart';
import '../../app/router.dart';
import '../../core/assets/app_images.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/duration_format.dart';
import '../../core/utils/id.dart';
import '../../core/widgets/beak_button.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/widgets/page_backdrop.dart';
import '../../core/widgets/section_header.dart';
import '../../data/workout_repository.dart';
import '../../domain/workout.dart';
import '../../domain/workout_stage.dart';
import '../../domain/workout_templates.dart';
import 'widgets/template_card.dart';
import 'widgets/workout_card.dart';

/// Every route saved on the device, newest edit first.
class RoutesScreen extends ConsumerWidget {
  const RoutesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workouts = ref.watch(savedWorkoutsProvider);

    return Scaffold(
      body: PageBackdrop(
        image: AppImages.route,
        height: 260,
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: Layout.maxContentWidth,
              ),
              child: workouts.when(
                loading: () =>
                    const Center(child: CircularProgressIndicator.adaptive()),
                error: (error, _) => _LoadFailure(error: error),
                data: (list) => list.isEmpty
                    ? const _NoRoutes()
                    : _RouteList(workouts: list),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RouteList extends ConsumerWidget {
  const _RouteList({required this.workouts});

  final List<Workout> workouts;

  Future<bool> _confirmDelete(BuildContext context, Workout workout) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete this route?'),
        content: Text(
          '"${workout.name}" will be removed from this device. '
          'Runs already recorded in your history are kept.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(
              foregroundColor: context.colors.danger,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  Future<void> _duplicate(WidgetRef ref, Workout workout) async {
    final now = DateTime.now();

    await ref
        .read(workoutRepositoryProvider)
        .save(
          Workout(
            id: newId(),
            name: '${workout.name} copy',
            templateKey: workout.templateKey,
            createdAt: now,
            updatedAt: now,
            stages: [
              for (final stage in workout.stages)
                WorkoutStage(
                  id: newId(),
                  tempo: stage.tempo,
                  duration: stage.duration,
                  marker: stage.marker,
                  note: stage.note,
                ),
            ],
          ),
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = workouts.fold(
      Duration.zero,
      (sum, workout) => sum + workout.totalDuration,
    );

    return ListView.separated(
      padding: EdgeInsets.fromLTRB(
        Insets.xl,
        Insets.lg,
        Insets.xl,
        dockClearance(context),
      ),
      itemCount: workouts.length + 2,
      separatorBuilder: (_, _) => const SizedBox(height: Insets.md),
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.only(bottom: Insets.sm),
            child: SectionHeader(
              title: 'Your routes',
              eyebrow:
                  '${workouts.length} saved  ·  ${total.compact} in total',
              actionLabel: 'New',
              onAction: () => context.push(AppRoute.builder),
            ),
          );
        }

        if (index == workouts.length + 1) {
          return Padding(
            padding: const EdgeInsets.only(top: Insets.lg),
            child: BeakButton(
              label: 'Build a new route',
              icon: Icons.add_rounded,
              variant: BeakButtonVariant.secondary,
              onPressed: () => context.push(AppRoute.builder),
            ),
          );
        }

        final workout = workouts[index - 1];

        return Dismissible(
          key: ValueKey(workout.id),
          direction: DismissDirection.endToStart,
          background: const _DeleteBackground(),
          confirmDismiss: (_) => _confirmDelete(context, workout),
          onDismissed: (_) =>
              ref.read(workoutRepositoryProvider).delete(workout.id),
          child: WorkoutCard(
            workout: workout,
            onTap: () => context.push(AppRoute.edit(workout.id)),
            trailing: _RouteMenu(
              onStart: () => context.push(AppRoute.run(workout.id)),
              onEdit: () => context.push(AppRoute.edit(workout.id)),
              onDuplicate: () => _duplicate(ref, workout),
              onDelete: () async {
                if (await _confirmDelete(context, workout)) {
                  await ref.read(workoutRepositoryProvider).delete(workout.id);
                }
              },
            ),
          ),
        );
      },
    );
  }
}

class _RouteMenu extends StatelessWidget {
  const _RouteMenu({
    required this.onStart,
    required this.onEdit,
    required this.onDuplicate,
    required this.onDelete,
  });

  final VoidCallback onStart;
  final VoidCallback onEdit;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return PopupMenuButton<void Function()>(
      onSelected: (action) => action(),
      icon: Icon(Icons.more_horiz_rounded, color: colors.textMuted),
      color: colors.canvasElevated,
      shape: const RoundedRectangleBorder(borderRadius: Corners.cardRadius),
      itemBuilder: (context) => [
        PopupMenuItem(value: onStart, child: const Text('Start run')),
        PopupMenuItem(value: onEdit, child: const Text('Edit')),
        PopupMenuItem(value: onDuplicate, child: const Text('Duplicate')),
        PopupMenuItem(
          value: onDelete,
          child: Text('Delete', style: TextStyle(color: colors.danger)),
        ),
      ],
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  const _DeleteBackground();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: Insets.xl),
      decoration: BoxDecoration(
        color: colors.danger.withValues(alpha: 0.16),
        borderRadius: Corners.cardRadius,
      ),
      child: Icon(Icons.delete_outline_rounded, color: colors.danger),
    );
  }
}

class _NoRoutes extends StatelessWidget {
  const _NoRoutes();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.fromLTRB(
        Insets.xl,
        Insets.xxl,
        Insets.xl,
        dockClearance(context),
      ),
      children: [
        EmptyState(
          title: 'Nothing saved yet',
          message:
              'Start from one of the structures below, or build a route stage '
              'by stage.',
          actionLabel: 'Build a route',
          onAction: () => context.push(AppRoute.builder),
        ),
        const SizedBox(height: Insets.xxl),
        const SectionHeader(title: 'Ready to use', eyebrow: 'Built in'),
        const SizedBox(height: Insets.lg),
        for (final template in workoutTemplates)
          Padding(
            padding: const EdgeInsets.only(bottom: Insets.md),
            child: TemplateCard(
              template: template,
              width: double.infinity,
              onTap: () => context.push(AppRoute.fromTemplate(template.key)),
            ),
          ),
      ],
    );
  }
}

class _LoadFailure extends StatelessWidget {
  const _LoadFailure({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: Insets.page,
      child: Center(
        child: Text(
          'Your routes could not be opened.\n$error',
          textAlign: TextAlign.center,
          style: context.text.bodyMedium,
        ),
      ),
    );
  }
}
