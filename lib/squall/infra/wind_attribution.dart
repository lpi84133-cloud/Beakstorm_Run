import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:app_tracking_transparency/app_tracking_transparency.dart';
import 'package:appsflyer_sdk/appsflyer_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../config/gale_config.dart';
import 'gale_agent.dart';

void galeTrace(String Function() message) {
  // dart format off
  assert(() { debugPrint(message()); return true; }());
  // dart format on
}

class WindAttribution {
  WindAttribution(this._agent);

  final GaleAgent _agent;
  AppsflyerSdk? _sdk;
  Map<String, dynamic>? _install;
  Map<String, dynamic>? _reopen;
  Map<String, dynamic>? _deepLink;
  Future<void>? _startFuture;
  Future<void>? _attFuture;
  Completer<void> _installReady = Completer<void>();
  Completer<void> _deepLinkReady = Completer<void>();
  int _generation = 0;

  Future<void> start() => _startFuture ??= _start();

  /// True when AppsFlyer already gave a real `af_status` (Organic or paid).
  /// Empty maps / `{status: failure}` / timeouts are NOT usable.
  bool get hasUsableConversion {
    final status = _install?['af_status']?.toString();
    return status != null && status.isNotEmpty;
  }

  /// Paid / OneLink conversion. Must survive an offline Retry — wiping it
  /// and re-initting the SDK often comes back Organic and locks the user
  /// into the white game forever.
  bool get hasPaidConversion {
    final status = _install?['af_status']?.toString();
    return status != null &&
        status.isNotEmpty &&
        status.toLowerCase() != 'organic';
  }

  /// Drop a poisoned in-process SDK after an offline first launch so Retry
  /// can wait for a real conversion instead of replaying `{status: failure}`.
  /// A paid conversion is kept: the native AF singleton already consumed
  /// the OneLink, and a second init usually cannot recover it.
  void recycleForRetry() {
    if (_startFuture == null && _install == null) return;
    if (hasPaidConversion) {
      galeTrace(() => '[GALE.WIND] recycle skipped — paid conversion kept');
      return;
    }
    _generation++;
    _startFuture = null;
    _sdk = null;
    _install = null;
    _reopen = null;
    _deepLink = null;
    if (!_installReady.isCompleted) _installReady.complete();
    if (!_deepLinkReady.isCompleted) _deepLinkReady.complete();
    _installReady = Completer<void>();
    _deepLinkReady = Completer<void>();
  }

  /// Own memoized future — not tied to [start], so a retry after an offline
  /// first launch can still present ATT if the first attempt was lost.
  Future<void> ensureTrackingPrompt() => _attFuture ??= _promptTracking();

  Future<void> _start() async {
    final generation = _generation;
    if (!GaleConfig.grayCredentialsReady) {
      _completeEmpty();
      return;
    }
    try {
      await ensureTrackingPrompt();
      if (generation != _generation) return;
      final sdk = AppsflyerSdk(
        AppsFlyerOptions(
          afDevKey: GaleConfig.appsFlyerKey,
          appId: GaleConfig.iosStoreId,
          showDebug: kDebugMode,
          timeToWaitForATTUserAuthorization: 6,
        ),
      );
      _sdk = sdk;
      sdk.onInstallConversionData(_acceptInstall);
      sdk.onAppOpenAttribution((raw) {
        if (generation != _generation) return;
        _reopen = _flat(raw);
      });
      sdk.onDeepLinking((result) {
        if (generation != _generation) return;
        final event = result.deepLink?.clickEvent;
        if (event != null) _deepLink = Map<String, dynamic>.from(event);
        if (!_deepLinkReady.isCompleted) _deepLinkReady.complete();
      });
      await sdk.initSdk(
        registerConversionDataCallback: true,
        registerOnAppOpenAttributionCallback: true,
        registerOnDeepLinkingCallback: true,
      );
      if (generation != _generation) return;
    } catch (error) {
      galeTrace(() => '[GALE.WIND] initialization failed: $error');
      if (generation == _generation) _completeEmpty();
    }
  }

  Future<void> _promptTracking() async {
    if (!Platform.isIOS) return;
    var status = await AppTrackingTransparency.trackingAuthorizationStatus;
    if (status != TrackingStatus.notDetermined) return;

    await _waitUntilFrontmost();
    await WidgetsBinding.instance.endOfFrame;
    await Future<void>.delayed(
      const Duration(milliseconds: GaleConfig.attPromptDelayMs),
    );
    status = await AppTrackingTransparency.requestTrackingAuthorization();
    if (status == TrackingStatus.notDetermined) {
      await _waitUntilFrontmost();
      await AppTrackingTransparency.requestTrackingAuthorization();
    }
  }

