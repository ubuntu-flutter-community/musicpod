import 'package:flutter/material.dart';

extension ThemeDataX on ThemeData {
  bool get isLight => brightness == Brightness.light;
}
