import 'dart:ui';

int? colorValue(Color? color) {
  if (color == null) {
    return null;
  }

  return (_floatToInt8(color.a) << 24) |
      (_floatToInt8(color.r) << 16) |
      (_floatToInt8(color.g) << 8) |
      _floatToInt8(color.b) << 0;
}

int _floatToInt8(double x) {
  return (x * 255.0).round() & 0xff;
}
