import 'package:beakstorm_run/app/app.dart';
import 'package:beakstorm_run/core/theme/app_theme.dart';
import 'package:beakstorm_run/features/startup/startup_controller.dart';
import 'package:beakstorm_run/features/startup/startup_screen.dart';
import 'package:beakstorm_run/features/startup/startup_task.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('app opens on the launch screen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          startupTasksProvider.overrideWithValue([
            StartupTask(
              label: 'ready',
              weight: 1,
              run: (ref, report) async => report(1),
            ),
          ]),
          startupTaskTimeoutProvider.overrideWithValue(
            const Duration(milliseconds: 10),
          ),
        ],
        child: const BeakstormRunApp(),
      ),
    );

    expect(find.byType(StartupScreen), findsOneWidget);
    expect(find.text('Runs fully offline on this device.'), findsOneWidget);

    await tester.pumpAndSettle();
  });

  testWidgets('launch screen starts empty and never rounds up to 100', (
    tester,
  ) async {
    Widget wrap(double progress) => MaterialApp(
      theme: AppTheme.dark(),
      home: StartupScreen(progress: progress, label: 'Getting ready'),
    );

    await tester.pumpWidget(wrap(0));
    expect(find.text('0'), findsOneWidget);

    await tester.pumpWidget(wrap(0.999));
    expect(find.text('99'), findsOneWidget);
    expect(find.text('100'), findsNothing);

    await tester.pumpWidget(wrap(1));
    expect(find.text('100'), findsOneWidget);
  });

  testWidgets('launch screen picks the artwork that fits the screen shape', (
    tester,
  ) async {
    String assetOf(WidgetTester tester) {
      final image = tester.widget<Image>(find.byType(Image).first);
      return (image.image as AssetImage).assetName;
    }

    Widget wrap() => MaterialApp(
      theme: AppTheme.dark(),
      home: const StartupScreen(progress: 0.5, label: 'Loading'),
    );

    await tester.binding.setSurfaceSize(const Size(390, 844));
    await tester.pumpWidget(wrap());
    expect(assetOf(tester), contains('launch_portrait'));

    await tester.binding.setSurfaceSize(const Size(1180, 820));
    await tester.pumpWidget(wrap());
    await tester.pump();
    expect(assetOf(tester), contains('launch_landscape'));

    addTearDown(() => tester.binding.setSurfaceSize(null));
  });
}
