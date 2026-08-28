import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'squall/config/gale_config.dart';
import 'squall/infra/gale_agent.dart';
import 'squall/infra/gale_exchange.dart';
import 'squall/infra/perch_vault.dart';
import 'squall/infra/sky_probe.dart';
import 'squall/infra/wind_attribution.dart';
import 'squall/infra/wing_pulse.dart';
import 'squall/squall_coordinator.dart';
import 'squall/squall_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final vault = PerchVault();
  final agent = GaleAgent();
  await Future.wait<void>(<Future<void>>[vault.initialize(), agent.prepare()]);

  galeTrace(
    () =>
        '[GALE.BOOT] credentialsReady=${GaleConfig.grayCredentialsReady} '
        'endpoint=${GaleConfig.endpoint} '
        'afKeyLen=${GaleConfig.appsFlyerKey.length} '
        'fbNum=${GaleConfig.firebaseProjectNumber}',
  );

  var productionServicesReady = false;
  if (GaleConfig.grayCredentialsReady) {
    try {
      await Firebase.initializeApp();
      productionServicesReady = true;
      galeTrace(() => '[GALE.BOOT] Firebase.initializeApp OK');
    } catch (error) {
      galeTrace(() => '[GALE.BOOT] Firebase.initializeApp failed: $error');
    }
    if (productionServicesReady) {
      try {
        await FirebaseAppCheck.instance.activate(
          providerApple: kDebugMode
              ? const AppleDebugProvider()
              : const AppleAppAttestWithDeviceCheckFallbackProvider(),
        );
      } catch (error) {
        galeTrace(() => '[GALE.BOOT] AppCheck skipped: $error');
      }
    }
  } else {
    galeTrace(
      () =>
          '[GALE.BOOT] gray gate DISABLED — missing credentials. White part only.',
    );
  }

  final probe = SkyProbe();
  final notifications = WingPulse(vault, enabled: productionServicesReady);
  final attribution = WindAttribution(agent);
  final coordinator = SquallCoordinator(
    vault: vault,
    probe: probe,
    attribution: attribution,
    exchange: GaleExchange(agent, vault),
    notifications: notifications,
    agent: agent,
    runtimeEnabled: GaleConfig.grayCredentialsReady,
  );

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0E1A2C),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  await SystemChrome.setPreferredOrientations(const <DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(ProviderScope(child: SquallShell(coordinator: coordinator)));
}
