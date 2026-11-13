import 'package:flutter/painting.dart';

/// Parses `RRGGBB` or `AARRGGBB` hex, returning [fallback] if malformed.
Color colorFromHex(String hex, {required Color fallback}) {
  final value = int.tryParse(hex.length == 6 ? 'FF$hex' : hex, radix: 16);
  return value == null ? fallback : Color(value);
}
