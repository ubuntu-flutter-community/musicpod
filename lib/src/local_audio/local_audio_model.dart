import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:ubuntu_service/ubuntu_service.dart';

import '../../common.dart';
import '../../data.dart';
import '../../library.dart';
import '../../local_audio.dart';

class LocalAudioModel extends SafeChangeNotifier {
  LocalAudioModel({
    required this.localAudioService,
    required this.libraryService,
  });

  final LocalAudioService localAudioService;
  final LibraryService libraryService;

  StreamSubscription<bool>? _audiosChangedSub;

  Set<Audio>? _albumSearchResult;
  Set<Audio>? get albumSearchResult => _albumSearchResult;

  Set<Audio>? _titlesSearchResult;
  Set<Audio>? get titlesSearchResult => _titlesSearchResult;

  Set<Audio>? _artistsSearchResult;
  Set<Audio>? get similarArtistsSearchResult => _artistsSearchResult;

  String? _searchQuery;
  String? get searchQuery => _searchQuery;
  void search(String? query) {
    _searchQuery = query;
    if (query == null) return;
    if (query.isEmpty) {
      _titlesSearchResult = {};
      _albumSearchResult = {};
      _artistsSearchResult = {};
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
    notifyListeners();
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

  Set<Audio>? _allAlbums;
  Set<Audio>? get allAlbums => _allAlbums;
  Set<Audio>? _findAllAlbums() {
    if (audios == null) return null;
    final albumsResult = <Audio>{};
    for (var a in audios!) {
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

  AudioFilter _audioFilter = AudioFilter.title;
  AudioFilter get audioFilter => _audioFilter;
  set audioFilter(AudioFilter value) {
    if (value == _audioFilter) return;
    _audioFilter = value;
    notifyListeners();
  }

  Set<Audio>? get audios {
    return localAudioService.audios;
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

  Future<void> init({
    required void Function(List<String> failedImports) onFail,
    bool forceInit = false,
  }) async {
    if (forceInit ||
        (localAudioService.audios == null ||
            localAudioService.audios?.isEmpty == true)) {
      final failedImports = await localAudioService.init();

      if (failedImports.isNotEmpty) {
        onFail(failedImports);
      }
    }

    _allAlbums = _findAllAlbums();
    _allArtists = _findAllArtists();

    _audiosChangedSub = localAudioService.audiosChanged.listen((_) {
      notifyListeners();
    });

    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _audiosChangedSub?.cancel();
    super.dispose();
  }

  bool _manualFilter = false;
  bool get manualFilter => _manualFilter;
  void setManualFilter(bool value) {
    if (value == _manualFilter) return;
    _manualFilter = value;
    notifyListeners();
  }
}

final localAudioModelProvider = ChangeNotifierProvider(
  (ref) => LocalAudioModel(
    localAudioService: getService<LocalAudioService>(),
    libraryService: getService<LibraryService>(),
  ),
);
