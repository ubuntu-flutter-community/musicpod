import 'dart:async';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:synchronized/synchronized.dart';
import 'package:watcher/watcher.dart';

import '../common/data/audio.dart';
import '../common/logging.dart';
import '../common/view/audio_filter.dart';
import '../extensions/media_file_x.dart';
import '../settings/shared_preferences_keys.dart';
import '../extensions/string_x.dart';
import '../extensions/taget_platform_x.dart';
import '../settings/settings_service.dart';
import 'local_cover_service.dart';
import 'local_search_result.dart';

class LocalAudioService {
  final SettingsService? _settingsService;
  final LocalCoverService _localCoverService;

  LocalAudioService({
    required LocalCoverService localCoverService,
    SettingsService? settingsService,
  }) : _settingsService = settingsService,
       _localCoverService = localCoverService;

  List<Audio>? _audios;
  List<Audio>? get audios => _audios;
  final _audiosController = StreamController<bool>.broadcast();
  Stream<bool> get audiosChanged => _audiosController.stream;
  List<String>? _failedImports;
  List<String>? get failedImports => _failedImports;

  void _sortAllTitles() {
    if (_audios == null) return;
    sortListByAudioFilter(audioFilter: AudioFilter.title, audios: _audios!);
  }

  List<String>? _allArtists;
  List<String>? get allArtists => _allArtists;
  void _findAllArtists() {
    if (_audios == null) return;
    final artists = <String>[];
    for (var a in audios!) {
      final artist = a.artist;
      if (artist?.isNotEmpty == true && !artists.contains(artist)) {
        artists.add(artist!);
      }
    }
    _allArtists = artists;
    _allArtists?.sort();
  }

  List<String>? _allGenres;
  List<String>? get allGenres => _allGenres;
  void _findAllGenres() {
    if (_audios == null) return;
    final genresResult = <String>[];
    for (var a in audios!) {
      if (genresResult.none((e) => e == a.genre) &&
          a.genre?.isNotEmpty == true) {
        genresResult.add(a.genre!);
      }
    }
    genresResult.sort();
    _allGenres = genresResult;
  }

  List<String>? _allAlbumIDs;
  List<String>? get allAlbumIDs => _allAlbumIDs;
  List<String>? findAllAlbumIDs({String? artist, bool clean = true}) {
    final groupAlbumsOnlyByAlbumName =
        _settingsService?.getBool(SPKeys.groupAlbumsOnlyByAlbumName) ?? false;

    final theAudios = artist == null || artist.isEmpty
        ? audios
        : audios?.where((e) => e.artist == artist);
    if (theAudios == null) return null;
    final albumsResult = <String>[];
    for (var a in theAudios) {
      final idToUse = groupAlbumsOnlyByAlbumName ? a.album : a.albumId;

      if (idToUse != null && albumsResult.none((e) => e == idToUse)) {
        albumsResult.add(idToUse);
      }
    }
    albumsResult.sort(
      (a, b) => groupAlbumsOnlyByAlbumName
          ? compareNatural(a, b)
          : compareNatural(a.albumOfId, b.albumOfId),
    );

    if (clean) {
      _allAlbumIDs = albumsResult;
      return _allAlbumIDs;
    } else {
      return albumsResult;
    }
  }

  String? findAlbumId({required String artist, required String album}) =>
      (_allAlbumIDs ?? []).firstWhereOrNull(
        (e) => e == Audio.createAlbumId(artist, album),
      );

  List<Audio>? getCachedAlbum(String albumId) {
    final maybe = _albumCache[albumId];
    if (maybe != null) {
      return maybe;
    }
    return null;
  }

  final Map<String, List<Audio>?> _albumCache = {};
  Future<List<Audio>?> findAlbum(
    String albumId, [
    AudioFilter audioFilter = AudioFilter.trackNumber,
  ]) async {
    await init();
    return _findAlbum(albumId);
  }

  List<Audio>? _findAlbum(
    String albumId, [
    AudioFilter audioFilter = AudioFilter.trackNumber,
  ]) {
    final maybe = _albumCache[albumId];
    if (maybe != null) {
      return maybe;
    }

    final album = audios?.where((a) {
      if (_settingsService?.getBool(SPKeys.groupAlbumsOnlyByAlbumName) ??
          false) {
        return a.album != null && a.album == albumId.albumOfId;
      }
      return a.albumId != null && a.albumId == albumId;
    });

    var albumList = album?.toList();
    if (albumList != null) {
      sortListByAudioFilter(audioFilter: audioFilter, audios: albumList);

      albumList = splitByDiscs(albumList).toList();
    }

    final list = albumList;
    _albumCache[albumId] = list;
    return list;
  }

