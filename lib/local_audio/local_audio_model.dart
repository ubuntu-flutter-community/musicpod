import 'dart:async';
import 'dart:typed_data';

import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../common/view/audio_filter.dart';
import 'local_audio_service.dart';

class LocalAudioModel extends SafeChangeNotifier {
  LocalAudioModel({
    required LocalAudioService localAudioService,
  }) : _service = localAudioService;

  final LocalAudioService _service;
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

    final result = _service.search(query);

    _titlesSearchResult = result?.titles;
    _albumSearchResult = result?.albums;
    _artistsSearchResult = result?.artists;
    _genresSearchResult = result?.genres;
    notifyListeners();
  }

  Set<Audio>? get audios => _service.audios;
  Set<Audio>? get allArtists => _service.allArtists;
  Set<Audio>? get allGenres => _service.allGenres;
  Set<Audio>? get allAlbums => _service.allAlbums;

  Set<Audio>? findAlbum(
    Audio audio, [
    AudioFilter audioFilter = AudioFilter.trackNumber,
  ]) =>
      _service.findAlbum(audio, audioFilter);

  Set<Audio>? findTitlesOfArtist(
    String artist, [
    AudioFilter audioFilter = AudioFilter.album,
  ]) =>
      _service.findTitlesOfArtist(artist, audioFilter);

  Set<Audio>? findArtistsOfGenre(String genre) =>
      _service.findArtistsOfGenre(genre);

  Set<Uint8List>? findImages(Set<Audio> audios) => _service.findImages(audios);

  List<String>? get failedImports => _service.failedImports;

  Set<Audio>? findAllAlbums({Iterable<Audio>? newAudios, bool clean = true}) =>
      _service.findAllAlbums(newAudios: newAudios, clean: clean);

  Future<void> init({
    bool forceInit = false,
  }) async {
    await _service.init(forceInit: forceInit);
    _audiosChangedSub ??=
        _service.audiosChanged.listen((_) => notifyListeners());

    notifyListeners();
  }

  @override
  Future<void> dispose() async {
    await _audiosChangedSub?.cancel();
    super.dispose();
  }
}
