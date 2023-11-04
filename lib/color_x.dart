import 'dart:ui';

extension on Color {
  // ignore: unused_element
  Color operator +(Color other) => Color.alphaBlend(this, other);
}
