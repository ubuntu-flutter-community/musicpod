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

  LocalSearchResult? _localSearchResult;
  LocalSearchResult? get localSearchResult => _localSearchResult;

  String? _searchQuery;
  String? get searchQuery => _searchQuery;
  void search(String? query) {
    _searchQuery = query;
    if (query == null) return;
    if (query.isEmpty) {
      _localSearchResult = (titles: [], albums: [], artists: [], genres: []);
      notifyListeners();
      return;
    }
    _localSearchResult = _service.search(query);
    notifyListeners();
  }

  List<Audio>? get audios => _service.audios;
  List<String>? get allArtists => _service.allArtists;
  List<String>? get allGenres => _service.allGenres;
  List<String>? get allAlbums => _service.allAlbums;

  List<Audio>? findAlbum(
    String albumName, [
    AudioFilter audioFilter = AudioFilter.trackNumber,
  ]) =>
      _service.findAlbum(albumName, audioFilter);

  List<Audio>? findTitlesOfArtist(
    String artist, [
    AudioFilter audioFilter = AudioFilter.album,
  ]) =>
      _service.findTitlesOfArtist(artist, audioFilter);

  List<String>? findArtistsOfGenre(String genre) =>
      _service.findArtistsOfGenre(genre);

  Set<Uint8List>? findImages(List<Audio> audios) => _service.findImages(audios);

  List<String>? get failedImports => _service.failedImports;

  List<String>? findAllAlbums({
    Iterable<Audio>? newAudios,
    bool clean = true,
  }) =>
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
