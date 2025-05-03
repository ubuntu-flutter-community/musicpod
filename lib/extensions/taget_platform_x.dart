import 'package:flutter/foundation.dart';

extension TagetPlatformX on TargetPlatform {
  bool get isIOS => this == TargetPlatform.iOS;
  bool get isAndroid => this == TargetPlatform.android;
  bool get isFuchsia => this == TargetPlatform.fuchsia;
  bool get isMacOS => this == TargetPlatform.macOS;
  bool get isWindows => this == TargetPlatform.windows;
  bool get isLinux => this == TargetPlatform.linux;
  bool get isDesktop => isMacOS || isWindows || isLinux;
  bool get isMobile => isIOS || isAndroid || isFuchsia;
}

bool get isMobile => defaultTargetPlatform.isMobile;
bool get isLinux => defaultTargetPlatform.isLinux;
bool get isMacOS => defaultTargetPlatform.isMacOS;
bool get isWindows => defaultTargetPlatform.isWindows;
bool get isIOS => defaultTargetPlatform.isIOS;
bool get isAndroid => defaultTargetPlatform.isAndroid;
bool get isFuchsia => defaultTargetPlatform.isFuchsia;
