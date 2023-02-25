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
      final files = await _getFiles(path: directory!);
      audios = files.map(
        (e) {
          File file = File(e.path);
          String basename = path.basename(file.path);
          return Audio(
            resourcePath: e.path,
            audioType: AudioType.local,
            title: basename,
          );
        },
      ).toList();
      notifyListeners();
    }
  }

  Future<List<FileSystemEntity>> _getFiles({required String path}) async {
    return await Directory(path).list().toList();
  }
}
