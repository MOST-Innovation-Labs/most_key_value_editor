import 'package:flutter/material.dart' show Color;

/// Color lightness extension.
extension LightnessColorExtension on Color {
  /// Darken a color by [percent] amount (100 = black)
  Color darken([int percent = 10]) {
    assert(0 <= percent && percent <= 100, '0 <= $percent <= 100');

    Color c = this;
    double f = 1 - percent.clamp(0, 100) / 100;

    return Color.fromARGB(
      c.alpha,
      (c.red * f).round(),
      (c.green * f).round(),
      (c.blue * f).round(),
    );
  }

  /// Lighten a color by [percent] amount (100 = white)
  Color lighten([int percent = 10]) {
    assert(0 <= percent && percent <= 100, '0 <= $percent <= 100');

    Color c = this;
    double p = percent.clamp(0, 100) / 100;

    return Color.fromARGB(
      c.alpha,
      c.red + ((0xFF - c.red) * p).round(),
      c.green + ((0xFF - c.green) * p).round(),
      c.blue + ((0xFF - c.blue) * p).round(),
    );
  }
}

/// Color serialization extension.
extension HexColorExtension on Color {
  /// String is in the format "aabbcc" or "ffaabbcc"
  /// with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true`.
  String toHex({bool leadingHashSign = true}) {
    return '${leadingHashSign ? '#' : ''}'
        '${alpha.toRadixString(16).padLeft(2, '0')}'
        '${red.toRadixString(16).padLeft(2, '0')}'
        '${green.toRadixString(16).padLeft(2, '0')}'
        '${blue.toRadixString(16).padLeft(2, '0')}';
  }
}
