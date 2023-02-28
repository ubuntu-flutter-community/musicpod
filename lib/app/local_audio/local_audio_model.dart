import 'dart:io';

import 'package:metadata_god/metadata_god.dart';
import 'package:music/data/audio.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:path/path.dart' as path;

class LocalAudioModel extends SafeChangeNotifier {
  bool _searchActive = false;
  bool get searchActive => _searchActive;
  set searchActive(bool value) {
    if (value == _searchActive) return;
    _searchActive = value;
    notifyListeners();
  }

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

  List<Audio>? _audios;
  List<Audio>? get audios {
    List<Audio>? list;
    if (searchQuery == null || searchQuery!.isEmpty) {
      list = _audios;
    } else {
      list = _audios?.where((a) {
        if (a.metadata == null) {
          return false;
        } else {
          if (a.metadata?.title == null) {
            return false;
          } else {
            if (a.metadata!.title!
                .toLowerCase()
                .contains(searchQuery!.toLowerCase())) {
              return true;
            }
          }
          if (a.metadata?.artist == null) {
            return false;
          } else {
            if (a.metadata!.artist!
                .toLowerCase()
                .contains(searchQuery!.toLowerCase())) {
              return true;
            }
          }
        }
        return a.metadata!.title!.contains(searchQuery!);
      }).toList();
    }

    list?.sort(
      (a, b) {
        if (a.metadata == null || b.metadata == null) {
          return -1;
        }

        switch (audioFilter) {
          case AudioFilter.album:
            return (a.metadata!.album == null || b.metadata!.album == null)
                ? -1
                : a.metadata!.album!.compareTo(b.metadata!.album!);
          case AudioFilter.artist:
            return (a.metadata!.artist == null || b.metadata!.artist == null)
                ? -1
                : a.metadata!.artist!.compareTo(b.metadata!.artist!);
          case AudioFilter.title:
            return (a.metadata!.title == null || b.metadata!.title == null)
                ? -1
                : a.metadata!.title!.compareTo(b.metadata!.title!);
          case AudioFilter.year:
            return (a.metadata!.year == null || b.metadata!.year == null)
                ? -1
                : a.metadata!.year!.compareTo(b.metadata!.year!);
          case AudioFilter.genre:
            return (a.metadata!.genre == null || b.metadata!.genre == null)
                ? -1
                : a.metadata!.genre!.compareTo(b.metadata!.genre!);
        }
      },
    );

    return list;
  }

  set audios(List<Audio>? value) {
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

      audios = [];
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
  title,
  artist,
  album,
  genre,
  year;
}
