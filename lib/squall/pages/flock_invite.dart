import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/beak_button.dart';
import '../config/gale_config.dart';
import '../infra/perch_vault.dart';
import '../infra/wing_pulse.dart';

class FlockInvite extends StatefulWidget {
  const FlockInvite({
    super.key,
    required this.vault,
    required this.notifications,
    required this.nextBuilder,
    this.onTokenReady,
  });

  final PerchVault vault;
  final WingPulse notifications;
  final WidgetBuilder nextBuilder;
  final Future<void> Function(String token)? onTokenReady;

  @override
  State<FlockInvite> createState() => _FlockInviteState();
}

class _FlockInviteState extends State<FlockInvite> {
  bool _working = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  Future<void> _accept() async {
    if (_working) return;
    setState(() => _working = true);
    final granted = await widget.notifications.askPermission();
    final token = widget.notifications.token;
    if (granted && token != null && token.isNotEmpty) {
      await widget.onTokenReady?.call(token);
    }
    if (!granted) await _snooze();
    _continue();
  }

  Future<void> _skip() async {
    if (_working) return;
    setState(() => _working = true);
    await _snooze();
    _continue();
  }

  Future<void> _snooze() {
    final until =
        DateTime.now().millisecondsSinceEpoch ~/ 1000 +
        GaleConfig.pushSnoozeSeconds;
    return widget.vault.snoozePushInvite(until);
  }

  void _continue() {
    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute<void>(builder: widget.nextBuilder));
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final landscape = media.orientation == Orientation.landscape;
    final background = landscape
        ? 'assets/Beakstorm_Run_APPLICATION_additional_assets/'
              'Horizontal_Notifications_Screen.webp'
        : 'assets/Beakstorm_Run_APPLICATION_additional_assets/'
              'Vertical_Notifications_Screen.webp';

    Widget body = Stack(
      fit: StackFit.expand,
      children: <Widget>[
        Image.asset(
          background,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
        ),
        landscape ? _landscapeActions() : _portraitActions(media.size.width),
      ],
    );

    if (landscape) {
      body = MediaQuery(
        data: media.copyWith(
          padding: EdgeInsets.zero,
          viewPadding: EdgeInsets.zero,
          viewInsets: EdgeInsets.zero,
        ),
        child: body,
      );
    }

    return Theme(
      data: AppTheme.dark(),
      child: Scaffold(
        backgroundColor: Colors.black,
        resizeToAvoidBottomInset: false,
        body: body,
      ),
    );
  }

  Widget _portraitActions(double screenWidth) {
    final width = (screenWidth * 0.78).clamp(260.0, 420.0);
    return Align(
      alignment: const Alignment(0, 0.88),
      child: SizedBox(
        width: width,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            BeakButton(
              label: 'Accept',
              onPressed: _working ? null : _accept,
            ),
            const SizedBox(height: 16),
            BeakButton(
              label: 'Skip',
              variant: BeakButtonVariant.secondary,
              onPressed: _working ? null : _skip,
            ),
          ],
        ),
      ),
    );
  }

  Widget _landscapeActions() {
    return Align(
      alignment: const Alignment(0, 0.94),
      child: FractionallySizedBox(
        widthFactor: 0.62,
        child: Row(
          children: <Widget>[
            Expanded(
              child: BeakButton(
                label: 'Accept',
                onPressed: _working ? null : _accept,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: BeakButton(
                label: 'Skip',
                variant: BeakButtonVariant.secondary,
                onPressed: _working ? null : _skip,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
