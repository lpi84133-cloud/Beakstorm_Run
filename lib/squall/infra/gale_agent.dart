import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:http/http.dart' as http;

import '../config/gale_config.dart';

class GaleAgent extends http.BaseClient {
  final http.Client _transport = http.Client();
  String? _userAgent;

  Future<void> prepare() async {
    try {
      if (!Platform.isIOS) {
        _userAgent = _fallback();
        return;
      }
      final info = await DeviceInfoPlugin().iosInfo;
      final version = _normalizedIos(info.systemVersion);
      _userAgent = _mobileSafari(version);
    } catch (_) {
      _userAgent = _fallback();
    }
  }

  String get userAgent => _userAgent ?? _fallback();

  String _normalizedIos(String raw) {
    final components = raw
        .split('.')
        .map((part) => int.tryParse(part))
        .whereType<int>()
        .take(3)
        .toList();
    if (components.isEmpty || components.first < 18) return '18.6';
    return components.join('.');
  }

  // GAME THEME CATEGORY: slot (operator required UA identity suffix).
  // Identity tokens are decoded at runtime — no plaintext suffix markers.
  String _mobileSafari(String iosVersion) {
    final cpu = iosVersion.replaceAll('.', '_');
    return '${GaleConfig.uaProduct} ${GaleConfig.uaPlatformPrefix} $cpu '
        '${GaleConfig.uaPlatformSuffix} ${GaleConfig.uaEngine} '
        'Version/${GaleConfig.safariVersion} ${GaleConfig.uaMobileToken} '
        'Safari/${GaleConfig.safariTail} ${GaleConfig.uaAppIdTok}'
        '${GaleConfig.iosStoreId} ${GaleConfig.uaAppNameTok}'
        '${GaleConfig.uaAppLabel}';
  }

  String _fallback() => _mobileSafari('18.6');

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.putIfAbsent('User-Agent', () => userAgent);
    return _transport.send(request);
  }

  @override
  void close() => _transport.close();
}
