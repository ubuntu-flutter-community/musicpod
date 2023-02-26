import 'dart:io';

import 'package:music/data/audio.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:path/path.dart' as path;

class LocalAudioModel extends SafeChangeNotifier {
  String? _directory;
  String? get directory => _directory;
  set directory(String? value) {
    if (value == null || value == _directory) return;
    _directory = value;
    notifyListeners();
  }

  List<Audio>? _audios;
  List<Audio>? get audios => _audios;
  set audios(List<Audio>? value) {
    _audios = value;
    notifyListeners();
  }

  Future<void> init() async {
    if (_directory != null) {
      final allFileSystemEntities = Set<FileSystemEntity>.from(
        await _getFlattenedFileSystemEntities(path: directory!),
      );

      final onlyFiles = <FileSystemEntity>[];

      for (var fileSystemEntity in allFileSystemEntities) {
        if (!await FileSystemEntity.isDirectory(fileSystemEntity.path) &&
            fileSystemEntity.path.endsWith('.mp3')) {
          onlyFiles.add(fileSystemEntity);
        }
      }

      audios = onlyFiles.map(
        (e) {
          File file = File(e.path);
          String basename = path.basename(file.path);
          return Audio(
            path: e.path,
            audioType: AudioType.local,
            name: basename,
          );
        },
      ).toList();
      notifyListeners();
    }
  }

  Future<List<FileSystemEntity>> _getFlattenedFileSystemEntities({
    required String path,
  }) async {
    return await Directory(path)
        .list(recursive: true, followLinks: false)
        .toList();
  }
}
