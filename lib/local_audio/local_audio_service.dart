import 'dart:async';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:watcher/watcher.dart';

import '../common/data/audio.dart';
import '../common/logging.dart';
import '../common/view/audio_filter.dart';
import '../extensions/media_file_x.dart';
import '../extensions/string_x.dart';
import '../settings/settings_service.dart';
import 'local_cover_service.dart';
import 'local_search_result.dart';

class LocalAudioService {
  final SettingsService? _settingsService;
  final LocalCoverService _localCoverService;

  LocalAudioService({
    required LocalCoverService localCoverService,
    SettingsService? settingsService,
  })  : _settingsService = settingsService,
        _localCoverService = localCoverService;

  List<Audio>? _audios;
  List<Audio>? get audios => _audios;
  final _audiosController = StreamController<bool>.broadcast();
  Stream<bool> get audiosChanged => _audiosController.stream;
  List<String>? _failedImports;
  List<String>? get failedImports => _failedImports;

  void _sortAllTitles() {
    if (_audios == null) return;
    sortListByAudioFilter(
      audioFilter: AudioFilter.title,
      audios: _audios!,
    );
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
      if (genresResult.none(
            (e) => e == a.genre,
          ) &&
          a.genre?.isNotEmpty == true) {
        genresResult.add(a.genre!);
      }
    }
    genresResult.sort();
    _allGenres = genresResult;
  }

  List<String>? _allAlbumIDs;
  List<String>? get allAlbumIDs => _allAlbumIDs;
  List<String>? findAllAlbumIDs({
    String? artist,
    bool clean = true,
  }) {
    final theAudios = artist == null || artist.isEmpty
        ? audios
        : audios?.where((e) => e.artist == artist);
    if (theAudios == null) return null;
    final albumsResult = <String>[];
    for (var a in theAudios) {
      if (a.albumId != null && albumsResult.none((e) => e == a.albumId)) {
        albumsResult.add(a.albumId!);
      }
    }
    albumsResult.sort(
      (a, b) => compareNatural(a.albumOfId, b.albumOfId),
    );

    if (clean) {
      _allAlbumIDs = albumsResult;
      return _allAlbumIDs;
    } else {
      return albumsResult;
    }
  }

  List<Audio>? findAlbum(
    String albumId, [
    AudioFilter audioFilter = AudioFilter.trackNumber,
  ]) {
    final album = audios?.where(
      (a) => a.albumId != null && a.albumId == albumId,
    );

    var albumList = album?.toList();
    if (albumList != null) {
      sortListByAudioFilter(
        audioFilter: audioFilter,
        audios: albumList,
      );

      albumList = splitByDiscs(albumList).toList();
    }

    return albumList;
  }

  List<Audio>? findTitlesOfArtist(
    String artist, [
    AudioFilter audioFilter = AudioFilter.album,
  ]) {
    final album = audios?.where(
      (a) => a.artist != null && a.artist == artist,
    );

    var artistList = album?.toList();
    if (artistList != null) {
      sortListByAudioFilter(
        audioFilter: audioFilter,
        audios: artistList,
      );
      artistList = splitByDiscs(artistList).toList();
    }
    return artistList != null ? List.from(artistList) : null;
  }

  List<String>? findArtistsOfGenre(String genre) {
    if (_audios == null) return null;
    final artistsOfGenre = <String>[];

    for (var artistAudio in _audios!) {
      if (artistAudio.genre?.trim().isNotEmpty == true &&
          artistAudio.genre == genre &&
          artistsOfGenre.none((e) => e == artistAudio.artist)) {
        artistsOfGenre.add(artistAudio.artist!);
      }
    }

    return artistsOfGenre;
  }

  Set<Uint8List>? findLocalCovers({
    required List<Audio> audios,
    int limit = 4,
  }) {
    final images = <Uint8List>{};

    List<Audio> albumAudios = findUniqueAlbumAudios(audios);

    for (var audio in albumAudios) {
      var uint8list = _localCoverService.get(audio.albumId);
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

    final allAlbumsFindings = allAlbumIDs
        ?.where((e) => e.albumOfId.toLowerCase().contains(query.toLowerCase()));

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
      titles: audios
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

  Future<void> init({String? newDirectory, bool forceInit = false}) async {
    if (forceInit == false && _audios?.isNotEmpty == true) return;

    if (newDirectory != null && newDirectory != _settingsService?.directory) {
      await _settingsService?.setDirectory(newDirectory);
    }
    final dir = newDirectory ?? _settingsService?.directory;

    final result = await compute(_readAudiosFromDirectory, dir);
    _failedImports = result.failedImports;

    if (!Platform.isWindows &&
        dir != null &&
        Directory(dir).existsSync() &&
        (_fileWatcher == null || _fileWatcher!.path != dir)) {
      _fileWatcher = FileWatcher(dir);
    }

    addAudios(
      result.audios,
      clear: forceInit,
    );
  }

  Future<void> dispose() async => _audiosController.close();

  void addAudios(List<Audio> newAudios, {bool clear = false}) {
    if (clear) {
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

    _buildLocalLibrary();
  }

  void _buildLocalLibrary() {
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
        updateMetadata(
          file,
          (metadata) {
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
          },
        );
      }
    }
  }
}

FutureOr<ImportResult> _readAudiosFromDirectory(String? directory) async {
  List<Audio> newAudios = [];
  List<String> failedImports = [];

  if (directory != null && Directory(directory).existsSync()) {
    final files = (await Directory(directory)
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
