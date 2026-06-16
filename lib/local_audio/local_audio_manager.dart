import 'dart:async';

import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../app/page_ids.dart';
import '../common/data/audio.dart';
import '../common/no_error_filter.dart';
import '../common/view/audio_filter.dart';
import 'local_audio_service.dart';
import 'playlist_action.dart';

@singleton
class LocalAudioManager {
  LocalAudioManager({required LocalAudioService localAudioService})
    : _localAudioService = localAudioService {
    togglePinnedAlbumIDsCommand.run();
    playlistIDsCommand.run();
    likedAudiosCommand.run();
  }

  final LocalAudioService _localAudioService;

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
    if (showPlaylistAddAudios.value && _localAudioService.audios == null) {
      initAudiosCommand.run((
        directory: null,
        forceInit: false,
        forceDbOnly: false,
      ));
    }
  }

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

        return _localAudioService.findAlbum(
          albumId,
          audioFilter ?? AudioFilter.trackNumber,
        );
      }, initialValue: null),
    );
  }

  Future<List<Audio>?> findTitlesOfArtist(
    String artist, [
    AudioFilter audioFilter = AudioFilter.album,
  ]) async => _localAudioService.findTitlesOfArtist(artist, audioFilter);

  Future<List<int>> findAlbumIDsOfArtist(String artist) async =>
      _localAudioService.findAlbumIDsOfArtist(artist);

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
      clear(
        clearFindAlbumsCommands: true,
        clearPlaylistContents: true,
        clearLikedAudiosCommand: true,
        clearPlaylistIDCommands: true,
        clearTogglePinnedAlbumIDsCommand: true,
      );
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
  void addLikedAudios(List<Audio> audios) => likedAudiosCommand.run(
    PlaylistChange(
      id: PageIDs.likedAudios,
      action: PlaylistAction.addTo,
      audios: audios,
    ),
  );
  void removeLikedAudios(List<Audio> audios) => likedAudiosCommand.run(
    PlaylistChange(
      id: PageIDs.likedAudios,
      action: PlaylistAction.removeFrom,
      audios: audios,
    ),
  );
  late final Command<PlaylistChange?, List<Audio>> likedAudiosCommand =
      Command.createAsync((param) async {
        if (param != null) {
          await _localAudioService.createOrChangeLikedAudios(param);
        }

        if (_localAudioService.likedAudios.isEmpty) {
          await _localAudioService.loadLikedAudios();
        }

        return _localAudioService.likedAudios;
      }, initialValue: _localAudioService.likedAudios);

  //
  // Playlists
  //

  final _playlistCommands = <String, Command<PlaylistChange, List<Audio>?>>{};
  Command<PlaylistChange, List<Audio>?> playlistCommand(String id) =>
      _playlistCommands.putIfAbsent(
        id,
        () => Command.createAsync((param) async {
          await _localAudioService.createOrChangePlaylist(param);
          await playlistIDsCommand.runAsync();
          return _localAudioService.getPlaylistById(id);
        }, initialValue: _localAudioService.getPlaylistById(id)),
      );

  late final Command<void, List<String>> playlistIDsCommand =
      Command.createAsyncNoParam(() async {
        await _localAudioService.loadPlaylistIDs();

        return _localAudioService.playlistIDs;
      }, initialValue: _localAudioService.playlistIDs);

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
      await playlistIDsCommand.runAsync();
    }
  });

  //
  // Pinned Albums
  //

  late final Command<int?, List<int>> togglePinnedAlbumIDsCommand =
      Command.createAsync((id) async {
        if (id != null) {
          if (_localAudioService.pinnedAlbumIDs.contains(id)) {
            await _localAudioService.unpinAlbum(id);
          } else {
            await _localAudioService.pinAlbum(id);
          }
        }

        if (_localAudioService.pinnedAlbumIDs.isEmpty) {
          await _localAudioService.loadPinnedAlbums();
        }

        return _localAudioService.pinnedAlbumIDs;
      }, initialValue: _localAudioService.pinnedAlbumIDs);

  void clear({
    bool clearPlaylistContents = true,
    bool clearFindAlbumsCommands = true,
    bool clearPlaylistIDCommands = false,
    bool clearTogglePinnedAlbumIDsCommand = false,
    bool clearLikedAudiosCommand = false,
  }) {
    _localAudioService.clearContentCaches(
      clearPlaylistContents: clearPlaylistContents,
    );
    if (clearFindAlbumsCommands) {
      _findAlbumCommands.clear();
    }
    if (clearPlaylistContents) {
      _playlistCommands.clear();
    }
    if (clearLikedAudiosCommand) {
      likedAudiosCommand.value = [];
    }
    if (clearPlaylistIDCommands) {
      playlistIDsCommand.value = [];
    }
    if (clearTogglePinnedAlbumIDsCommand) {
      togglePinnedAlbumIDsCommand.value = [];
    }
    importExternalPlaylistsCommand.value = [];
  }
}
