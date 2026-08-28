import 'dart:convert';

import '../config/gale_config.dart';
import '../core/trail_models.dart';
import 'gale_agent.dart';
import 'perch_vault.dart';
import 'wind_attribution.dart';

class GaleExchange {
  GaleExchange(this._agent, this._vault);

  final GaleAgent _agent;
  final PerchVault _vault;

  Future<GaleReply> request(Map<String, dynamic> payload) async {
    if (!GaleConfig.grayCredentialsReady) {
      return GaleReply.rejected('credentials_unavailable');
    }
    try {
      galeTrace(() => '[GALE.EXCHANGE] request ${jsonEncode(payload)}');
      final response = await _agent
          .post(
            Uri.parse(GaleConfig.endpoint),
            headers: <String, String>{
              'Accept': 'application/json',
              'Content-Type': 'application/json',
              'X-Partner-App-Id': GaleConfig.bundleId,
              'X-Partner-App-Name': GaleConfig.appTitle,
            },
            body: jsonEncode(payload),
          )
          .timeout(
            const Duration(milliseconds: GaleConfig.configPostTimeoutMs),
          );
      galeTrace(
        () =>
            '[GALE.EXCHANGE] response ${response.statusCode} ${response.body}',
      );
      if (response.statusCode != 200) {
        return GaleReply.rejected('http_${response.statusCode}');
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) return GaleReply.rejected('invalid_response');
      final reply = GaleReply.fromJson(Map<String, dynamic>.from(decoded));
      if (reply.hasDestination) {
        await _vault.cacheUrl(reply.url!, reply.expiresAt);
      }
      return reply;
    } catch (error) {
      galeTrace(() => '[GALE.EXCHANGE] failed: $error');
      return GaleReply.rejected('network_failure');
    }
  }
}
