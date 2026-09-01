import 'dart:async';
import 'dart:io';

import 'config/gale_config.dart';
import 'core/trail_models.dart';
import 'infra/gale_agent.dart';
import 'infra/gale_exchange.dart';
import 'infra/perch_vault.dart';
import 'infra/sky_probe.dart';
import 'infra/tap_trail.dart';
import 'infra/wind_attribution.dart';
import 'infra/wing_pulse.dart';

class SquallCoordinator {
  SquallCoordinator({
    required this.vault,
    required this.probe,
    required this.attribution,
    required this.exchange,
    required this.notifications,
    required this.agent,
    required this.runtimeEnabled,
  });

  final PerchVault vault;
  final SkyProbe probe;
  final WindAttribution attribution;
  final GaleExchange exchange;
  final WingPulse notifications;
  final GaleAgent agent;
  final bool runtimeEnabled;

  bool get enabled => runtimeEnabled && GaleConfig.grayCredentialsReady;

  Future<TrailTarget>? _decideFuture;

  Future<TrailTarget> decide({
    required void Function(double value) onProgress,
  }) => _decideFuture ??= _decide(
    onProgress: onProgress,
  ).whenComplete(() => _decideFuture = null);

  Future<TrailTarget> _decide({
    required void Function(double value) onProgress,
  }) async {
    if (!enabled) {
      galeTrace(
        () =>
            '[GALE.SQUALL] gate disabled runtime=$runtimeEnabled '
            'creds=${GaleConfig.grayCredentialsReady}',
      );
      onProgress(1);
      return const NativeTrail();
    }

    galeTrace(() => '[GALE.SQUALL] decide start route=${vault.route}');

    notifications.onTokenChanged = _refreshForToken;
    final coldRoute = await TapTrailReader.consume();
    if (coldRoute != null) {
      notifications.markColdRouteConsumed();
      await vault.saveRoute(TrailKind.portal);
      await vault.consumePushUrl();
      unawaited(_backgroundDispatch());
      onProgress(1);
      return PortalTrail(coldRoute, coldLaunch: true);
    }

    onProgress(0.12);
    return switch (vault.route) {
      TrailKind.first => _firstDecision(onProgress),
      TrailKind.portal => _returningPortal(onProgress),
      TrailKind.native => _returningNative(onProgress),
    };
  }

  Future<TrailTarget> _firstDecision(void Function(double) progress) async {
    attribution.recycleForRetry();

    if (!await probe.hasInterface()) {
      galeTrace(() => '[GALE.SQUALL] first: no interface → offline');
      return const OfflineTrail(returnToNative: false);
    }

    Future<bool> waitWhileInterfaceUp(Future<void> work) async {
      var done = false;
      final tracked = work.whenComplete(() => done = true);
      while (!done) {
        if (!await probe.hasInterface()) return false;
        await Future.any<void>(<Future<void>>[
          tracked,
          Future<void>.delayed(const Duration(milliseconds: 320)),
        ]);
      }
      return probe.hasInterface();
    }

    unawaited(
      Future<void>(() async {
        try {
          await notifications.boot();
        } catch (_) {}
      }),
    );
    if (!await waitWhileInterfaceUp(attribution.ensureTrackingPrompt())) {
      galeTrace(() => '[GALE.SQUALL] first: dropped during ATT → offline');
      return const OfflineTrail(returnToNative: false);
    }
    if (!await waitWhileInterfaceUp(
      attribution.awaitSignals(
        installTimeout: const Duration(milliseconds: 12800),
      ),
    )) {
      galeTrace(() => '[GALE.SQUALL] first: dropped during AF → offline');
      return const OfflineTrail(returnToNative: false);
    }

    GaleReply? reply;
    if (!await waitWhileInterfaceUp(
      _requestConfig().then((value) => reply = value),
    )) {
      galeTrace(() => '[GALE.SQUALL] first: dropped during config → offline');
      return const OfflineTrail(returnToNative: false);
    }
    final resolved = reply ?? GaleReply.rejected('network_failure');
    galeTrace(
      () =>
          '[GALE.SQUALL] first: config hasDest=${resolved.hasDestination} '
          'authoritative=${resolved.isAuthoritative} reason=${resolved.reason} '
          'url=${resolved.url}',
    );
    if (resolved.hasDestination) {
      await vault.saveRoute(TrailKind.portal);
      return PortalTrail(resolved.url!);
    }
    if (!resolved.isAuthoritative || !await probe.hasInterface()) {
      galeTrace(
        () => '[GALE.SQUALL] first: no authoritative config → stay undecided',
      );
      return const OfflineTrail(returnToNative: false);
    }
    // 404 without a real AF conversion is not "organic" — it is a Retry
    // after OneLink + offline that posted an empty body. Stay undecided.
    if (!attribution.hasUsableConversion) {
      galeTrace(
        () =>
            '[GALE.SQUALL] first: config empty but AF not ready → stay undecided',
      );
      return const OfflineTrail(returnToNative: false);
    }
    await vault.saveRoute(TrailKind.native);
    return const NativeTrail();
  }

  Future<TrailTarget> _returningPortal(void Function(double) progress) async {
    if (!await probe.hasInterface()) {
      return const OfflineTrail(returnToNative: false);
    }
    final pending = await vault.consumePushUrl();
    if (pending != null && pending.isNotEmpty) {
      progress(1);
      return PortalTrail(pending, coldLaunch: true);
    }
    final cached = await vault.savedUrl();
    if (cached != null && !vault.cachedUrlExpired) {
      progress(1);
      return PortalTrail(cached);
    }

    await Future.wait<void>(<Future<void>>[
      notifications.boot(),
      attribution.start(),
    ]);
    if (!await probe.canReachNetwork()) {
      return const OfflineTrail(returnToNative: false);
    }
    progress(0.62);
    await attribution.awaitSignals(
      installTimeout: const Duration(
        milliseconds: GaleConfig.installSignalTimeoutMs,
      ),
    );
    final reply = await _requestConfig();
    progress(1);
    if (reply.hasDestination) return PortalTrail(reply.url!);
    if (cached != null && !vault.cachedUrlExpired) return PortalTrail(cached);
    return const OfflineTrail(returnToNative: false);
  }

  Future<TrailTarget> _returningNative(void Function(double) progress) async {
    if (!await probe.hasInterface()) {
      progress(1);
      return const NativeTrail();
    }
    await Future.wait<void>(<Future<void>>[
      notifications.boot(),
      attribution.start(),
    ]);
    if (!await probe.canReachNetwork()) {
      progress(1);
      return const NativeTrail();
    }
    progress(0.55);
    await attribution.awaitSignals();
    final reply = await _requestConfig();
    progress(1);
    if (!reply.hasDestination) return const NativeTrail();
    galeTrace(() => '[GALE.SQUALL] mode-flip native → portal');
    await vault.saveRoute(TrailKind.portal);
    return PortalTrail(reply.url!);
  }

  Future<GaleReply> _requestConfig({String? token}) async {
    final body = await attribution.compose(
      locale: Platform.localeName.replaceAll('-', '_'),
      pushToken: token ?? notifications.token,
    );
    return exchange.request(body);
  }

  Future<void> _backgroundDispatch() async {
    try {
      await Future.wait<void>(<Future<void>>[
        notifications.boot(),
        attribution.awaitSignals(),
      ]);
      await _requestConfig();
    } catch (_) {}
  }

  Future<void> _refreshForToken(String token) async {
    try {
      await _requestConfig(token: token);
    } catch (_) {}
  }
}
