import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:xdg_directories/xdg_directories.dart';

import 'constants.dart';
import 'common/data/audio.dart';

String? _workingDir;
Future<String> getWorkingDir() async {
  if (_workingDir != null) return Future.value(_workingDir!);
  if (Platform.isLinux) {
    final workingDir = p.join(configHome.path, kAppName);
    if (!Directory(workingDir).existsSync()) {
      await Directory(workingDir).create();
    }
    _workingDir = workingDir;
    return workingDir;
  } else if (Platform.isMacOS || Platform.isIOS) {
    final libDirPath = (await getLibraryDirectory()).path;
    final workingDirPath = p.join(libDirPath, kAppName);
    if (!Directory(workingDirPath).existsSync()) {
      await Directory(workingDirPath).create();
    }
    _workingDir = workingDirPath;
    return workingDirPath;
  } else {
    final docDirPath = (await getApplicationSupportDirectory()).path;
    final workingDirPath = p.join(docDirPath, kAppName);
    if (!Directory(workingDirPath).existsSync()) {
      Directory(workingDirPath).createSync();
    }
    _workingDir = workingDirPath;
    return workingDirPath;
  }
}

Future<String?> getMusicDir() async {
  if (Platform.isLinux) {
    return getUserDirectory('MUSIC')?.path;
  }
  return null;
}

Future<String?> getDownloadsDir() async {
  String? path;
  if (Platform.isLinux) {
    path = getUserDirectory('DOWNLOAD')?.path;
  } else if (Platform.isMacOS || Platform.isIOS || Platform.isWindows) {
    path = (await getDownloadsDirectory())?.path;
  }
  if (path != null) {
    return p.join(path, kAppName);
  }
  return null;
}

Future<void> writeAppState(String key, dynamic value) async =>
    writeSetting(key, value, kAppStateFileName);

Future<void> writeSetting(
  String? key,
  dynamic value, [
  String filename = kSettingsFileName,
]) async {
  if (key == null || value == null) return;
  final oldSettings = await getSettings(filename);
  if (oldSettings.containsKey(key)) {
    oldSettings.update(key, (v) => value);
  } else {
    oldSettings.putIfAbsent(key, () => value);
  }
  final jsonStr = jsonEncode(oldSettings);

  final workingDir = await getWorkingDir();

  final file = File(p.join(workingDir, filename));

  if (!file.existsSync()) {
    file.create();
  }

  await file.writeAsString(jsonStr);
}

Future<dynamic> readAppState(String key) => readSetting(key, kAppStateFileName);

Future<dynamic> readSetting(
  dynamic key, [
  String filename = kSettingsFileName,
]) async {
  if (key == null) return null;
  final oldSettings = await getSettings(filename);
  return oldSettings[key];
}

Future<Map<String, String>> getSettings([
  String filename = kSettingsFileName,
]) async {
  final workingDir = await getWorkingDir();

  final file = File(p.join(workingDir, filename));

  if (file.existsSync()) {
    final jsonStr = await file.readAsString();

    final map = jsonDecode(jsonStr) as Map<String, dynamic>;

    final m = map.map(
      (key, value) => MapEntry<String, String>(
        key,
        value,
      ),
    );

    return m;
  } else {
    return <String, String>{};
  }
}

Future<void> writeStringIterable({
  required Iterable<String> iterable,
  required String filename,
}) async {
  final workingDir = await getWorkingDir();
  final file = File('$workingDir/$filename');
  if (!file.existsSync()) {
    file.create();
  }
  await file.writeAsString(iterable.join('\n'));
}

Future<Iterable<String>?> readStringIterable({
  required String filename,
}) async {
  final workingDir = await getWorkingDir();
  final file = File(p.join(workingDir, filename));

  if (!file.existsSync()) return Future.value(null);

  final content = await file.readAsLines();

  return content;
}

Future<void> writeAudioMap(Map<String, Set<Audio>> map, String fileName) async {
  final dynamicMap = map.map(
    (key, value) => MapEntry<String, List<dynamic>>(
      key,
      value.map((audio) => audio.toMap()).toList(),
    ),
  );

  await writeJsonToFile(dynamicMap, fileName);
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

Future<Map<String, Set<Audio>>> readAudioMap(String fileName) async {
  final workingDir = await getWorkingDir();

  try {
    final file = File(p.join(workingDir, fileName));

    if (file.existsSync()) {
      final jsonStr = await file.readAsString();

      final map = jsonDecode(jsonStr) as Map<String, dynamic>;

      final m = map.map(
        (key, value) => MapEntry<String, Set<Audio>>(
          key,
          Set.from(
            (value as List<dynamic>).map((e) => Audio.fromMap(e)),
          ),
        ),
      );

      return m;
    } else {
      return <String, Set<Audio>>{};
    }
  } on Exception catch (_) {
    return <String, Set<Audio>>{};
  }
}

Future<Map<String, String>> readStringMap(String fileName) async {
  final workingDir = await getWorkingDir();

  try {
    final file = File(p.join(workingDir, fileName));

    if (file.existsSync()) {
      final jsonStr = await file.readAsString();

      final map = jsonDecode(jsonStr) as Map<String, dynamic>;

      final m = map.map(
        (key, value) => MapEntry<String, String>(
          key,
          value as String,
        ),
      );

      return m;
    } else {
      return <String, String>{};
    }
  } on Exception catch (_) {
    return <String, String>{};
  }
}

Future<void> writeStringMap(Map<String, String> map, String fileName) async {
  final dynamicMap = map.map(
    (key, value) => MapEntry<String, String>(
      key,
      value as dynamic,
    ),
  );

  final jsonStr = jsonEncode(dynamicMap);

  final workingDir = await getWorkingDir();

  final file = File(p.join(workingDir, fileName));

  if (!file.existsSync()) {
    file.createSync();
  }

  await file.writeAsString(jsonStr);
}

/// TODO: how to l10n labels?
List<MenuItem> trayMenuItems = [
  MenuItem(
    key: 'restore_window',
    label: 'Hide/Restore',
  ),
  MenuItem.separator(),
  MenuItem(
    key: 'close_application',
    label: 'Close Application',
  ),
];

String trayIcon() {
  if (Platform.isWindows) {
    return 'assets/images/tray_icon.ico';
  } else {
    return 'assets/images/tray_icon.png';
  }
}
