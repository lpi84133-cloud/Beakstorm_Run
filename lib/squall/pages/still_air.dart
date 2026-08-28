import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_typography.dart';
import '../../core/widgets/beak_button.dart';
import '../infra/sky_probe.dart';

class StillAirPage extends StatefulWidget {
  const StillAirPage({
    super.key,
    required this.probe,
    required this.retryBuilder,
  });

  final SkyProbe probe;
  final WidgetBuilder retryBuilder;

  @override
  State<StillAirPage> createState() => _StillAirPageState();
}

class _StillAirPageState extends State<StillAirPage> {
  bool _checking = false;

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

  Future<void> _retry() async {
    if (_checking) return;
    unawaited(HapticFeedback.lightImpact());
    setState(() => _checking = true);
    bool online = false;
    try {
      online = await widget.probe.canReachNetwork();
    } catch (_) {
      online = false;
    }
    if (!mounted) return;
    if (online) {
      await Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute<void>(builder: widget.retryBuilder));
      return;
    }
    setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.dark(),
      child: Scaffold(
        backgroundColor: Palette.navy900,
        resizeToAvoidBottomInset: false,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final short = constraints.biggest.shortestSide;
            final wide = constraints.maxWidth > constraints.maxHeight;

            final iconSize = (short * (wide ? 0.20 : 0.22)).clamp(56.0, 120.0);
            final titleSize = (short * (wide ? 0.055 : 0.06)).clamp(20.0, 32.0);
            final bodySize = (short * (wide ? 0.032 : 0.036)).clamp(13.0, 18.0);
            final buttonWidth = (constraints.maxWidth * (wide ? 0.44 : 0.72))
                .clamp(240.0, 520.0);
            final gap = short * 0.03;
            final topGap = short * 0.02;

            return Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Palette.navy900,
                    Palette.navy700,
                    Palette.navy500,
                  ],
                  stops: <double>[0.0, 0.55, 1.0],
                ),
              ),
              child: SafeArea(
                minimum: EdgeInsets.symmetric(
                  horizontal: wide ? 24 : 20,
                  vertical: 16,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          Icons.wifi_off_rounded,
                          color: Palette.cream50,
                          size: iconSize,
                        ),
                        SizedBox(height: topGap.clamp(10.0, 24.0)),
                        Text(
                          'NO INTERNET CONNECTION',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: titleSize,
                            fontWeight: FontWeight.w800,
                            color: Palette.cream50,
                            letterSpacing: 0.6,
                            height: 1.15,
                          ),
                        ),
                        SizedBox(height: (topGap * 0.55).clamp(6.0, 14.0)),
                        Text(
                          'Check your connection and try again',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: kFontFamily,
                            fontSize: bodySize,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFFBFC9DA),
                            height: 1.35,
                          ),
                        ),
                        SizedBox(height: gap.clamp(18.0, 34.0)),
                        SizedBox(
                          width: buttonWidth,
                          child: BeakButton(
                            label: _checking ? 'Checking…' : 'Retry',
                            icon: Icons.refresh_rounded,
                            onPressed: _checking ? null : _retry,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
