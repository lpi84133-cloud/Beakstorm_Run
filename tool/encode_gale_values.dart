// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:typed_data';

const List<int> _gustPepper = <int>[
  0xA7,
  0x3C,
  0x91,
  0x5E,
  0x2B,
  0xD4,
  0x08,
  0xF6,
  0x71,
  0xC2,
  0x4A,
  0x19,
  0xE8,
  0x63,
  0xB0,
  0x2D,
];

const String _idSeed = 'com.beakstormrun.beakstormrungame';
const String _buildSeed = '1.0.1+2';

List<int> _mask() {
  final seed = utf8.encode('$_idSeed/$_buildSeed');
  return List<int>.generate(32, (i) {
    return seed[i % seed.length] ^ _gustPepper[i % _gustPepper.length];
  });
}

String fold(String plain) {
  final bytes = Uint8List.fromList(utf8.encode(plain));
  final mask = _mask();
  final mixed = Uint8List(bytes.length);
  for (var i = 0; i < bytes.length; i++) {
    mixed[i] = bytes[i] ^ mask[i % mask.length] ^ (i & 0xff);
  }
  return base64Encode(mixed);
}

String unfold(String encoded) {
  if (encoded.isEmpty) return '';
  final raw = base64Decode(encoded);
  final mask = _mask();
  final plain = Uint8List(raw.length);
  for (var i = 0; i < raw.length; i++) {
    plain[i] = raw[i] ^ mask[i % mask.length] ^ (i & 0xff);
  }
  return utf8.decode(plain);
}

void main() {
  const values = <String, String>{
    'endpoint': 'https://beakstormrun.com/config.php',
    'gcd': 'https://gcdsdk.appsflyer.com/install_data/v5.0/',
    'appsFlyerDevKey': 'XrScmbbZVnvkTbkmdNAMYe',
    'firebaseProjectNumber': '697629678918',
    'uaProduct': 'Mozilla/5.0',
    'uaPlatformPrefix': '(iPhone; CPU iPhone OS',
    'uaPlatformSuffix': 'like Mac OS X)',
    'uaEngine': 'AppleWebKit/605.1.15 (KHTML, like Gecko)',
    'uaMobileToken': 'Mobile/15E148',
    'safariVersion': '18.7',
    'safariTail': '604.1',
    'uaAppIdTok': 'appid/',
    'uaAppNameTok': 'appname/',
    'uaAppLabel': 'Beakstorm Run',
  };

  for (final entry in values.entries) {
    final encoded = fold(entry.value);
    print("${entry.key}: '$encoded'");
    if (unfold(encoded) != entry.value) {
      throw StateError('Round-trip failed for ${entry.key}');
    }
  }
  print('VERIFY: all values round-tripped');
}
