import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:xdg_directories/xdg_directories.dart';

import '../app/app_config.dart';
import '../extensions/taget_platform_x.dart';

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

Future<void> writeCustomSetting({
  required String? key,
  required dynamic value,
  required String filename,
}) async {
  if (key == null || value == null) return;
  final oldSettings = await getCustomSettings(filename);
  if (oldSettings.containsKey(key)) {
    oldSettings.update(key, (v) => value);
  } else {
    oldSettings.putIfAbsent(key, () => value);
  }
  final jsonStr = jsonEncode(oldSettings);

  final workingDir = await getWorkingDir();

  final file = File(p.join(workingDir, filename));

  if (!file.existsSync()) {
    file.createSync();
  }

  await file.writeAsString(jsonStr);
}

Future<void> writeCustomSettings({
  required List<MapEntry<String, dynamic>> entries,
  required String filename,
}) async {
  if (entries.isEmpty) return;
  final oldSettings = await getCustomSettings(filename);

  for (var entry in entries) {
    if (oldSettings.containsKey(entry.key)) {
      oldSettings.update(entry.key, (v) => entry.value);
    } else {
      oldSettings.putIfAbsent(entry.key, () => entry.value);
    }
  }

  final jsonStr = jsonEncode(oldSettings);
  final workingDir = await getWorkingDir();
  final file = File(p.join(workingDir, filename));

  if (!file.existsSync()) {
    await file.create();
  }

  await file.writeAsString(jsonStr);
}

Future<void> removeCustomSetting({
  required String key,
  required String filename,
}) async {
  final oldSettings = await getCustomSettings(filename);
  if (oldSettings.containsKey(key)) {
    oldSettings.remove(key);
    final jsonStr = jsonEncode(oldSettings);

    final workingDir = await getWorkingDir();

    final file = File(p.join(workingDir, filename));

    if (!file.existsSync()) {
      await file.create();
    }
    await file.writeAsString(jsonStr);
  }
}

Future<void> removeCustomSettings({
  required List<String> keys,
  required String filename,
}) async {
  final oldSettings = await getCustomSettings(filename);
  for (var key in keys) {
    if (oldSettings.containsKey(key)) {
      oldSettings.remove(key);
    }
  }

  final jsonStr = jsonEncode(oldSettings);
  final workingDir = await getWorkingDir();
  final file = File(p.join(workingDir, filename));

  if (!file.existsSync()) {
    await file.create();
  }
  await file.writeAsString(jsonStr);
}

Future<Map<String, String>> getCustomSettings(String filename) async {
  final workingDir = await getWorkingDir();

  final file = File(p.join(workingDir, filename));

  if (file.existsSync()) {
    final jsonStr = await file.readAsString();

    final map = jsonDecode(jsonStr) as Map<String, dynamic>;

    final m = map.map((key, value) => MapEntry<String, String>(key, value));

    return m;
  } else {
    return <String, String>{};
  }
}

Future<void> wipeCustomSettings({required String filename}) async {
  final workingDir = await getWorkingDir();

  final file = File(p.join(workingDir, filename));

  if (file.existsSync()) {
    await file.delete();
  }
}

Future<void> writeJsonToFile(Map<String, dynamic> json, String fileName) async {
  final jsonStr = jsonEncode(json);

  final workingDir = await getWorkingDir();

  final file = File(p.join(workingDir, fileName));

  if (!file.existsSync()) {
    file.createSync();
  }

  await file.writeAsString(jsonStr);
}
