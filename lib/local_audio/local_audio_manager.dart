import 'dart:async';

import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../common/view/audio_filter.dart';
import 'data/change_metadata_capsule.dart';
import 'local_audio_service.dart';
import 'playlist_action.dart';

@lazySingleton
class LocalAudioManager extends SafeChangeNotifier {
  LocalAudioManager({required LocalAudioService localAudioService})
    : _localAudioService = localAudioService {
    _propertiesChangedSub ??= _localAudioService.propertiesChanged.listen(
      (_) => notifyListeners(),
    );
  }

  final LocalAudioService _localAudioService;
  StreamSubscription<bool>? _propertiesChangedSub;

  @disposeMethod
  @override
  Future<void> dispose() async {
    await _propertiesChangedSub?.cancel();
    super.dispose();
  }

  late final Command<ChangeMetadataCapsule, Audio?> changeMetadataCommand =
      Command.createAsync(
        (param) => _localAudioService.changeMetadata(param),
        initialValue: null,
      );

  final allowReorder = SafeValueNotifier<bool>(false);
  void setAllowReorder(bool value) {
    if (value == allowReorder.value) return;
    allowReorder.value = value;
  }

  final useArtistGridView = SafeValueNotifier<bool>(true);
  void setUseArtistGridView(bool value) {
    if (value == useArtistGridView.value) return;
    useArtistGridView.value = value;
  }

  final showPlaylistAddAudios = SafeValueNotifier<bool>(false);
  void setShowPlaylistAddAudios(bool value) {
    if (value == showPlaylistAddAudios.value) return;
    showPlaylistAddAudios.value = value;
    if (showPlaylistAddAudios.value && audios == null) {
      initAudiosCommand.run((
        directory: null,
        forceInit: false,
        forceDbOnly: false,
      ));
    }
  }

  List<Audio>? get audios => _localAudioService.audios;
  List<String>? get allArtists => _localAudioService.allArtists;
  List<String>? get allGenres => _localAudioService.allGenres;
  List<int>? get allAlbumIDs => _localAudioService.allAlbumIDs;

  int? findAlbumId({required String artist, required String album}) =>
      _localAudioService.findAlbumId(artist: artist, album: album);

  String? findAlbumName(int albumId) =>
      _localAudioService.findAlbumName(albumId);

  String? findArtistOfAlbum(int albumId) =>
      _localAudioService.findArtistOfAlbum(albumId);

  final _findAlbumCommands = <int, Command<AudioFilter?, List<Audio>?>>{};
  Command<AudioFilter?, List<Audio>?> findAlbumCommand(
    int albumId, {
    bool force = false,
  }) {
    if (force) {
      _findAlbumCommands.remove(albumId);
    }
    return _findAlbumCommands.putIfAbsent(
      albumId,
      () => Command.createAsync((audioFilter) async {
        if (initAudiosCommand.value == null) {
          await initAudiosCommand.runAsync((
            directory: null,
            forceInit: false,
            forceDbOnly: false,
          ));
        }

        return _localAudioService.getCachedAlbum(albumId) ??
            _localAudioService.findAlbum(
              albumId,
              audioFilter ?? AudioFilter.trackNumber,
            );
      }, initialValue: null),
    );
  }

  List<Audio>? getCachedTitlesOfArtist(String artist) =>
      _localAudioService.getCachedTitlesOfArtist(artist);
  Future<List<Audio>?> findTitlesOfArtist(
    String artist, [
    AudioFilter audioFilter = AudioFilter.album,
  ]) async => _localAudioService.findTitlesOfArtist(artist, audioFilter);

  List<int>? getCachedAlbumIDsOfGenre(String genre) =>
      _localAudioService.getCachedAlbumIDsOfGenre(genre);
  Future<List<int>?> findAlbumsIDOfGenre(String genre) async =>
      _localAudioService.findAlbumIDsOfGenre(genre);

