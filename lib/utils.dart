import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
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
    return p.join(path, 'musicpod');
  }
  return null;
}

Future<void> writeAppState(String key, dynamic value) async =>
    await writeSetting(key, value, kAppStateFileName);

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

String? generateAlbumId(Audio audio) {
  final albumName = audio.album;
  final artistName = audio.artist;
  final id = albumName == null && artistName == null
      ? null
      : '${artistName ?? ''}:${albumName ?? ''}';
  return id;
}

/// | Bytes | extension | Description |
/// |:--|:--|:--|
/// |`49 44 33`| `.mp3` |MP3 file with an ID3v2 container|
/// |`FF FB / FF F3 / FF F2`|`.mp3`|MPEG-1 Layer 3 file without an ID3 tag or with an ID3v1 tag (which is appended at the end of the file)|
/// |`4F 67 67 53`| `.ogg`, `.oga`, `.ogv` | Ogg, an open source media container format |
/// |`66 4C 61 43`| `.flac` | Free Lossless Audio Codec |
/// |`66 74 79 70 69 73 6F 6D`| `mp4`| 	ISO Base Media file (MPEG-4)|
/// |`66 74 79 70 4D 53 4E 56`| `mp4`| 	MPEG-4 video file|
/// TODO: either guarantee that downloads are saved with the correct extension or manage to detect files without file extensions via magic bytes
bool isValidFile(String path) {
  final mime = lookupMimeType(path);
  return mime?.startsWith('audio') == true ||
      mime?.startsWith('video') == true ||
      _validExtensions.any((e) => path.endsWith(e));
}

const _validExtensions = [
  '.mp3',
  '.flac',
  '.mp4',
  '.opus',
  '.ogg',
  '.m4a',
  '.aac',
];

({String? songName, String? artist}) splitIcyTitle(String icyTitle) {
  String? songName;
  String? artist;
  final split = icyTitle.split(' - ');
  if (split.isNotEmpty) {
    artist = split.elementAtOrNull(0);
    songName = split.elementAtOrNull(1);
  }
  return (songName: songName, artist: artist);
}

Future<String?> fetchAlbumArt(String icyTitle) async {
  return UrlStore().get(icyTitle) ?? await _fetchAlbumArt(icyTitle);
}

Future<String?> _fetchAlbumArt(String icyTitle) async {
  final res = splitIcyTitle(icyTitle);
  if (res.songName == null || res.artist == null) return null;

  final searchUrl = Uri.parse(
    'https://musicbrainz.org/ws/2/recording/?query=recording:"${res.songName}"%20AND%20artist:"${res.artist}"',
  );

  try {
    final searchResponse = await http.get(
      searchUrl,
      headers: {
        'Accept': 'application/json',
        'User-Agent':
            'MusicPod (https://github.com/ubuntu-flutter-community/musicpod)',
      },
    );

    if (searchResponse.statusCode == 200) {
      final searchData = jsonDecode(searchResponse.body);
      final recordings = searchData['recordings'] as List;

      final firstRecording = recordings.firstOrNull;

      final releaseId = firstRecording == null
          ? null
          : firstRecording?['releases']?[0]?['id'];

      if (releaseId == null) return null;

      final albumArtUrl = await _fetchAlbumArtUrlFromReleaseId(releaseId);

      return albumArtUrl;
    }
  } on Exception catch (_) {
    return null;
  }

  return null;
}

Future<String?> _fetchAlbumArtUrlFromReleaseId(String releaseId) async {
  final url = Uri.parse(
    'https://coverartarchive.org/release/$releaseId',
  );
  try {
    final response = await http.get(
      url,
      headers: {
        'Accept': 'application/json',
        'User-Agent':
            'MusicPod (https://github.com/ubuntu-flutter-community/musicpod)',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final images = data['images'] as List;

      if (images.isNotEmpty) {
        final artwork = images[0];

        return (artwork['image']) as String?;
      }
    }
  } on Exception catch (_) {
    return null;
  }

  return null;
}
