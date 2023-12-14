import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  ThemeData get t => Theme.of(this);

  MediaQueryData get m => MediaQuery.of(this);
}
