import 'package:flutter/material.dart';

import '../common/view/ui_constants.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => theme.colorScheme;
  TextTheme get textTheme => theme.textTheme;

  Size get mediaQuerySize => MediaQuery.sizeOf(this);
  bool get isPortrait => MediaQuery.orientationOf(this) == Orientation.portrait;
  bool get isAndroidGestureNavigationEnabled {
    final value = MediaQuery.of(this).systemGestureInsets.bottom;
    return value < 48.0 && value != 0.0;
  }

  bool get smallWindow => mediaQuerySize.width < kMasterDetailBreakPoint;
  bool get wideWindow => mediaQuerySize.width < kAdaptivContainerBreakPoint;
  bool get showMasterPanel => mediaQuerySize.width > kMasterDetailBreakPoint;
}
