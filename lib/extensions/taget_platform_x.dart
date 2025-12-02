import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:xdg_directories/xdg_directories.dart';

import '../app_config.dart';

bool get isDesktop => !kIsWeb && !isMobile;
bool get isMobile => !kIsWeb && (isIOS || isAndroid || isFuchsia);
bool get isLinux => !kIsWeb && Platform.isLinux;
bool get isMacOS => !kIsWeb && Platform.isMacOS;
bool get isWindows => !kIsWeb && Platform.isWindows;
bool get isIOS => !kIsWeb && Platform.isIOS;
bool get isAndroid => !kIsWeb && Platform.isAndroid;
bool get isFuchsia => !kIsWeb && Platform.isFuchsia;

extension PlatformX on Platform {
  static Future<String?> get downloadsDefaultDir async {
    String? path;
    if (isLinux) {
      path = getUserDirectory('DOWNLOAD')?.path;
    } else if (isMacOS || isIOS || isWindows) {
      path = (await getDownloadsDirectory())?.path;
    } else if (isAndroid) {
      final androidDir = Directory('/storage/emulated/0/Download');
      if (androidDir.existsSync()) {
        path = androidDir.path;
      }
    }
    if (path != null) {
      return p.join(path, AppConfig.appName);
    }
    return null;
  }

  static String? get musicDefaultDir =>
      isLinux ? getUserDirectory('MUSIC')?.path : null;
}