  String? getCachedCoverPath(String albumId) {
    final maybe = _coverPathCache[albumId];
    if (maybe != null) {
      return maybe;
    }
    return null;
  }

  final Map<String, String?> _coverPathCache = {};
  Future<String?> findCoverPath(String albumId) async {
    final maybe = _coverPathCache[albumId];
    if (maybe != null) {
      return maybe;
    }

    final albumAudios = await findAlbum(albumId);
    _coverPathCache[albumId] = albumAudios
        ?.firstWhereOrNull((e) => e.path != null)
        ?.path;
    return _coverPathCache[albumId];
  }

  final Map<String, List<Audio>?> _titlesOfArtistCache = {};
  List<Audio>? getCachedTitlesOfArtist(String artist) {
    final maybe = _titlesOfArtistCache[artist];
    if (maybe != null) {
      return maybe;
    }
    return null;
  }

  Future<List<Audio>?> findTitlesOfArtist(
    String artist, [
    AudioFilter audioFilter = AudioFilter.album,
  ]) async {
    await init();
    final maybe = _titlesOfArtistCache[artist];
    if (maybe != null) {
      return maybe;
    }
    final artistTitles = audios?.where(
      (a) => a.artist != null && a.artist == artist,
    );

    var artistList = artistTitles?.toList();
    if (artistList != null) {
      sortListByAudioFilter(audioFilter: audioFilter, audios: artistList);
      artistList = splitByDiscs(artistList).toList();
    }
    final list = artistList != null ? List<Audio>.from(artistList) : null;

    _titlesOfArtistCache[artist] = list;

    return list;
  }

  List<String>? getCachedAlbumIDsOfGenre(String genre) {
    final maybe = _albumIDsOfGenreCache[genre];
    if (maybe != null) {
      return maybe;
    }
    return null;
  }

  final Map<String, List<String>?> _albumIDsOfGenreCache = {};
  Future<List<String>?> findAlbumIDsOfGenre(String genre) async {
    await init();
    if (_audios == null) return null;
    final maybe = _albumIDsOfGenreCache[genre];
    if (maybe != null) {
      return maybe;
    }

    final albumIDsOfGenre = <String>[];

    for (var artistAudio in _audios!) {
      if (artistAudio.genre?.trim().isNotEmpty == true &&
          artistAudio.genre == genre &&
          albumIDsOfGenre.none((e) => e == artistAudio.albumId)) {
        albumIDsOfGenre.add(artistAudio.albumId!);
      }
    }

    _albumIDsOfGenreCache[genre] = albumIDsOfGenre;

    return albumIDsOfGenre;
  }

  Set<Uint8List>? findLocalCovers({
    required List<Audio> audios,
    int limit = 4,
  }) {
    final images = <Uint8List>{};

    final List<Audio> albumAudios = findUniqueAlbumAudios(audios);

    for (var audio in albumAudios) {
      final uint8list = _localCoverService.get(audio.albumId);
      if (uint8list != null && images.length < limit) {
        images.add(uint8list);
      }
    }

    return images;
  }

  List<Audio> findUniqueAlbumAudios(List<Audio> audios) {
    final albumAudios = <Audio>[];
    for (var audio in audios) {
      if (albumAudios.none((a) => a.album == audio.album)) {
        albumAudios.add(audio);
      }
    }
    return albumAudios;
  }

  LocalSearchResult? search(String? query) {
    if (query == null) return null;
    if (query.isEmpty) {
      return const LocalSearchResult(
        titles: [],
        artists: [],
        albums: [],
        genres: [],
        playlists: [],
      );
    }

    final allAlbumsFindings = allAlbumIDs?.where(
      (e) => e.albumOfId.toLowerCase().contains(query.toLowerCase()),
    );

    final albumsResult = <String>[];
    if (allAlbumsFindings != null) {
      for (var a in allAlbumsFindings) {
        if (albumsResult.none((e) => e == a)) {
          albumsResult.add(a);
        }
      }
    }

    final allGenresFindings = audios?.where(
      (audio) =>
          audio.genre?.isNotEmpty == true &&
          audio.genre!.toLowerCase().contains(query.toLowerCase()),
    );

    final genreFindings = <String>[];
    if (allGenresFindings != null) {
      for (var a in allGenresFindings) {
        if (a.genre?.isNotEmpty == true &&
            genreFindings.none((element) => element == a.genre)) {
          genreFindings.add(a.genre!);
        }
      }
    }

    return LocalSearchResult(
      titles:
          audios
              ?.where(
                (audio) =>
                    audio.title?.isNotEmpty == true &&
                    audio.title!.toLowerCase().contains(query.toLowerCase()),
              )
              .toList() ??
          <Audio>[],
      albums: albumsResult,
      genres: genreFindings,
      artists: allArtists
          ?.where((a) => a.toLowerCase().contains(query.toLowerCase()))
          .toList(),
      playlists: [],
    );
  }