  Future<void> _waitUntilFrontmost() async {
    for (var attempt = 0; attempt < 24; attempt++) {
      final state = WidgetsBinding.instance.lifecycleState;
      if (state == null || state == AppLifecycleState.resumed) return;
      await Future<void>.delayed(const Duration(milliseconds: 90));
    }
  }

  Future<void> _acceptInstall(dynamic raw) async {
    final generation = _generation;
    try {
      final received = _flat(raw);
      final status = received['status']?.toString().toLowerCase();
      final failed =
          status == 'failure' ||
          (received['af_status'] == null && received.containsKey('status'));
      galeTrace(
        () =>
            '[GALE.WIND] conversion status=$status '
            'af_status=${received['af_status']} keys=${received.keys.toList()}',
      );
      if (generation != _generation) return;
      if (failed) {
        _install = <String, dynamic>{};
      } else if (received['af_status'] == 'Organic') {
        await Future<void>.delayed(
          const Duration(seconds: GaleConfig.organicRecheckSeconds),
        );
        if (generation != _generation) return;
        _install = await _fetchGcd() ?? received;
      } else {
        _install = received;
      }
    } catch (error) {
      galeTrace(() => '[GALE.WIND] conversion parse error: $error');
      if (generation != _generation) return;
      _install = <String, dynamic>{};
    } finally {
      if (generation == _generation && !_installReady.isCompleted) {
        _installReady.complete();
      }
    }
  }

  Map<String, dynamic> _flat(dynamic raw) {
    if (raw is! Map) return <String, dynamic>{};
    final map = Map<String, dynamic>.from(raw);
    final payload = map['payload'];
    return payload is Map ? Map<String, dynamic>.from(payload) : map;
  }

  Future<Map<String, dynamic>?> _fetchGcd() async {
    final uid = await appsFlyerId();
    if (uid == null || uid.isEmpty) return null;
    try {
      final uri = Uri.parse(
        '${GaleConfig.gcdBase}${GaleConfig.storeToken}?device_id=$uid',
      );
      final response = await _agent
          .get(
            uri,
            headers: <String, String>{
              'Authorization': 'Bearer ${GaleConfig.appsFlyerKey}',
            },
          )
          .timeout(const Duration(seconds: 13));
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body);
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> awaitSignals({Duration? installTimeout}) async {
    await start();
    final timeout =
        installTimeout ??
        const Duration(milliseconds: GaleConfig.installSignalTimeoutMs);
    await Future.wait<void>(<Future<void>>[
      _installReady.future.timeout(timeout, onTimeout: () {}),
      _deepLinkReady.future.timeout(
        const Duration(seconds: 7),
        onTimeout: () {},
      ),
    ]);
  }

  Future<String?> appsFlyerId() async {
    try {
      return await _sdk?.getAppsFlyerUID();
    } catch (_) {
      return null;
    }
  }

  Future<Map<String, dynamic>> compose({
    required String locale,
    String? pushToken,
  }) async {
    final body = <String, dynamic>{};
    if (_install != null) body.addAll(_install!);
    if (_reopen != null) {
      _reopen!.forEach((key, value) => body.putIfAbsent(key, () => value));
    }
    if (_deepLink != null) {
      _deepLink!.forEach((key, value) => body.putIfAbsent(key, () => value));
    }

    body['af_id'] = await appsFlyerId() ?? body['af_id'] ?? '';
    body['bundle_id'] = GaleConfig.bundleId;
    body['os'] = 'iOS';
    body['store_id'] = GaleConfig.storeToken;
    body['locale'] = locale;
    if (pushToken != null &&
        pushToken.isNotEmpty &&
        GaleConfig.firebaseProjectNumber.isNotEmpty) {
      body['push_token'] = pushToken;
      body['firebase_project_id'] = GaleConfig.firebaseProjectNumber;
    }

    if (Platform.isIOS) {
      try {
        if (await AppTrackingTransparency.trackingAuthorizationStatus ==
            TrackingStatus.authorized) {
          final idfa = await AppTrackingTransparency.getAdvertisingIdentifier();
          if (idfa.isNotEmpty && !idfa.startsWith('00000000-')) {
            body['sub_id_10'] = idfa;
          }
        }
      } catch (_) {}
    }
    galeTrace(() => '[GALE.WIND] payload ${jsonEncode(body)}');
    return body;
  }

  void _completeEmpty() {
    if (!_installReady.isCompleted) _installReady.complete();
    if (!_deepLinkReady.isCompleted) _deepLinkReady.complete();
  }
}
