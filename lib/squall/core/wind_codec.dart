import 'dart:convert';
import 'dart:typed_data';

/// One-pass XOR over standard base64. The mask is derived from the bundle id
/// plus a project pepper — not a KSA/PRGA stream.
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

String unfoldGust(String encoded) {
  if (encoded.isEmpty) return '';
  final raw = base64Decode(encoded);
  final mask = _mask();
  final plain = Uint8List(raw.length);
  for (var i = 0; i < raw.length; i++) {
    plain[i] = raw[i] ^ mask[i % mask.length] ^ (i & 0xff);
  }
  return utf8.decode(plain);
}
