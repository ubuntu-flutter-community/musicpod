import 'dart:async';
import 'dart:typed_data';

import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:watcher/watcher.dart';

import '../common/data/audio.dart';
import '../common/view/audio_filter.dart';
import '../library/library_service.dart';
import '../settings/settings_service.dart';
import 'local_audio_service.dart';

class LocalAudioModel extends SafeChangeNotifier {
  LocalAudioModel({
    required LocalAudioService localAudioService,
    required LibraryService libraryService,
    required SettingsService settingsService,
  })  : _localAudioService = localAudioService,
        _settingsService = settingsService,
        _libraryService = libraryService {
    _audiosChangedSub ??=
        _localAudioService.audiosChanged.listen((_) => notifyListeners());
  }

  final LocalAudioService _localAudioService;
  final LibraryService _libraryService;
  final SettingsService _settingsService;
  StreamSubscription<bool>? _audiosChangedSub;
  FileWatcher? get fileWatcher => _localAudioService.fileWatcher;

  int get localAudioindex => _settingsService.localAudioIndex;
  set localAudioindex(int value) {
    if (value == localAudioindex) return;
    // Note: we do not listen to the local audio index change on purpose, we just pump it into the sink
    // and load it fresh in init
    _settingsService.setLocalAudioIndex(value);
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

  List<Audio>? get audios => _localAudioService.audios;
  List<String>? get allArtists => _localAudioService.allArtists;
  List<String>? get allAlbumArtists => _localAudioService.allAlbumArtists;
  List<String>? get allGenres => _localAudioService.allGenres;
  List<String>? get allAlbums => _localAudioService.allAlbums;

  List<Audio>? findAlbum(
    String albumName, [
    AudioFilter audioFilter = AudioFilter.trackNumber,
  ]) =>
      _localAudioService.findAlbum(albumName, audioFilter);

  List<Audio>? findTitlesOfArtist(
    String artist, [
    AudioFilter audioFilter = AudioFilter.album,
  ]) =>
      _localAudioService.findTitlesOfArtist(artist, audioFilter);

  List<Audio>? findTitlesOfAlbumArtists(
    String artist, [
    AudioFilter audioFilter = AudioFilter.album,
  ]) =>
      _localAudioService.findTitlesOfAlbumArtists(artist, audioFilter);

  List<String>? findArtistsOfGenre(String genre) =>
      _localAudioService.findArtistsOfGenre(genre);

  Set<Uint8List>? findLocalCovers({
    required List<Audio> audios,
    int limit = 4,
  }) =>
      _localAudioService.findLocalCovers(audios: audios, limit: limit);

  List<Audio> findUniqueAlbumAudios(List<Audio> audios) =>
      _localAudioService.findUniqueAlbumAudios(audios);

  List<String>? get failedImports => _localAudioService.failedImports;

  List<String>? findAllAlbums({
    Iterable<Audio>? newAudios,
    bool clean = true,
  }) =>
      _localAudioService.findAllAlbums(newAudios: newAudios, clean: clean);

  bool get importing => _localAudioService.audios == null;

  Future<void> init({
    bool forceInit = false,
    String? directory,
  }) async {
    await _localAudioService.init(
      forceInit: forceInit,
      newDirectory: directory,
    );
    if (_libraryService.playlists.isEmpty) return;
    for (var playlist in _libraryService.playlists.entries.where(
      (e) => _settingsService.externalPlaylists.contains(e.key),
    )) {
      _localAudioService.addAudios(playlist.value);
    }
  }

  @override
  Future<void> dispose() async {
    await _audiosChangedSub?.cancel();
    super.dispose();
  }
}
