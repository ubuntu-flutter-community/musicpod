import 'dart:io';

import '../extensions/taget_platform_x.dart' as Platforms;

class SnapDetector {
  static bool get isSnap {
    if (!Platforms.isLinux) return false;

    return Platform.environment.containsKey('SNAP_NAME') ||
        Platform.environment.containsKey('SNAP');
  }

  static String? get snapVersion {
    if (!isSnap) return null;
    return Platform.environment['SNAP_VERSION'];
  }
}
