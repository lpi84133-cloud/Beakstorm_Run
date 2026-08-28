import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/assets/app_images.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/beak_progress_bar.dart';

/// Launch screen. Purely presentational: it renders whatever progress it is
/// handed and owns no timers of its own.
///
/// Two pieces of launch art ship with the app, so the layout picks the one that
/// matches the current aspect ratio instead of stretching a portrait image
/// across a wide screen.
class StartupScreen extends StatelessWidget {
  const StartupScreen({
    super.key,
    required this.progress,
    required this.label,
  });

  final double progress;
  final String label;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Palette.navy900,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= constraints.maxHeight;

            return Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  wide ? AppImages.launchLandscape : AppImages.launchPortrait,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                ),
                const _BottomScrim(),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: SafeArea(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        wide ? Insets.xxxl : Insets.xxl,
                        Insets.xl,
                        wide ? Insets.xxxl : Insets.xxl,
                        wide ? Insets.xl : Insets.xxl,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: Layout.maxContentWidth,
                        ),
                        child: _ProgressBlock(progress: progress),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _BottomScrim extends StatelessWidget {
  const _BottomScrim();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.center,
          end: Alignment.bottomCenter,
          colors: [Color(0x00000000), Color(0x730E1A2C)],
        ),
      ),
    );
  }
}

/// The artwork is bright and busy at the bottom, so the readout sits on its own
/// frosted panel rather than relying on a scrim for contrast.
class _ProgressBlock extends StatelessWidget {
  const _ProgressBlock({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.all(Corners.lg),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.fromLTRB(
            Insets.xl,
            Insets.lg,
            Insets.xl,
            Insets.lg,
          ),
          decoration: BoxDecoration(
            color: Palette.navy900.withValues(alpha: 0.78),
            borderRadius: const BorderRadius.all(Corners.lg),
            border: Border.all(color: const Color(0x2EFFFFFF)),
          ),
          child: _ProgressReadout(progress: progress),
        ),
      ),
    );
  }
}

class _ProgressReadout extends StatelessWidget {
  const _ProgressReadout({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    // Floor rather than round, so 100 appears only when the work is truly done.
    final percent = (progress.clamp(0.0, 1.0) * 100).floor();

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$percent',
              style: const TextStyle(
                fontFamily: kFontFamily,
                fontSize: 34,
                fontWeight: FontWeight.w800,
                height: 1,
                letterSpacing: -1,
                color: Palette.cream50,
                fontFeatures: kTabularFigures,
              ),
            ),
            const SizedBox(width: 2),
            const Text(
              '%',
              style: TextStyle(
                fontFamily: kFontFamily,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Palette.yellow500,
              ),
            ),
            const SizedBox(width: Insets.lg),
            const Expanded(
              child: Text(
                'LOADING',
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: kFontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.9,
                  color: Color(0xFFBFC9DA),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: Insets.md),
        BeakProgressBar(
          value: progress,
          thickness: 14,
          trackColor: Colors.transparent,
        ),
      ],
    );
  }
}
