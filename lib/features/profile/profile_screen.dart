import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../app/app_shell.dart';
import '../../app/router.dart';
import '../../core/assets/app_images.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/duration_format.dart';
import '../../core/widgets/beak_card.dart';
import '../../core/widgets/page_backdrop.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/stat_tile.dart';
import '../../data/session_repository.dart';
import '../../domain/statistics.dart';
import '../legal/legal_screen.dart';
import 'profile_controller.dart';

/// Who is running, what they are aiming for this week, and how the app behaves.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final TextEditingController _name = TextEditingController(
    text: ref.read(profileControllerProvider).name,
  );

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar(ImageSource source) async {
    final picker = ImagePicker();

    try {
      final file = await picker.pickImage(
        source: source,
        maxWidth: 720,
        maxHeight: 720,
        imageQuality: 88,
      );
      if (file == null) return;

      await ref.read(profileControllerProvider.notifier).setAvatar(file.path);
    } on PlatformException catch (error) {
      if (!mounted) return;

      // Happens when access was declined in Settings; say so plainly instead of
      // failing silently.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            source == ImageSource.camera
                ? 'The camera is not available. You can allow access in '
                      'Settings, or pick a photo instead.'
                : 'Photos are not available. You can allow access in Settings.',
          ),
        ),
      );
      // dart format off
      assert(() { debugPrint('avatar picking failed: $error'); return true; }());
      // dart format on
    }
  }

  Future<void> _avatarOptions() async {
    final hasAvatar = ref.read(profileControllerProvider).avatarPath != null;

    await showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      backgroundColor: context.colors.canvasElevated,
      shape: const RoundedRectangleBorder(borderRadius: Corners.sheetRadius),
      builder: (sheet) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.of(sheet).pop();
                _pickAvatar(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from library'),
              onTap: () {
                Navigator.of(sheet).pop();
                _pickAvatar(ImageSource.gallery);
              },
            ),
            if (hasAvatar)
              ListTile(
                leading: Icon(
                  Icons.delete_outline_rounded,
                  color: context.colors.danger,
                ),
                title: const Text('Remove photo'),
                onTap: () {
                  Navigator.of(sheet).pop();
                  ref.read(profileControllerProvider.notifier).removeAvatar();
                },
              ),
            const SizedBox(height: Insets.md),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileControllerProvider);
    final controller = ref.read(profileControllerProvider.notifier);
    final stats =
        ref.watch(statisticsProvider(StatsRange.week)).value ??
        WorkoutStats.empty(StatsRange.week);

    return Scaffold(
      body: PageBackdrop(
        image: AppImages.track,
        height: 240,
        child: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: Layout.maxContentWidth,
              ),
              child: ListView(
                padding: EdgeInsets.fromLTRB(
                  Insets.xl,
                  Insets.lg,
                  Insets.xl,
                  dockClearance(context),
                ),
                children: [
                  _Identity(
                    avatarPath: profile.avatarPath,
                    name: _name,
                    onAvatarTap: _avatarOptions,
                    onNameChanged: controller.setName,
                  ),
                  const SizedBox(height: Insets.xxl),
                  _WeeklyGoal(
                    goalMinutes: profile.weeklyGoalMinutes,
                    doneMinutes: stats.totalTime.inMinutes,
                    onChanged: controller.setWeeklyGoal,
                  ),
                  const SizedBox(height: Insets.xxl),
                  const SectionHeader(
                    title: 'Preferences',
                    eyebrow: 'How the app behaves',
                  ),
                  const SizedBox(height: Insets.lg),
                  BeakCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: Insets.lg,
                      vertical: Insets.sm,
                    ),
                    child: Column(
                      children: [
                        _ThemeRow(
                          value: profile.themeMode,
                          onChanged: controller.setThemeMode,
                        ),
                        const Divider(height: 1),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          value: profile.soundEnabled,
                          onChanged: controller.setSoundEnabled,
                          title: const Text('Sound cues'),
                          subtitle: const Text(
                            'A short tone when a stage changes',
                          ),
                        ),
                        const Divider(height: 1),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          value: profile.hapticsEnabled,
                          onChanged: controller.setHapticsEnabled,
                          title: const Text('Vibration'),
                          subtitle: const Text(
                            'A tap you can feel with the phone in a pocket',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: Insets.xxl),
                  const SectionHeader(
                    title: 'About',
                    eyebrow: 'Works without a connection',
                  ),
                  const SizedBox(height: Insets.lg),
                  const _AboutCard(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AboutCard extends StatefulWidget {
  const _AboutCard();

  @override
  State<_AboutCard> createState() => _AboutCardState();
}

class _AboutCardState extends State<_AboutCard> {
  String _version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) {
        setState(() => _version = '${info.version} (${info.buildNumber})');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return BeakCard(
      padding: const EdgeInsets.symmetric(horizontal: Insets.lg),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.lock_outline_rounded),
            title: const Text('Privacy Policy'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(AppRoute.legal(LegalDocument.privacy)),
          ),
          const Divider(height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.help_outline_rounded),
            title: const Text('Support and FAQ'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(AppRoute.legal(LegalDocument.support)),
          ),
          const Divider(height: 1),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.info_outline_rounded),
            title: const Text('Version'),
            trailing: Text(
              _version,
              style: context.text.bodyMedium?.copyWith(color: colors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _Identity extends StatelessWidget {
  const _Identity({
    required this.avatarPath,
    required this.name,
    required this.onAvatarTap,
    required this.onNameChanged,
  });

  final String? avatarPath;
  final TextEditingController name;
  final VoidCallback onAvatarTap;
  final ValueChanged<String> onNameChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: onAvatarTap,
          child: Container(
            height: 84,
            width: 84,
            decoration: BoxDecoration(
              color: colors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colors.borderStrong, width: 2),
            ),
            clipBehavior: Clip.antiAlias,
            child: avatarPath == null
                ? Icon(
                    Icons.add_a_photo_outlined,
                    color: colors.textMuted,
                    size: 26,
                  )
                : Image.file(
                    File(avatarPath!),
                    fit: BoxFit.cover,
                    // The file can vanish if the user clears app data by hand.
                    errorBuilder: (context, _, _) =>
                        Icon(Icons.person_rounded, color: colors.textMuted),
                  ),
          ),
        ),
        const SizedBox(width: Insets.lg),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'YOUR NAME',
                style: context.text.labelSmall?.copyWith(
                  color: colors.textMuted,
                ),
              ),
              TextField(
                controller: name,
                maxLength: 24,
                textCapitalization: TextCapitalization.words,
                style: context.text.headlineSmall,
                decoration: const InputDecoration(
                  hintText: 'Runner',
                  counterText: '',
                  filled: false,
                  isDense: true,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: onNameChanged,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WeeklyGoal extends StatelessWidget {
  const _WeeklyGoal({
    required this.goalMinutes,
    required this.doneMinutes,
    required this.onChanged,
  });

  final int goalMinutes;
  final int doneMinutes;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final share = goalMinutes == 0
        ? 0.0
        : (doneMinutes / goalMinutes).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Weekly goal', eyebrow: 'Minutes moving'),
        const SizedBox(height: Insets.lg),
        BeakCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  StatTile(
                    value: '$doneMinutes',
                    unit: 'min',
                    caption: 'Done this week',
                    accent: share >= 1,
                  ),
                  StatTile(
                    value: '$goalMinutes',
                    unit: 'min',
                    caption: 'Goal',
                    alignment: CrossAxisAlignment.end,
                  ),
                ],
              ),
              const SizedBox(height: Insets.lg),
              ClipRRect(
                borderRadius: Corners.pillRadius,
                child: LinearProgressIndicator(
                  value: share,
                  minHeight: 8,
                  backgroundColor: colors.surfaceMuted,
                  valueColor: AlwaysStoppedAnimation(colors.accent),
                ),
              ),
              const SizedBox(height: Insets.sm),
              Text(
                share >= 1
                    ? 'Goal reached. Anything else this week is a bonus.'
                    : '${Duration(minutes: goalMinutes - doneMinutes).compact} left',
                style: context.text.bodySmall?.copyWith(
                  color: colors.textMuted,
                ),
              ),
              const SizedBox(height: Insets.md),
              Slider.adaptive(
                value: goalMinutes.toDouble(),
                min: 30,
                max: 420,
                divisions: 26,
                label: '$goalMinutes min',
                onChanged: (value) => onChanged(value.round()),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThemeRow extends StatelessWidget {
  const _ThemeRow({required this.value, required this.onChanged});

  final ThemeMode value;
  final ValueChanged<ThemeMode> onChanged;

  static const _labels = {
    ThemeMode.system: 'System',
    ThemeMode.light: 'Light',
    ThemeMode.dark: 'Dark',
  };

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: const Text('Appearance'),
      trailing: DropdownButton<ThemeMode>(
        value: value,
        underline: const SizedBox.shrink(),
        borderRadius: Corners.cardRadius,
        items: [
          for (final entry in _labels.entries)
            DropdownMenuItem(value: entry.key, child: Text(entry.value)),
        ],
        onChanged: (mode) => onChanged(mode ?? ThemeMode.dark),
      ),
    );
  }
}
