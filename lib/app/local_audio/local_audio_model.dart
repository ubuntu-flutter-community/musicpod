import 'dart:io';

import 'package:collection/collection.dart';
import 'package:metadata_god/metadata_god.dart';
import 'package:mime_type/mime_type.dart';
import 'package:musicpod/data/audio.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:path/path.dart' as path;
import 'package:xdg_directories/xdg_directories.dart';

class LocalAudioModel extends SafeChangeNotifier {
  String? _searchQuery;
  String? get searchQuery => _searchQuery;
  void setSearchQuery(String? value) {
    if (value == null || value == _searchQuery) return;
    _searchQuery = value;
    notifyListeners();
  }

  Set<Audio>? _similarAlbumsSearchResult;
  Set<Audio>? get similarAlbumsSearchResult => _similarAlbumsSearchResult;
  void setSimilarAlbumsSearchResult(Set<Audio>? value) {
    _similarAlbumsSearchResult = value;
    notifyListeners();
  }

  Set<Audio>? _titlesSearchResult;
  Set<Audio>? get titlesSearchResult => _titlesSearchResult;
  void setTitlesSearchResult(Set<Audio>? value) {
    _titlesSearchResult = value;
    notifyListeners();
  }

  void search() {
    if (searchQuery == null) return;

    final audiosWithSimilarAlbumName = audios?.where(
      (audio) =>
          audio.metadata != null &&
          audio.metadata!.album?.isNotEmpty == true &&
          audio.metadata!.album!
              .toLowerCase()
              .contains(searchQuery!.toLowerCase()),
    );

    final albumsSet = <Audio>{};
    if (audiosWithSimilarAlbumName != null) {
      for (var a in audiosWithSimilarAlbumName) {
        if (albumsSet
            .none((element) => element.metadata?.album == a.metadata?.album)) {
          albumsSet.add(a);
        }
      }
    }

    var titles = audios?.where(
          (audio) =>
              audio.metadata != null &&
              audio.metadata!.title?.isNotEmpty == true &&
              audio.metadata!.title!
                  .toLowerCase()
                  .contains(searchQuery!.toLowerCase()),
        ) ??
        <Audio>{};
    setTitlesSearchResult(
      Set.from(
        titles,
      ),
    );
    setSimilarAlbumsSearchResult(
      albumsSet.isNotEmpty == false ? {} : albumsSet,
    );
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

  Future<void> init() async {
    _directory ??= getUserDirectory('MUSIC')?.path;

    if (_directory != null) {
      final allFileSystemEntities = Set<FileSystemEntity>.from(
        await _getFlattenedFileSystemEntities(path: directory!),
      );

      final onlyFiles = <FileSystemEntity>[];

      for (var fileSystemEntity in allFileSystemEntities) {
        if (!await FileSystemEntity.isDirectory(fileSystemEntity.path) &&
            validType(fileSystemEntity.path)) {
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

  bool validType(String path) => mime(path)?.contains('audio') ?? false;

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
