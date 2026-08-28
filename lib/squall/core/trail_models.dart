enum TrailKind {
  native,
  portal,
  first;

  String get storageValue => switch (this) {
    TrailKind.native => 'native',
    TrailKind.portal => 'portal',
    TrailKind.first => 'first',
  };

  static TrailKind parse(String? value) => switch (value) {
    'portal' || 'web' => TrailKind.portal,
    'native' || 'game' => TrailKind.native,
    _ => TrailKind.first,
  };
}

class GaleReply {
  const GaleReply({
    required this.accepted,
    this.url,
    this.expiresAt,
    this.reason,
  });

  factory GaleReply.fromJson(Map<String, dynamic> json) {
    final rawExpiry = json['expires'];
    return GaleReply(
      accepted: json['ok'] == true,
      url: json['url'] is String ? json['url'] as String : null,
      expiresAt: rawExpiry is num
          ? rawExpiry.toInt()
          : int.tryParse(rawExpiry?.toString() ?? ''),
      reason: json['message']?.toString(),
    );
  }

  factory GaleReply.rejected(String reason) =>
      GaleReply(accepted: false, reason: reason);

  final bool accepted;
  final String? url;
  final int? expiresAt;
  final String? reason;

  bool get hasDestination => accepted && (url?.isNotEmpty ?? false);

  /// A real answer from the config host. Network timeouts, 5xx and parse
  /// errors are NOT a first-launch decision — the route stays undecided.
  bool get isAuthoritative {
    if (reason == 'network_failure' || reason == 'invalid_response') {
      return false;
    }
    if (reason == 'credentials_unavailable') return true;
    if (reason != null && reason!.startsWith('http_')) {
      return reason == 'http_404';
    }
    return true;
  }
}

sealed class TrailTarget {
  const TrailTarget();
}

final class NativeTrail extends TrailTarget {
  const NativeTrail();
}

final class PortalTrail extends TrailTarget {
  const PortalTrail(this.url, {this.coldLaunch = false});

  final String url;
  final bool coldLaunch;
}

final class OfflineTrail extends TrailTarget {
  const OfflineTrail({required this.returnToNative});

  final bool returnToNative;
}
