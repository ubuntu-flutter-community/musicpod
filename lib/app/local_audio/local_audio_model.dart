import 'dart:io';

import 'package:metadata_god/metadata_god.dart';
import 'package:music/data/audio.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:path/path.dart' as path;

class LocalAudioModel extends SafeChangeNotifier {
  String? _searchQuery;
  String? get searchQuery => _searchQuery;
  set searchQuery(String? value) {
    if (value == null || value == _searchQuery) return;
    _searchQuery = value;
    notifyListeners();
  }

  AudioFilter _audioFilter = AudioFilter.title;
  AudioFilter get audioFilter => _audioFilter;
  set audioFilter(AudioFilter value) {
    if (value == _audioFilter) return;
    _audioFilter = value;
    notifyListeners();
  }

  String? _directory;
  String? get directory => _directory;
  set directory(String? value) {
    if (value == null || value == _directory) return;
    _directory = value;
    notifyListeners();
  }

  Set<Audio>? _audios;
  Set<Audio>? get audios => _audios;

  set audios(Set<Audio>? value) {
    _audios = value;
    notifyListeners();
  }

  int _selectedTab = 0;
  int get selectedTab => _selectedTab;
  set selectedTab(int value) {
    if (value == _selectedTab) return;
    _selectedTab = value;
    notifyListeners();
  }

  String? guessDirectory() {
    Map<String, String> envVars = Platform.environment;
    final home = envVars['HOME'];

    final guessMap = <String, String>{
      'de': 'Musik',
      'dk': 'Musik',
      'se': 'Musik',
      'no': 'Musikk',
      'es': 'Música',
      'po': 'Música',
      'it': 'Musica',
      'tk': 'Müzik',
      'fr': 'Musique'
    };

    for (var guess in guessMap.entries) {
      final path = '$home/${guess.value}';
      if (Directory(path).existsSync()) {
        return path;
      }
    }
    return null;
  }

  Future<void> init() async {
    _directory ??= guessDirectory();

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

      audios = {};
      for (var e in onlyFiles) {
        File file = File(e.path);
        String basename = path.basename(file.path);

        final metadata = await MetadataGod.getMetadata(e.path);

        final audio = Audio(
          path: e.path,
          audioType: AudioType.local,
          name: basename,
          metadata: metadata,
        );

        audios?.add(audio);
      }

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

enum AudioFilter {
  trackNumber,
  title,
  artist,
  album,
  genre,
  year;
}
