import 'package:flutter/material.dart';

import '../constants.dart';

extension BuildContextX on BuildContext {
  ThemeData get t => Theme.of(this);

  MediaQueryData get m => MediaQuery.of(this);

  bool get smallWindow => m.size.width < kMasterDetailBreakPoint;
  bool get wideWindow => m.size.width < kAdaptivContainerBreakPoint;
  bool get showMasterPanel => m.size.width > kMasterDetailBreakPoint;
}
