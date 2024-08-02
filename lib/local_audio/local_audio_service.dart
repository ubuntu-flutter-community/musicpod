import 'dart:async';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../common/data/audio.dart';
import '../common/view/audio_filter.dart';
import '../extensions/media_file_x.dart';
import '../settings/settings_service.dart';
import 'cover_store.dart';

typedef LocalSearchResult = ({
  Set<Audio>? titles,
  Set<Audio>? artists,
  Set<Audio>? albums,
  Set<String>? genres,
});

class LocalAudioService {
  final SettingsService _settingsService;

  LocalAudioService({required SettingsService settingsService})
      : _settingsService = settingsService;

  Set<Audio>? _audios;
  Set<Audio>? get audios => _audios;
  final _audiosController = StreamController<bool>.broadcast();
  Stream<bool> get audiosChanged => _audiosController.stream;
  List<String>? _failedImports;
  List<String>? get failedImports => _failedImports;

  void _sortAllTitles() {
    if (_audios == null) return;
    final list = _audios!.toList();
    sortListByAudioFilter(
      audioFilter: AudioFilter.title,
      audios: list,
    );

    _audios = Set.from(list);
  }

  Set<Audio>? _allArtists;
  Set<Audio>? get allArtists => _allArtists;
  void _findAllArtists() {
    if (_audios == null) return;
    final artistsResult = <Audio>{};
    for (var a in audios!) {
      if (artistsResult.none(
        (e) => e.artist == a.artist,
      )) {
        artistsResult.add(a);
      }
    }
    final list = artistsResult.toList();
    sortListByAudioFilter(
      audioFilter: AudioFilter.artist,
      audios: list,
    );
    _allArtists = Set.from(list);
  }

  Set<String>? _allGenres;
  Set<String>? get allGenres => _allGenres;
  void _findAllGenres() {
    if (_audios == null) return;
    final genresResult = <String>{};
    for (var a in audios!) {
      if (genresResult.none(
            (e) => e == a.genre,
          ) &&
          a.genre?.isNotEmpty == true) {
        genresResult.add(a.genre!);
      }
    }
    final list = genresResult.toList();
    list.sort();

    _allGenres = Set.from(list);
  }

  Set<Audio>? _allAlbums;
  Set<Audio>? get allAlbums => _allAlbums;
  Set<Audio>? findAllAlbums({Iterable<Audio>? newAudios, bool clean = true}) {
    final theAudios = newAudios ?? audios;
    if (theAudios == null) return null;
    final albumsResult = <Audio>{};
    for (var a in theAudios) {
      if (albumsResult.none((element) => element.album == a.album)) {
        albumsResult.add(a);
      }
    }
    final list = albumsResult.toList();
    sortListByAudioFilter(
      audioFilter: AudioFilter.album,
      audios: list,
    );

    if (clean) {
      _allAlbums = Set.from(list);
      return _allAlbums;
    } else {
      return Set.from(list);
    }
  }

  Set<Audio>? findAlbum(
    Audio audio, [
    AudioFilter audioFilter = AudioFilter.trackNumber,
  ]) {
    final album = audios?.where(
      (a) => a.album != null && a.album == audio.album,
    );

    var albumList = album?.toList();
    if (albumList != null) {
      sortListByAudioFilter(
        audioFilter: audioFilter,
        audios: albumList,
      );

      albumList = splitByDiscs(albumList).toList();
    }

    return albumList != null ? Set.from(albumList) : null;
  }

  Set<Audio>? findTitlesOfArtist(
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
    return artistList != null ? Set.from(artistList) : null;
  }

  Set<Audio>? findArtistsOfGenre(String genre) {
    if (audios == null) return null;
    final artistsOfGenre = <Audio>{};

    for (var artistAudio in audios!) {
      if (artistAudio.genre?.trim().isNotEmpty == true &&
          artistAudio.genre == genre &&
          artistsOfGenre.none((e) => e.artist == artistAudio.artist)) {
        artistsOfGenre.add(artistAudio);
      }
    }

    return artistsOfGenre;
  }

