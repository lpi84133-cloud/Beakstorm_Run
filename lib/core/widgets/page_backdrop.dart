import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Artwork bleeding from the top of a screen into the canvas colour.
///
/// The illustrations are the app's identity, so sections open on one instead of
/// a flat header; the gradient guarantees text contrast whatever the image does.
class PageBackdrop extends StatelessWidget {
  const PageBackdrop({
    super.key,
    required this.image,
    required this.child,
    this.height = 300,
    this.opacity = 0.55,
  });

  final String image;
  final Widget child;
  final double height;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: height,
          child: Opacity(
            opacity: opacity,
            child: ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.white, Colors.transparent],
                stops: [0, 0.45, 1],
              ).createShader(bounds),
              blendMode: BlendMode.dstIn,
              child: Image.asset(
                image,
                fit: BoxFit.cover,
                alignment: Alignment.topCenter,
                filterQuality: FilterQuality.medium,
              ),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colors.canvas.withValues(alpha: 0.35),
                  colors.canvas.withValues(alpha: 0.75),
                  colors.canvas,
                ],
                stops: const [0, 0.55, 1],
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
