import 'package:flutter/material.dart';

extension ColorSchemeX on ColorScheme {
  bool get isLight => brightness == Brightness.light;
}
