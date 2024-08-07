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

  int _localAudioIndex = 2;
  int get localAudioindex => _localAudioIndex;
  set localAudioindex(int value) {
    if (value == _localAudioIndex) return;
    _localAudioIndex = value;
    notifyListeners();
  }

  bool _allowReorder = false;
  bool get allowReorder => _allowReorder;
  void setAllowReorder(bool value) {
    if (value == _allowReorder) return;
    _allowReorder = value;
    notifyListeners();
  }

  bool _useArtistGridView = true;
  bool get useArtistGridView => _useArtistGridView;
  void setUseArtistGridView(bool value) {
    if (value == _useArtistGridView) return;
    _useArtistGridView = value;
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

  Set<Uint8List>? findImages({required List<Audio> audios, int limit = 4}) =>
      _service.findImages(audios: audios, limit: limit);

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
