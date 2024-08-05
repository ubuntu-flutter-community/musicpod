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

  List<Audio>? _albumSearchResult;
  List<Audio>? get albumSearchResult => _albumSearchResult;

  List<Audio>? _titlesSearchResult;
  List<Audio>? get titlesSearchResult => _titlesSearchResult;

  List<Audio>? _artistsSearchResult;
  List<Audio>? get similarArtistsSearchResult => _artistsSearchResult;

  List<String>? _genresSearchResult;
  List<String>? get genresSearchResult => _genresSearchResult;

  String? _searchQuery;
  String? get searchQuery => _searchQuery;
  void search(String? query) {
    _searchQuery = query;
    if (query == null) return;
    if (query.isEmpty) {
      _titlesSearchResult = [];
      _albumSearchResult = [];
      _artistsSearchResult = [];
      _genresSearchResult = [];
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

  List<Audio>? get audios => _service.audios;
  List<Audio>? get allArtists => _service.allArtists;
  List<String>? get allGenres => _service.allGenres;
  List<Audio>? get allAlbums => _service.allAlbums;

  List<Audio>? findAlbum(
    Audio audio, [
    AudioFilter audioFilter = AudioFilter.trackNumber,
  ]) =>
      _service.findAlbum(audio, audioFilter);

  List<Audio>? findTitlesOfArtist(
    String artist, [
    AudioFilter audioFilter = AudioFilter.album,
  ]) =>
      _service.findTitlesOfArtist(artist, audioFilter);

  List<Audio>? findArtistsOfGenre(String genre) =>
      _service.findArtistsOfGenre(genre);

  Set<Uint8List>? findImages(List<Audio> audios) => _service.findImages(audios);

  List<String>? get failedImports => _service.failedImports;

  List<Audio>? findAllAlbums({Iterable<Audio>? newAudios, bool clean = true}) =>
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
