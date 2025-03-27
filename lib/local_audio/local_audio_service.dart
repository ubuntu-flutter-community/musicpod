import 'dart:async';
import 'dart:io';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

import '../common/data/audio.dart';
import '../common/data/audio_type.dart';
import '../common/logging.dart';
import '../common/view/audio_filter.dart';
import '../extensions/media_file_x.dart';
import '../settings/settings_service.dart';
import 'local_cover_service.dart';

class LocalSearchResult {
  const LocalSearchResult({
    required this.titles,
    required this.artists,
    required this.albumArtists,
    required this.albums,
    required this.genres,
    required this.playlists,
  });

  final List<Audio>? titles;
  final List<String>? artists;
  final List<String>? albumArtists;
  final List<String>? albums;
  final List<String>? genres;
  final List<String>? playlists;
}

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

  List<String>? _allAlbumArtists;
  List<String>? get allAlbumArtists => _allAlbumArtists;
  void _findAllAlbumArtists() {
    if (_audios == null) return;
    final albumArtists = <String>[];
    for (var a in audios!) {
      final albumArtist = a.albumArtist;
      if (albumArtist?.isNotEmpty == true &&
          !albumArtists.contains(albumArtist)) {
        albumArtists.add(albumArtist!);
      }
    }
    _allAlbumArtists = albumArtists;
    _allAlbumArtists?.sort();
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

  List<Audio>? findTitlesOfAlbumArtists(
    String albumArtist, [
    AudioFilter audioFilter = AudioFilter.album,
  ]) {
    final album = audios?.where(
      (a) => a.albumArtist != null && a.albumArtist == albumArtist,
    );

    var albumArtistList = album?.toList();
    if (albumArtistList != null) {
      sortListByAudioFilter(
        audioFilter: audioFilter,
        audios: albumArtistList,
      );
      albumArtistList = splitByDiscs(albumArtistList).toList();
    }
    return albumArtistList != null ? List.from(albumArtistList) : null;
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
        albumArtists: [],
        albums: [],
        genres: [],
        playlists: [],
      );
    }

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
      albumArtists: allAlbumArtists
          ?.where((a) => a.toLowerCase().contains(query.toLowerCase()))
          .toList(),
      playlists: [],
    );
  }

  Future<void> init({
    String? directory,
    bool forceInit = false,
  }) async {
    if (forceInit == false && _audios?.isNotEmpty == true) return;

    final result = await compute(
      _readAudiosFromDirectory,
      directory ?? _settingsService?.directory,
    );
    _audios = result.audios;
    _failedImports = result.failedImports;
    _sortAllTitles();
    _findAllArtists();
    _findAllAlbumArtists();
    findAllAlbums();
    _findAllGenres();
    _audiosController.add(true);
  }

  Future<void> dispose() async => _audiosController.close();
}

FutureOr<ImportResult> _readAudiosFromDirectory(String? directory) async {
  List<Audio> newAudios = [];
  List<String> failedImports = [];

  if (directory != null && Directory(directory).existsSync()) {
    final entities = await Directory(directory)
        .list(recursive: true, followLinks: false)
        .handleError((e) => failedImports.add(e.toString()))
        .toList();

    for (final e in entities) {
      try {
        if (e is File) {
          if (e.couldHaveMetadata) {
            newAudios.add(
              Audio.fromMetadata(
                path: e.path,
                data: readMetadata(e, getImage: false),
              ),
            );
          } else if (e.isPlayable) {
            newAudios.add(
              Audio(
                path: e.path,
                title: basename(e.path),
                audioType: AudioType.local,
              ),
            );
          }
        }
      } on Exception catch (error) {
        printMessageInDebugMode(error);
        failedImports.add(e.path);
      }
    }
  }

  return (audios: newAudios, failedImports: failedImports);
}

typedef ImportResult = ({List<String> failedImports, List<Audio> audios});
