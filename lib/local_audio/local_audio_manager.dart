import 'dart:async';

import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../common/no_error_filter.dart';
import '../common/view/audio_filter.dart';
import 'local_audio_service.dart';
import 'playlist_action.dart';

@singleton
class LocalAudioManager {
  LocalAudioManager({required LocalAudioService localAudioService})
    : _localAudioService = localAudioService {}

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
  }

  Future<int?> findAlbumId({required String artist, required String album}) =>
      _localAudioService.findAlbumIdForArtistAndAlbum(
        artist: artist,
        album: album,
      );

  Future<String?> findAlbumName(int albumId) async {
    await _runInitIfNeeded();

    return _localAudioService.findAlbumName(albumId);
  }

  Future<String?> findArtistOfAlbum(int albumId) async {
    await _runInitIfNeeded();

    return _localAudioService.findArtistOfAlbum(albumId);
  }

  Future<List<Audio>?> findAlbum(int albumId) async {
    await _runInitIfNeeded();

    return _localAudioService.findAlbum(albumId);
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
    ({bool initialized, List<String> failedImports})?
  >
  initAudiosCommand = Command.createAsyncWithProgress((param, handle) async {
    final localAudioResult = await _localAudioService.init(
      forceInit: param.forceInit,
      newDirectory: param.directory,
      forceDbOnly: param.forceDbOnly,
      updateProgress: handle.updateProgress,
    );

    await areTracksSyncedCommand.runAsync();

    return localAudioResult;
  }, initialValue: null);

  Future<void> _runInitIfNeeded() async {
    if (initAudiosCommand.value == null) {
      await initAudiosCommand.runAsync((
        directory: null,
        forceInit: false,
        forceDbOnly: false,
      ));
    }
  }

  //
  // Playlists
  //

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
      await di<PlaylistIDsManager>().command.runAsync();
    }
  });

  //
  // Pinned Albums
  //

  Future<void> createOrChangePlaylist(PlaylistChange param) =>
      _localAudioService.createOrChangePlaylist(param);

  Future<List<Audio>?> findPlaylistById(String playlistId) async {
    await _runInitIfNeeded();
    return _localAudioService.findPlaylistById(playlistId);
  }

  Future<List<Audio>> findAllTracks() async {
    await _runInitIfNeeded();
    return _localAudioService.findAllTracks();
  }
}

@Injectable(cache: true)
class PinnedAlbumIDsManager {
  PinnedAlbumIDsManager({required LocalAudioService localAudioService}) {
    command = Command.createAsync((id) async {
      if (id != null) {
        if (await localAudioService.isPinnedAlbum(id)) {
          await localAudioService.unpinAlbum(id);
        } else {
          await localAudioService.pinAlbum(id);
        }
      }

      return localAudioService.findPinnedAlbumIDs();
    }, initialValue: []);
    command.run();
  }

  late final Command<int?, List<int>> command;
}

@Injectable(cache: true)
class PlaylistIDsManager {
  PlaylistIDsManager({required LocalAudioService localAudioService}) {
    command = Command.createAsyncNoParam(
      () => localAudioService.findAllPlaylistIDs(),
      initialValue: [],
    );
    command.run();
  }

  late final Command<void, List<String>> command;
}
