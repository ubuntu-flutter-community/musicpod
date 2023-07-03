import 'dart:async';
import 'dart:typed_data';

import 'package:collection/collection.dart';
import 'package:musicpod/app/common/audio_filter.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/service/local_audio_service.dart';
import 'package:musicpod/utils.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

class LocalAudioModel extends SafeChangeNotifier {
  LocalAudioModel(this._service);

  final LocalAudioService _service;

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

  Set<Audio> findAllArtists() {
    final artistsResult = <Audio>{};
    if (audios != null) {
      for (var a in audios!) {
        if (artistsResult.none(
          (e) => e.artist == a.artist,
        )) {
          artistsResult.add(a);
        }
      }
    }
    return artistsResult;
  }

  Set<Audio> findAllAlbums() {
    final albumsResult = <Audio>{};
    if (audios != null) {
      for (var a in audios!) {
        if (albumsResult.none((element) => element.album == a.album)) {
          albumsResult.add(a);
        }
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

  String? get directory => _service.directory;
  Future<void> setDirectory(String? value) async =>
      _service.setDirectory(value);

  Set<Audio>? get audios => _service.audios;
  set audios(Set<Audio>? value) => _service.audios = value;

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

  @override
  Future<void> dispose() async {
    _directoryChangedSub?.cancel();
    _audiosChangedSub?.cancel();
    super.dispose();
  }

  Future<void> init({
    required void Function(List<String> failedImports) onFail,
    bool forceInit = false,
  }) async {
    if (forceInit ||
        (_service.audios == null || _service.audios?.isEmpty == true)) {
      final failedImports = await _service.init();

      if (failedImports.isNotEmpty) {
        onFail(failedImports);
      }
    }

    _directoryChangedSub = _service.directoryChanged.listen((_) {
      notifyListeners();
    });
    _audiosChangedSub = _service.audiosChanged.listen((_) {
      notifyListeners();
    });

    notifyListeners();
  }
}