  List<Audio> findUniqueAlbumAudios(List<Audio> audios) =>
      _localAudioService.findUniqueAlbumAudios(audios);

  List<int>? findAllAlbumIDs({String? artist, bool clean = true}) =>
      _localAudioService.findAllAlbumIDs(artist: artist, clean: clean);

  late final Command<void, bool> areTracksSyncedCommand =
      Command.createAsyncNoParam(
        _localAudioService.areTracksSynced,
        initialValue: true,
        errorFilter: NoErrorFilter(),
      );

  late final Command<
    ({bool forceInit, String? directory, bool forceDbOnly}),
    ({List<Audio> audios, List<String> failedImports})?
  >
  initAudiosCommand = Command.createAsyncWithProgress((param, handle) async {
    if (param.forceInit) {
      _findAlbumCommands.clear();
    }

    final localAudioResult = await _localAudioService.init(
      forceInit: param.forceInit,
      newDirectory: param.directory,
      forceDbOnly: param.forceDbOnly,
      updateProgress: handle.updateProgress,
    );

    await areTracksSyncedCommand.runAsync();

    return localAudioResult;
  }, initialValue: null);

  //
  // Liked Audios
  //
  int get likedAudiosLength => _localAudioService.likedAudiosLength;
  List<Audio> get likedAudios => _localAudioService.likedAudios;
  void addLikedAudio(Audio audio) => _localAudioService.addLikedAudio(audio);
  void addLikedAudios(List<Audio> audios) =>
      _localAudioService.addLikedAudios(audios);
  void removeLikedAudios(List<Audio> audios) =>
      _localAudioService.removeLikedAudios(audios);
  bool isLikedAudio(Audio? audio) =>
      audio == null ? false : _localAudioService.isLiked(audio);
  bool isLikedAudios(List<Audio> audios) =>
      _localAudioService.isLikedAudios(audios);
  void removeLikedAudio(Audio audio, [bool notify = true]) =>
      _localAudioService.removeLikedAudio(audio, notify);

  //
  // Playlists
  //

  final _playlistCommands = <String, Command<PlaylistChange, List<Audio>?>>{};
  Command<PlaylistChange, List<Audio>?> playlistCommand(String id) =>
      _playlistCommands.putIfAbsent(
        id,
        () => Command.createAsync((param) async {
          await _localAudioService.createOrChangePlaylist(param);

          return _localAudioService.getPlaylistById(id);
        }, initialValue: _localAudioService.getPlaylistById(id)),
      );

  List<String> get playlistIDs => _localAudioService.playlistIDs;

  bool isPlaylistSaved(String? id) => _playlistCommands.containsKey(id);

  late final Command<List<({String id, List<Audio> audios})>, void>
  importExternalPlaylistsCommand = Command.createAsyncNoResult((
    playlists,
  ) async {
    for (final playlist in playlists) {
      await _localAudioService.createOrChangePlaylist(
        PlaylistChange(
          id: playlist.id,
          audios: playlist.audios,
          action: PlaylistAction.create,
          external: true,
        ),
      );
    }
  });

  Future<void> removePlaylist(String id) =>
      _localAudioService.removePlaylist(id);

  //
  // Pinned Albums
  //
  List<int> get pinnedAlbums => _localAudioService.pinnedAlbums;
  int get pinnedAlbumsLength => _localAudioService.pinnedAlbums.length;

  bool isPinnedAlbum(int id) => _localAudioService.isPinnedAlbum(id);

  void pinAlbum(
    int id, {
    // TODO: replace with command and sideeffect
    required Function() onFail,
  }) => _localAudioService.pinAlbum(id, onFail: onFail);

  void unpinAlbum(
    int id, {
    // TODO: replace with command and sideeffect
    required Function() onFail,
  }) => _localAudioService.unpinAlbum(id, onFail: onFail);
}

class NoErrorFilter extends ErrorFilter {
  @override
  ErrorReaction filter(Object error, StackTrace stackTrace) =>
      ErrorReaction.throwException;
}
