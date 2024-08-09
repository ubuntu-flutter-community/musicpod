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
  List<Audio>? titles,
  List<String>? artists,
  List<String>? albums,
  List<String>? genres,
});

class LocalAudioService {
  final SettingsService _settingsService;

  LocalAudioService({required SettingsService settingsService})
      : _settingsService = settingsService;

  List<Audio>? _audios;
  List<Audio>? get audios => _audios;
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

    _audios = List.from(list);
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

    _allGenres = List.from(list);
  }

  List<String>? _allAlbums;
  List<String>? get allAlbums => _allAlbums;
  List<String>? findAllAlbums({Iterable<Audio>? newAudios, bool clean = true}) {
    final theAudios = newAudios ?? audios;
    if (theAudios == null) return null;
    final albumsResult = <String>[];
    for (var a in theAudios) {
      if (a.album != null && albumsResult.none((e) => e == a.album)) {
        albumsResult.add(a.album!);
      }
    }
    final list = albumsResult.toList();
    list.sort();

    if (clean) {
      _allAlbums = List.from(list);
      return _allAlbums;
    } else {
      return List.from(list);
    }
  }

  List<Audio>? findAlbum(
    String albumName, [
    AudioFilter audioFilter = AudioFilter.trackNumber,
  ]) {
    final album = audios?.where(
      (a) => a.album != null && a.album == albumName,
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
    if (audios == null) return null;
    final artistsOfGenre = <String>[];

    for (var artistAudio in audios!) {
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

    final albumAudios = <Audio>[];
    for (var audio in audios) {
      if (albumAudios.none((a) => a.album == audio.album)) {
        albumAudios.add(audio);
      }
    }

    for (var audio in albumAudios) {
      var uint8list = CoverStore().get(audio.albumId);
      if (uint8list != null && images.length < limit) {
        images.add(uint8list);
      }
    }

    return images;
  }

  LocalSearchResult? search(String? query) {
    if (query == null) return null;
    if (query.isEmpty) return (titles: [], artists: [], albums: [], genres: []);

    final allAlbumsFindings =
        allAlbums?.where((e) => e.toLowerCase().contains(query.toLowerCase()));

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

    return (
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
    );
  }

  Future<void> init({
    String? directory,
    bool forceInit = false,
  }) async {
    if (forceInit == false && _audios?.isNotEmpty == true) return;
    // TODO: Add a dialog for when people have X (too many) music files
    // ask them to confirm that for them no local cache is being loaded and saved
    // because such a cache will always be to big
    if (kDebugMode) await CoverStore().read();
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
    // TODO: delete this when the setting is added
    if (kDebugMode) await CoverStore().write();
    return _audiosController.close();
  }
}

FutureOr<ImportResult> _readAudiosFromDirectory(String? directory) async {
  List<Audio> newAudios = [];
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

typedef ImportResult = ({List<String> failedImports, List<Audio> audios});
