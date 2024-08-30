import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
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
  } else if (Platform.isAndroid) {
    final androidDir = Directory('/storage/emulated/0/Download');
    if (androidDir.existsSync()) {
      path = androidDir.path;
    }
  }
  if (path != null) {
    return p.join(path, kAppName);
  }
  return null;
}

Future<void> writeCustomSetting(
  String? key,
  dynamic value, [
  String filename = kSettingsFileName,
]) async {
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
    file.create();
  }

  await file.writeAsString(jsonStr);
}

Future<void> removeCustomSetting(
  String key, [
  String filename = kSettingsFileName,
]) async {
  final oldSettings = await getCustomSettings(filename);
  if (oldSettings.containsKey(key)) {
    oldSettings.remove(key);
    final jsonStr = jsonEncode(oldSettings);

    final workingDir = await getWorkingDir();

    final file = File(p.join(workingDir, filename));

    if (!file.existsSync()) {
      file.create();
    }
    await file.writeAsString(jsonStr);
  }
}

Future<dynamic> readCustomSetting(
  dynamic key, [
  String filename = kSettingsFileName,
]) async {
  if (key == null) return null;
  final oldSettings = await getCustomSettings(filename);
  return oldSettings[key];
}

Future<Map<String, String>> getCustomSettings([
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

Future<void> writeAudioMap(
  Map<String, List<Audio>> map,
  String fileName,
) async {
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

Future<Map<String, List<Audio>>> readAudioMap(String fileName) async {
  final workingDir = await getWorkingDir();

  try {
    final file = File(p.join(workingDir, fileName));

    if (file.existsSync()) {
      final jsonStr = await file.readAsString();

      final map = jsonDecode(jsonStr) as Map<String, dynamic>;

      final m = map.map(
        (key, value) => MapEntry<String, List<Audio>>(
          key,
          List.from(
            (value as List<dynamic>).map((e) => Audio.fromMap(e)),
          ),
        ),
      );

      return m;
    } else {
      return <String, List<Audio>>{};
    }
  } on Exception catch (_) {
    return <String, List<Audio>>{};
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

Future<void> writeUint8ListMap(
  Map<String, Uint8List?> map,
  String fileName,
) async {
  final dynamicMap = map.map(
    (key, value) => MapEntry<String, dynamic>(key, base64Encode(value!)),
  );

  await writeJsonToFile(dynamicMap, fileName);
}

Future<Map<String, Uint8List?>?> readUint8ListMap(String fileName) async {
  final workingDir = await getWorkingDir();
  Map<String, Uint8List?>? theMap = {};

  final file = File(p.join(workingDir, fileName));
  if (file.existsSync()) {
    final jsonStr = await file.readAsString();
    final decode = jsonDecode(jsonStr) as Map<String, dynamic>;
    for (final e in decode.entries) {
      final value = base64Decode(e.value);
      if (value.isNotEmpty == true) {
        theMap.putIfAbsent(e.key, () => value);
      }
    }
  }

  return theMap;
}