  FileWatcher? _fileWatcher;
  FileWatcher? get fileWatcher => _fileWatcher;

  final Lock _lock = Lock();
  Future<void> init({String? newDirectory, bool forceInit = false}) async {
    await _lock.synchronized(() async {
      if (forceInit == false && (_audios != null && _audios!.isNotEmpty)) {
        return;
      }

      if (newDirectory != null &&
          newDirectory != _settingsService?.getString(SPKeys.directory)) {
        await _settingsService?.setValue(SPKeys.directory, newDirectory);
      }
      final dir = newDirectory ?? _settingsService?.getString(SPKeys.directory);

      final result = await compute(_readAudiosFromDirectory, dir);
      _failedImports = result.failedImports;

      if (!isWindows &&
          dir != null &&
          Directory(dir).existsSync() &&
          (_fileWatcher == null || _fileWatcher!.path != dir)) {
        _fileWatcher = FileWatcher(dir);
      }

      addAudiosAndBuildCollection(result.audios, clear: forceInit);
    });
  }

  Future<void> dispose() async => _audiosController.close();

  void addAudiosAndBuildCollection(
    List<Audio> newAudios, {
    bool clear = false,
  }) {
    if (clear) {
      _albumCache.clear();
      _titlesOfArtistCache.clear();
      _albumIDsOfGenreCache.clear();
      _coverPathCache.clear();
      _audios = null;
      _audiosController.add(true);
    }

    _audios ??= [];

    if (_audios!.isEmpty) {
      _audios = newAudios;
    } else {
      final set = Set<Audio>.from(_audios!);
      set.addAll(newAudios);
      _audios = set.toList();
    }

    _sortAllTitles();
    _findAllArtists();
    findAllAlbumIDs();
    _findAllGenres();
    _audiosController.add(true);
  }

  void changeMetadata(
    Audio audio, {
    Function? onChange,
    String? title,
    String? artist,
    String? album,
    String? genre,
    String? discTotal,
    String? discNumber,
    String? trackNumber,
    String? durationMs,
    String? year,
    List<Picture>? pictures,
  }) {
    if (audio.path != null) {
      final file = File(audio.path!);
      if (file.existsSync()) {
        updateMetadata(file, (metadata) {
          try {
            if (title != null) {
              metadata.setTitle(title);
            }
            if (artist != null) {
              metadata.setArtist(artist);
            }
            if (album != null) {
              metadata.setAlbum(album);
            }
            if (genre != null) {
              metadata.setGenres([genre]);
            }
            if (trackNumber != null && int.tryParse(trackNumber) != null) {
              metadata.setTrackNumber(int.tryParse(trackNumber));
            }
            if (year != null && int.tryParse(year) != null) {
              metadata.setYear(DateTime(int.parse(year)));
            }
            if (pictures?.isNotEmpty ?? false) {
              metadata.setPictures(pictures!);
            }

            // Not supported yet
            // if (discNumber != null) {
            //   metadata.setDiscNumber(discNumber);
            // }
            // if (discTotal != null) {
            //   metadata.setDiscTotal(discTotal);
            // }
            // if (durationMs != null) {
            //   metadata.setDuration(durationMs);
            // }
            // if (albumArtist != null) {
            //   metadata.setAlbumArtist(albumArtist);
            // }

            onChange?.call();
          } on Exception catch (e) {
            printMessageInDebugMode(e);
          }
        });
      }
    }
  }
}

FutureOr<ImportResult> _readAudiosFromDirectory(String? directory) async {
  final List<Audio> newAudios = [];
  final List<String> failedImports = [];

  if (directory != null && Directory(directory).existsSync()) {
    final files =
        (await Directory(directory)
                .list(recursive: true, followLinks: false)
                .handleError((e) => failedImports.add(e.toString()))
                .toList())
            .whereType<File>();

    for (final e in files) {
      if (e.isPlayable) {
        try {
          newAudios.add(Audio.local(e, onError: (p) => failedImports.add(p)));
        } on Exception catch (ex) {
          failedImports.add(e.path);
          printMessageInDebugMode(ex);
        }
      }
    }
  }

  return (audios: newAudios, failedImports: failedImports);
}

typedef ImportResult = ({List<String> failedImports, List<Audio> audios});