  Set<Uint8List>? findImages(Set<Audio> audios) {
    final images = <Uint8List>{};

    final albumAudios = <Audio>{};
    for (var audio in audios) {
      if (albumAudios.none((a) => a.album == audio.album)) {
        albumAudios.add(audio);
      }
    }

    for (var audio in albumAudios) {
      var uint8list = CoverStore().get(audio.albumId);
      if (uint8list != null) {
        images.add(uint8list);
      }
    }

    return images;
  }

  LocalSearchResult? search(String? query) {
    if (query == null) return null;
    if (query.isEmpty) return (titles: {}, artists: {}, albums: {}, genres: {});

    final allAlbumsFindings = audios?.where(
      (audio) =>
          audio.album?.isNotEmpty == true &&
          audio.album!.toLowerCase().contains(query.toLowerCase()),
    );

    final albumsResult = <Audio>{};
    if (allAlbumsFindings != null) {
      for (var a in allAlbumsFindings) {
        if (albumsResult.none((element) => element.album == a.album)) {
          albumsResult.add(a);
        }
      }
    }

    final allGenresFindings = audios?.where(
      (audio) =>
          audio.genre?.isNotEmpty == true &&
          audio.genre!.toLowerCase().contains(query.toLowerCase()),
    );

    final genreFindings = <String>{};
    if (allGenresFindings != null) {
      for (var a in allGenresFindings) {
        if (a.genre?.isNotEmpty == true &&
            genreFindings.none((element) => element == a.genre)) {
          genreFindings.add(a.genre!);
        }
      }
    }

    final allArtistFindings = audios?.where(
      (audio) =>
          audio.artist?.isNotEmpty == true &&
          audio.artist!.toLowerCase().contains(query.toLowerCase()),
    );
    final artistsResult = <Audio>{};
    if (allArtistFindings != null) {
      for (var a in allArtistFindings) {
        if (artistsResult.none(
          (e) => e.artist == a.artist,
        )) {
          artistsResult.add(a);
        }
      }
    }

    return (
      titles: Set.from(
        audios?.where(
              (audio) =>
                  audio.title?.isNotEmpty == true &&
                  audio.title!.toLowerCase().contains(query.toLowerCase()),
            ) ??
            <Audio>[],
      ),
      albums: albumsResult,
      genres: genreFindings,
      artists: artistsResult,
    );
  }

  Future<void> init({
    String? directory,
    bool forceInit = false,
  }) async {
    if (forceInit == false && _audios?.isNotEmpty == true) return;

    await CoverStore().read();

    final result = await compute(
      _readAudiosFromDirectory,
      directory ?? _settingsService.directory,
    );
    _audios = result.audios;
    _failedImports = result.failedImports;
    _sortAllTitles();
    _findAllArtists();
    findAllAlbums();
    _findAllGenres();
    _audiosController.add(true);
  }

  Future<void> dispose() async {
    await CoverStore().write();
    return _audiosController.close();
  }
}

FutureOr<ImportResult> _readAudiosFromDirectory(String? directory) async {
  Set<Audio> newAudios = {};
  List<String> failedImports = [];

  if (directory != null && Directory(directory).existsSync()) {
    for (var e in Directory(directory)
        .listSync(recursive: true, followLinks: false)
        .whereType<File>()
        .where((e) => e.isValidMedia)
        .toList()) {
      try {
        final metadata = await readMetadata(e, getImage: false);
        newAudios.add(Audio.fromMetadata(path: e.path, data: metadata));
      } catch (error) {
        failedImports.add(e.path);
      }
    }
  }

  return (audios: newAudios, failedImports: failedImports);
}

typedef ImportResult = ({List<String> failedImports, Set<Audio> audios});
