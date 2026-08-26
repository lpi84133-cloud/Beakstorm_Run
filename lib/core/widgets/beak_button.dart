import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_theme.dart';

enum BeakButtonVariant { primary, secondary, ghost, danger }

enum BeakButtonSize { regular, compact }

/// Primary action control. Presses shrink slightly and fire a light haptic so
/// the button reads as physical, matching the moulded illustration style.
class BeakButton extends StatefulWidget {
  const BeakButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = BeakButtonVariant.primary,
    this.size = BeakButtonSize.regular,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final BeakButtonVariant variant;
  final BeakButtonSize size;
  final bool expand;

  @override
  State<BeakButton> createState() => _BeakButtonState();
}

class _BeakButtonState extends State<BeakButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onPressed!.call();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final compact = widget.size == BeakButtonSize.compact;

    final isPrimary = widget.variant == BeakButtonVariant.primary;

    final (background, foreground, border) = switch (widget.variant) {
      BeakButtonVariant.primary => (colors.accent, colors.onAccent, null),
      BeakButtonVariant.secondary => (
        colors.surfaceMuted,
        colors.textPrimary,
        colors.border,
      ),
      BeakButtonVariant.ghost => (
        Colors.transparent,
        colors.textSecondary,
        colors.border,
      ),
      BeakButtonVariant.danger => (colors.danger, Palette.white, null),
    };

    final content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.icon != null) ...[
          Icon(widget.icon, size: compact ? 17 : 19, color: foreground),
          const SizedBox(width: Insets.sm),
        ],
        Flexible(
          child: Text(
            widget.label,
            overflow: TextOverflow.ellipsis,
            style: (compact ? context.text.labelMedium : context.text.labelLarge)
                ?.copyWith(color: foreground),
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: _enabled ? (_) => _setPressed(true) : null,
        onTapUp: _enabled ? (_) => _setPressed(false) : null,
        onTapCancel: _enabled ? () => _setPressed(false) : null,
        onTap: _enabled ? _handleTap : null,
        child: AnimatedScale(
          scale: _pressed ? 0.97 : 1,
          duration: Motion.instant,
          curve: Motion.enter,
          child: AnimatedOpacity(
            opacity: _enabled ? 1 : 0.45,
            duration: Motion.fast,
            child: Container(
              height: compact ? 42 : 54,
              padding: EdgeInsets.symmetric(
                horizontal: compact ? Insets.lg : Insets.xl,
              ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isPrimary ? null : background,
                gradient: isPrimary ? colors.accentSweep : null,
                borderRadius: Corners.pillRadius,
                border: border == null ? null : Border.all(color: border),
                boxShadow: isPrimary && _enabled
                    ? [
                        BoxShadow(
                          color: colors.accent.withValues(alpha: 0.34),
                          blurRadius: 26,
                          offset: const Offset(0, 10),
                          spreadRadius: -8,
                        ),
                      ]
                    : null,
              ),
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}
