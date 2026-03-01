import 'dart:async';
import 'dart:typed_data';

import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../common/view/audio_filter.dart';
import '../library/library_service.dart';
import '../settings/settings_service.dart';
import 'local_audio_service.dart';

class LocalAudioModel extends SafeChangeNotifier {
  LocalAudioModel({
    required LocalAudioService localAudioService,
    required SettingsService settingsService,
    required LibraryService libraryService,
  }) : _localAudioService = localAudioService,
       _settingsService = settingsService,
       _libraryService = libraryService {
    _audiosChangedSub ??= _localAudioService.audiosChanged.listen(
      (_) => notifyListeners(),
    );
    _settingsChangedSub ??= _settingsService.propertiesChanged.listen(
      (_) => notifyListeners(),
    );
  }

  final LocalAudioService _localAudioService;
  final LibraryService _libraryService;
  final SettingsService _settingsService;
  StreamSubscription<bool>? _audiosChangedSub;
  StreamSubscription<bool>? _settingsChangedSub;

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
  }) => _localAudioService.changeMetadata(
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

  bool _showPlaylistAddAudios = true;
  bool get showPlaylistAddAudios => _showPlaylistAddAudios;
  void setShowPlaylistAddAudios(bool value) {
    if (value == _showPlaylistAddAudios) return;
    _showPlaylistAddAudios = value;
    notifyListeners();
  }

  List<Audio>? get audios => _localAudioService.audios;
  List<String>? get allArtists => _localAudioService.allArtists;
  List<String>? get allGenres => _localAudioService.allGenres;
  List<String>? get allAlbumIDs => _localAudioService.allAlbumIDs;

  String? findAlbumId({required String artist, required String album}) =>
      _localAudioService.findAlbumId(artist: artist, album: album);

  List<Audio>? getCachedAlbum(String albumId) =>
      _localAudioService.getCachedAlbum(albumId);
  Future<List<Audio>?> findAlbum(
    String albumId, [
    AudioFilter audioFilter = AudioFilter.trackNumber,
  ]) => _localAudioService.findAlbum(albumId, audioFilter);

  String? getCachedCoverPath(String albumId) =>
      _localAudioService.getCachedCoverPath(albumId);
  Future<String?> findCoverPath(String albumId) async =>
      _localAudioService.findCoverPath(albumId);

  List<Audio>? getCachedTitlesOfArtist(String artist) =>
      _localAudioService.getCachedTitlesOfArtist(artist);
  Future<List<Audio>?> findTitlesOfArtist(
    String artist, [
    AudioFilter audioFilter = AudioFilter.album,
  ]) async => _localAudioService.findTitlesOfArtist(artist, audioFilter);

  List<String>? getCachedAlbumIDsOfGenre(String albumId) =>
      _localAudioService.getCachedAlbumIDsOfGenre(albumId);
  Future<List<String>?> findAlbumsIDOfGenre(String genre) async =>
      _localAudioService.findAlbumIDsOfGenre(genre);

  Set<Uint8List>? findLocalCovers({
    required List<Audio> audios,
    int limit = 4,
  }) => _localAudioService.findLocalCovers(audios: audios, limit: limit);

  List<Audio> findUniqueAlbumAudios(List<Audio> audios) =>
      _localAudioService.findUniqueAlbumAudios(audios);

  List<String>? findAllAlbumIDs({String? artist, bool clean = true}) =>
      _localAudioService.findAllAlbumIDs(artist: artist, clean: clean);

  late final Command<
    ({bool forceInit, String? directory}),
    ({List<Audio> audios, List<String> failedImports})
  >
  initAudiosCommand = Command.createAsync((param) async {
    final failedImports = await _localAudioService.init(
      forceInit: param.forceInit,
      newDirectory: param.directory,
      externalPlaylistAudios: _libraryService.externalPlaylistAudios,
    );

    return (
      audios: _localAudioService.audios ?? [],
      failedImports: failedImports,
    );
  }, initialValue: (audios: [], failedImports: []));
  void addAudios(List<Audio> newAudios) =>
      _localAudioService.addAudiosAndBuildCollection(newAudios);

  @override
  Future<void> dispose() async {
    await _audiosChangedSub?.cancel();
    await _settingsChangedSub?.cancel();
    super.dispose();
  }
}
