import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../common/view/audio_filter.dart';
import 'local_audio_service.dart';

class LocalAudioModel extends SafeChangeNotifier {
  LocalAudioModel({
    required LocalAudioService localAudioService,
  }) : _localAudioService = localAudioService;

  final LocalAudioService _localAudioService;

  StreamSubscription<bool>? _audiosChangedSub;

  Set<Audio>? _albumSearchResult;
  Set<Audio>? get albumSearchResult => _albumSearchResult;

  Set<Audio>? _titlesSearchResult;
  Set<Audio>? get titlesSearchResult => _titlesSearchResult;

  Set<Audio>? _artistsSearchResult;
  Set<Audio>? get similarArtistsSearchResult => _artistsSearchResult;

  Set<Audio>? _genresSearchResult;
  Set<Audio>? get genresSearchResult => _genresSearchResult;

  String? _searchQuery;
  String? get searchQuery => _searchQuery;
  void search(String? query) {
    _searchQuery = query;
    if (query == null) return;
    if (query.isEmpty) {
      _titlesSearchResult = {};
      _albumSearchResult = {};
      _artistsSearchResult = {};
      _genresSearchResult = {};
      notifyListeners();
      return;
    }

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

    final genreFindings = <Audio>{};
    if (allGenresFindings != null) {
      for (var a in allGenresFindings) {
        if (genreFindings.none((element) => element.genre == a.genre)) {
          genreFindings.add(a);
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

    _titlesSearchResult = Set.from(
      audios?.where(
            (audio) =>
                audio.title?.isNotEmpty == true &&
                audio.title!.toLowerCase().contains(query.toLowerCase()),
          ) ??
          <Audio>[],
    );
    _albumSearchResult = albumsResult;
    _artistsSearchResult = artistsResult;
    _genresSearchResult = genreFindings;
    notifyListeners();
  }

  Set<Audio>? _titles;
  Set<Audio>? get audios => _titles;
  Set<Audio>? _findAllTitles() {
    if (_localAudioService.audios == null) return null;
    final list = (_localAudioService.audios!).toList();
    sortListByAudioFilter(
      audioFilter: AudioFilter.title,
      audios: list,
    );

    return Set.from(list);
  }

  Set<Audio>? _allArtists;
  Set<Audio>? get allArtists => _allArtists;
  Set<Audio>? _findAllArtists() {
    if (audios == null) return null;
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
    return Set.from(list);
  }

  Set<Audio>? _allGenres;
  Set<Audio>? get allGenres => _allGenres;
  Set<Audio>? _findAllGenres() {
    if (audios == null) return null;
    final genresResult = <Audio>{};
    for (var a in audios!) {
      if (genresResult.none(
            (e) => e.genre == a.genre,
          ) &&
          a.genre?.isNotEmpty == true) {
        genresResult.add(a);
      }
    }
    final list = genresResult.toList();
    sortListByAudioFilter(
      audioFilter: AudioFilter.genre,
      audios: list,
    );
    return Set.from(list);
  }

  Set<Audio>? _allAlbums;
  Set<Audio>? get allAlbums => _allAlbums;
  Set<Audio>? findAllAlbums({Iterable<Audio>? newAudios}) {
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
    return Set.from(list);
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

  Set<Audio>? findArtist(
    Audio audio, [
    AudioFilter audioFilter = AudioFilter.album,
  ]) {
    final album = audios?.where(
      (a) => a.artist != null && a.artist == audio.artist,
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

  Set<Audio>? findArtistsOfGenre(
    Audio audio,
  ) {
    if (audios == null) return null;
    final artistsOfGenre = <Audio>{};

    for (var artistAudio in audios!) {
      if (artistAudio.genre?.trim().isNotEmpty == true &&
          artistAudio.genre == audio.genre &&
          artistsOfGenre.none((e) => e.artist == artistAudio.artist)) {
        artistsOfGenre.add(artistAudio);
      }
    }

    return artistsOfGenre;
  }

  Set<Audio>? findGenre(
    Audio audio, [
    AudioFilter audioFilter = AudioFilter.genre,
  ]) {
    final genre = audios?.where(
      (a) => a.genre != null && a.genre == audio.genre,
    );

    var genreList = genre?.toList();
    if (genreList != null) {
      sortListByAudioFilter(
        audioFilter: audioFilter,
        audios: genreList,
      );
    }
    return genreList != null ? Set.from(genreList) : null;
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
      if (audio.pictureData != null) {
        images.add(audio.pictureData!);
      }
    }

    return images;
  }

  List<String>? _failedImports;
  List<String>? get failedImports => _failedImports;

  Future<void> init({
    bool forceInit = false,
  }) async {
    if (forceInit ||
        (_localAudioService.audios == null ||
            _localAudioService.audios?.isEmpty == true)) {
      if (forceInit) {
        _titles = null;
        notifyListeners();
      }

      _failedImports = await _localAudioService.init();

      _titles = _findAllTitles();
      _allAlbums = findAllAlbums();
      _allArtists = _findAllArtists();
      _allGenres = _findAllGenres();
    } else {
      _titles ??= _findAllTitles();
      _allAlbums ??= findAllAlbums();
      _allArtists ??= _findAllArtists();
      _allGenres ??= _findAllGenres();
    }

    _audiosChangedSub ??= _localAudioService.audiosChanged.listen((_) {
      notifyListeners();
    });

    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _audiosChangedSub?.cancel();
    super.dispose();
  }
}
