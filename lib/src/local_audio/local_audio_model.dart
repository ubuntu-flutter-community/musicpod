import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../../common.dart';
import '../../data.dart';
import '../../library.dart';
import '../../local_audio.dart';
import '../../utils.dart';

class LocalAudioModel extends SafeChangeNotifier {
  LocalAudioModel({
    required this.localAudioService,
    required this.libraryService,
  });

  final LocalAudioService localAudioService;
  final LibraryService libraryService;

  bool _searchActive = false;
  bool get searchActive => _searchActive;
  void setSearchActive(bool value) {
    if (value == _searchActive) return;
    _searchActive = value;
    notifyListeners();
  }

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

  Set<Audio>? _similarArtistsSearchResult;
  Set<Audio>? get similarArtistsSearchResult => _similarArtistsSearchResult;
  void setSimilarArtistsSearchResult(Set<Audio>? value) {
    _similarArtistsSearchResult = value;
    notifyListeners();
  }

  void search() {
    if (searchQuery == null) return;

    final allAlbumsFindings = audios?.where(
      (audio) =>
          audio.album?.isNotEmpty == true &&
          audio.album!.toLowerCase().contains(searchQuery!.toLowerCase()),
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
          audio.artist!.toLowerCase().contains(searchQuery!.toLowerCase()),
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

    var titles = audios?.where(
          (audio) =>
              audio.title?.isNotEmpty == true &&
              audio.title!.toLowerCase().contains(searchQuery!.toLowerCase()),
        ) ??
        <Audio>{};
    setTitlesSearchResult(
      Set.from(
        titles,
      ),
    );
    setSimilarAlbumsSearchResult(albumsResult);
    setSimilarArtistsSearchResult(artistsResult);
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
    return artistsResult;
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
    return albumsResult;
  }

  AudioFilter _audioFilter = AudioFilter.title;
  AudioFilter get audioFilter => _audioFilter;
  set audioFilter(AudioFilter value) {
    if (value == _audioFilter) return;
    _audioFilter = value;
    notifyListeners();
  }

  String? get directory => localAudioService.directory;
  Future<void> setDirectory(String? value) async =>
      localAudioService.setDirectory(value);

  Set<Audio>? get audios {
    if (libraryService.localAudioCache?.isNotEmpty == true) {
      return libraryService.localAudioCache;
    }

    return localAudioService.audios;
  }

  Set<Audio>? findAlbum(
    Audio audio, [
    AudioFilter audioFilter = AudioFilter.trackNumber,
  ]) {
    final album = audios?.where(
      (a) => a.album != null && a.album == audio.album,
    );

    final albumList = album?.toList();
    if (albumList != null) {
      sortListByAudioFilter(
        audioFilter: audioFilter,
        audios: albumList,
      );
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

    final albumList = album?.toList();
    if (albumList != null) {
      sortListByAudioFilter(
        audioFilter: audioFilter,
        audios: albumList,
      );
    }
    return albumList != null ? Set.from(albumList) : null;
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

  int _selectedTab = 0;
  int get selectedTab => _selectedTab;
  set selectedTab(int value) {
    if (value == _selectedTab) return;
    _selectedTab = value;
    notifyListeners();
  }

  StreamSubscription<bool>? _directoryChangedSub;
  StreamSubscription<bool>? _audiosChangedSub;
  StreamSubscription<bool>? _localAudioCacheChangedSub;

  @override
  Future<void> dispose() async {
    _directoryChangedSub?.cancel();
    _audiosChangedSub?.cancel();
    _localAudioCacheChangedSub?.cancel();
    super.dispose();
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

    _directoryChangedSub = localAudioService.directoryChanged.listen((_) {
      notifyListeners();
    });
    _audiosChangedSub = localAudioService.audiosChanged.listen((_) {
      notifyListeners();
    });
    _localAudioCacheChangedSub =
        libraryService.localAudioCacheChanged.listen((_) {
      notifyListeners();
    });

    notifyListeners();
  }

  Future<void> disposeCacheSuggestion() async =>
      await libraryService.disposeCacheSuggestion();

  bool get cacheSuggestionDisposed => libraryService.cacheSuggestionDisposed;

  Future<void> createLocalAudioCache() async {
    if (audios?.isNotEmpty == false) return;
    await libraryService.writeLocalAudioCache(audios!);
  }
}
