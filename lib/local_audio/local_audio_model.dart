import 'dart:async';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';
import 'package:watcher/watcher.dart';

import '../common/data/audio.dart';
import '../common/view/audio_filter.dart';
import '../settings/settings_service.dart';
import 'local_audio_service.dart';

class LocalAudioModel extends SafeChangeNotifier {
  LocalAudioModel({
    required LocalAudioService localAudioService,
    required SettingsService settingsService,
  })  : _localAudioService = localAudioService,
        _settingsService = settingsService {
    _audiosChangedSub ??=
        _localAudioService.audiosChanged.listen((_) => notifyListeners());
    _settingsChangedSub ??=
        _settingsService.propertiesChanged.listen((_) => notifyListeners());
  }

  final LocalAudioService _localAudioService;
  final SettingsService _settingsService;
  StreamSubscription<bool>? _audiosChangedSub;
  StreamSubscription<bool>? _settingsChangedSub;
  FileWatcher? get fileWatcher => _localAudioService.fileWatcher;

  void changeMetadata(
    Audio audio, {
    Function? onChange,
    String? title,
    String? artist,
    String? album,
    String? genre,
    String? discTotal,
    String? discNumber,
    String? trackNumber,
    String? durationMs,
    String? year,
    List<Picture>? pictures,
  }) =>
      _localAudioService.changeMetadata(
        audio,
        onChange: onChange,
        title: title,
        artist: artist,
        album: album,
        genre: genre,
        discTotal: discTotal,
        discNumber: discNumber,
        trackNumber: trackNumber,
        durationMs: durationMs,
        year: year,
        pictures: pictures,
      );

  int get localAudioindex => _settingsService.localAudioIndex;
  void setLocalAudioindex(int value) =>
      _settingsService.setLocalAudioIndex(value);

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
  List<String>? get allGenres => _localAudioService.allGenres;
  List<String>? get allAlbumIDs => _localAudioService.allAlbumIDs;

  List<Audio>? findAlbum(
    String albumId, [
    AudioFilter audioFilter = AudioFilter.trackNumber,
  ]) =>
      _localAudioService.findAlbum(albumId, audioFilter);

  List<Audio>? findTitlesOfArtist(
    String artist, [
    AudioFilter audioFilter = AudioFilter.album,
  ]) =>
      _localAudioService.findTitlesOfArtist(artist, audioFilter);

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

  List<String>? findAllAlbumIDs({
    String? artist,
    bool clean = true,
  }) =>
      _localAudioService.findAllAlbumIDs(artist: artist, clean: clean);

  bool get importing => _localAudioService.audios == null;

  Future<void> init({bool forceInit = false, String? directory}) async =>
      _localAudioService.init(
        forceInit: forceInit,
        newDirectory: directory,
      );

  void addAudios(List<Audio> newAudios, {bool clear = false}) =>
      _localAudioService.addAudios(newAudios, clear: clear);

  @override
  Future<void> dispose() async {
    await _audiosChangedSub?.cancel();
    await _settingsChangedSub?.cancel();
    super.dispose();
  }
}
