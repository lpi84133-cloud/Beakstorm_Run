import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Phones stay portrait; larger screens keep landscape available.
  final isTablet =
      WidgetsBinding.instance.platformDispatcher.views.first.physicalSize
              .shortestSide /
          WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio >=
      600;

  await SystemChrome.setPreferredOrientations(
    isTablet
        ? const [
            DeviceOrientation.portraitUp,
            DeviceOrientation.portraitDown,
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight,
          ]
        : const [DeviceOrientation.portraitUp],
  );

  runApp(const ProviderScope(child: BeakstormRunApp()));
}
