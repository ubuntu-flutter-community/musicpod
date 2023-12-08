import 'dart:convert';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:xdg_directories/xdg_directories.dart';

import 'common.dart';
import 'constants.dart';
import 'data.dart';

String formatTime(Duration duration) {
  String twoDigits(int n) => n.toString().padLeft(2, '0');
  final hours = twoDigits(duration.inHours);
  final minutes = twoDigits(duration.inMinutes.remainder(60));
  final seconds = twoDigits(duration.inSeconds.remainder(60));

  return <String>[if (duration.inHours > 0) hours, minutes, seconds].join(':');
}

bool listsAreEqual(List<dynamic>? list1, List<dynamic>? list2) =>
    const ListEquality().equals(list1, list2);

void sortListByAudioFilter({
  required AudioFilter audioFilter,
  required List<Audio> audios,
}) {
  switch (audioFilter) {
    case AudioFilter.artist:
      audios.sort((a, b) {
        if (a.artist != null && b.artist != null) {
          return a.artist!.compareTo(b.artist!);
        }
        return 0;
      });
      break;
    case AudioFilter.title:
      audios.sort((a, b) {
        if (a.title != null && b.title != null) {
          return a.title!.compareTo(b.title!);
        }
        return 0;
      });
      break;
    case AudioFilter.album:
      audios.sort((a, b) {
        if (a.album != null && b.album != null) {
          final albumComp = a.album!.compareTo(b.album!);
          if (albumComp == 0 &&
              a.trackNumber != null &&
              b.trackNumber != null) {
            final trackComp = a.trackNumber!.compareTo(b.trackNumber!);

            return trackComp;
          }
          return albumComp;
        }
        return 0;
      });
      break;
    default:
      audios.sort((a, b) {
        if (a.trackNumber != null && b.trackNumber != null) {
          return a.trackNumber!.compareTo(b.trackNumber!);
        }
        return 0;
      });
      break;
  }
}

Audio createLocalAudio(String path, Metadata metadata, [String? fileName]) {
  return Audio(
    path: path,
    audioType: AudioType.local,
    artist: metadata.artist ?? '',
    title: (metadata.title?.isNotEmpty == true ? metadata.title : fileName) ??
        path,
    album: metadata.album == null
        ? ''
        : '${metadata.album} ${metadata.discTotal != null && metadata.discTotal! > 1 ? metadata.discNumber : ''}',
    albumArtist: metadata.albumArtist,
    discNumber: metadata.discNumber,
    discTotal: metadata.discTotal,
    durationMs: metadata.durationMs,
    fileSize: metadata.fileSize,
    genre: metadata.genre,
    pictureData: metadata.picture?.data,
    pictureMimeType: metadata.picture?.mimeType,
    trackNumber: metadata.trackNumber,
    year: metadata.year,
  );
}

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
    path = getUserDirectory('DOWNLOADS')?.path;
  } else if (Platform.isMacOS || Platform.isIOS || Platform.isWindows) {
    path = (await getDownloadsDirectory())?.path;
  }
  if (path != null) {
    return p.join(path, 'musicpod');
  }
  return null;
}

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

Future<void> writeStringSet({
  required Set<String> set,
  required String filename,
}) async {
  final workingDir = await getWorkingDir();
  final file = File('$workingDir/$filename');
  if (!file.existsSync()) {
    file.create();
  }
  await file.writeAsString(set.join('\n'));
}

Future<Set<String>> readStringSet({
  required String filename,
}) async {
  final workingDir = await getWorkingDir();
  final file = File(p.join(workingDir, filename));

  if (!file.existsSync()) return Future.value(<String>{});

  final content = await file.readAsLines();

  return Set.from(content);
}

Future<void> writeAudioMap(Map<String, Set<Audio>> map, String fileName) async {
  final dynamicMap = map.map(
    (key, value) => MapEntry<String, List<dynamic>>(
      key,
      value.map((audio) => audio.toMap()).toList(),
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

Duration? parseDuration(String? durationAsString) {
  if (durationAsString == null || durationAsString == 'null') return null;
  int hours = 0;
  int minutes = 0;
  int micros;
  List<String> parts = durationAsString.split(':');
  if (parts.length > 2) {
    hours = int.parse(parts[parts.length - 3]);
  }
  if (parts.length > 1) {
    minutes = int.parse(parts[parts.length - 2]);
  }
  micros = (double.parse(parts[parts.length - 1]) * 1000000).round();
  return Duration(hours: hours, minutes: minutes, microseconds: micros);
}

Future<Uri?> createUriFromAudio(Audio audio) async {
  if (audio.imageUrl != null || audio.albumArtUrl != null) {
    return Uri.parse(
      audio.imageUrl ?? audio.albumArtUrl!,
    );
  } else if (audio.pictureData != null) {
    Uint8List imageInUnit8List = audio.pictureData!;
    final workingDir = await getWorkingDir();

    final imagesDir = p.join(workingDir, 'images');

    if (Directory(imagesDir).existsSync()) {
      Directory(imagesDir).deleteSync(recursive: true);
    }
    Directory(imagesDir).createSync();
    final now =
        DateTime.now().toUtc().toString().replaceAll(RegExp(r'[^0-9]'), '');
    final file = File(p.join(imagesDir, '$now.png'));
    final newFile = await file.writeAsBytes(imageInUnit8List);

    return Uri.file(newFile.path, windows: Platform.isWindows);
  } else {
    return null;
  }
}

String? generateAlbumId(Audio audio) {
  final albumName = audio.album;
  final artistName = audio.artist;
  final id = albumName == null && artistName == null
      ? null
      : '${artistName ?? ''}:${albumName ?? ''}';
  return id;
}

bool isValidAudio(String path) {
  final mime = lookupMimeType(path);
  return mime?.startsWith('audio/') ?? false;
}
