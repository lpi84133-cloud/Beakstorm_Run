import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Identifier for a route or a stage. Generated on the device; there is no
/// server to hand out ids.
String newId() => _uuid.v4();
