import 'dart:async';

import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../common/data/audio.dart';
import '../common/no_error_filter.dart';
import '../common/view/audio_filter.dart';
import 'local_audio_service.dart';
import 'playlist_action.dart';

@lazySingleton
class LocalAudioManager {
  LocalAudioManager({required LocalAudioService localAudioService})
    : _localAudioService = localAudioService;

  final LocalAudioService _localAudioService;

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
  ]) async {
    await _runInitIfNeeded();
    return _localAudioService.findTitlesOfArtist(artist, audioFilter);
  }

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

  Future<void> createOrChangePlaylist(PlaylistChange param) async {
    await _runInitIfNeeded();
    return _localAudioService.createOrChangePlaylist(param);
  }

  Future<List<Audio>?> findPlaylistById(String playlistId) async {
    await _runInitIfNeeded();
    return _localAudioService.findPlaylistById(playlistId);
  }

  Future<List<String>> findAllPlaylistIDs() async {
    await _runInitIfNeeded();
    return _localAudioService.findAllPlaylistIDs();
  }

  Future<List<Audio>> findAllTracks() async {
    await _runInitIfNeeded();
    return _localAudioService.findAllTracks();
  }
}
