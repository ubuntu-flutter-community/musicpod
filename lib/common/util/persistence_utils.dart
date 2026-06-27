import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:xdg_directories/xdg_directories.dart';

import '../../app/app_config.dart';
import '../../extensions/platform_x.dart';

String? _workingDir;
Future<String> getWorkingDir() async {
  if (_workingDir != null) return Future.value(_workingDir!);
  if (isLinux) {
    final workingDir = p.join(configHome.path, AppConfig.appName);
    if (!Directory(workingDir).existsSync()) {
      await Directory(workingDir).create();
    }
    _workingDir = workingDir;
    return workingDir;
  } else if (isMacOS || isIOS) {
    final libDirPath = (await getLibraryDirectory()).path;
    final workingDirPath = p.join(libDirPath, AppConfig.appName);
    if (!Directory(workingDirPath).existsSync()) {
      await Directory(workingDirPath).create();
    }
    _workingDir = workingDirPath;
    return workingDirPath;
  } else {
    final docDirPath = (await getApplicationSupportDirectory()).path;
    final workingDirPath = p.join(docDirPath, AppConfig.appName);
    if (!Directory(workingDirPath).existsSync()) {
      Directory(workingDirPath).createSync();
    }
    _workingDir = workingDirPath;
    return workingDirPath;
  }
}
