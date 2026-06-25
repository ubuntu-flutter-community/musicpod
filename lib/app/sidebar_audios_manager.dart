import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../common/data/audio.dart';
import '../common/data/audio_type.dart';
import '../common/logging.dart';
import '../local_audio/manager/find_album_manager.dart';
import '../local_audio/manager/pinned_album_ids_manager.dart';
import '../local_audio/manager/playlist_ids_manager.dart';
import '../local_audio/manager/playlist_manager.dart';
import '../player/manager/player_manager.dart';
import '../podcasts/data/podcast_update_capsule.dart';
import '../podcasts/manager/episodes_manager.dart';
import '../podcasts/manager/podcast_updates_manager.dart';
import '../podcasts/manager/subscribed_podcasts_manager.dart';
import '../podcasts/service/podcast_service.dart';
import '../radio/manager/radio_manager.dart';
import '../radio/manager/radio_star_station_manager.dart';
import '../radio/manager/station_manager.dart';

@Injectable(cache: true)
class SidebarAudiosManager {
  final PodcastUpdatesManager _podcastUpdatesManager;
  final SubscribedPodcastsManager _podcastToggleManager;
  final RadioManager _radioManager;
  final RadioStarStationManager _radioStarStationManager;
  final PlayerManager _playerManager;
  final PlaylistIDsManager _playlistIDsManager;
  final PinnedAlbumIDsManager _pinnedAlbumIDsManager;

  SidebarAudiosManager({
    required PodcastService podcastService,
    required PodcastUpdatesManager podcastUpdatesManager,
    required PlaylistIDsManager playlistIDsManager,
    required RadioManager radioManager,
    required SubscribedPodcastsManager podcastToggleManager,
    required PlayerManager playerManager,
    required RadioStarStationManager radioStarStationManager,
    required PinnedAlbumIDsManager pinnedAlbumIDsManager,
  }) : _podcastToggleManager = podcastToggleManager,
       _radioManager = radioManager,
       _playerManager = playerManager,
       _podcastUpdatesManager = podcastUpdatesManager,
       _radioStarStationManager = radioStarStationManager,
       _playlistIDsManager = playlistIDsManager,
       _pinnedAlbumIDsManager = pinnedAlbumIDsManager {
    Logger.i('Instance created', tag: '$SidebarAudiosManager');
  }

  late final Command<({String pageId}), ({String pageId, List<Audio> audios})?>
  playAudiosByIdCommand = Command.createAsync(
    (param) => _playAudiosById(param).timeout(
      PlayAudiosByIdTimeoutException.timeoutDuration,
      onTimeout: () {
        throw PlayAudiosByIdTimeoutException(param.pageId);
      },
    ),
    initialValue: null,
  );

  Future<({List<Audio> audios, String pageId})?> _playAudiosById(
    ({String pageId}) param,
  ) async {
    final result = await _getAudiosById(pageId: param.pageId);
    final audios = result?.audios;
    final audioType = result?.audioType;

    final isEnQueued = _playerManager.queue.name == param.pageId;
    if (isEnQueued) {
      _playerManager.isPlaying
          ? await _playerManager.pause()
          : await _playerManager.resume();
    } else if (audios != null) {
      await _playerManager.play(audios: audios, listName: param.pageId);

      await _postPlayExtraStep(
        audioType: audioType,
        audios: audios,
        param: param,
      );

      return (pageId: param.pageId, audios: audios);
    }
    return null;
  }

  Future<({List<Audio>? audios, AudioType audioType})?> _getAudiosById({
    required String pageId,
  }) async {
    if (_radioStarStationManager.command.value.contains(pageId)) {
      final audio = await di<StationManager>(param1: pageId).command.runAsync();
      return audio == null
          ? null
          : (audios: [audio], audioType: AudioType.radio);
    }

    if (_podcastToggleManager.command.value.contains(pageId)) {
      return (
        audios: await di<EpisodesManager>(param1: pageId).command.runAsync(),
        audioType: AudioType.podcast,
      );
    }

    if (_playlistIDsManager.command.value.contains(pageId)) {
      return (
        audios: await di<PlaylistManager>(param1: pageId).command.runAsync(),
        audioType: AudioType.local,
      );
    }

    final albumId = int.tryParse(pageId);
    if (albumId != null &&
        _pinnedAlbumIDsManager.command.value.contains(albumId)) {
      return (
        audios: await di<FindAlbumManager>(param1: albumId).command.runAsync(),
        audioType: AudioType.local,
      );
    }
    return null;
  }

  Future<void> _postPlayExtraStep({
    required AudioType? audioType,
    required List<Audio> audios,
    required ({String pageId}) param,
  }) async {
    if (audioType == AudioType.radio) {
      await _radioManager.clickStation(audios.singleOrNull);
    } else if (audioType == AudioType.podcast) {
      await _podcastUpdatesManager.command.runAsync(
        PodcastUpdateCapsule(
          type: PodcastUpdateType.remove,
          feedUrls: [param.pageId],
        ),
      );
    }
  }
}

class PlayAudiosByIdTimeoutException implements Exception {
  final String pageId;

  static const Duration timeoutDuration = Duration(seconds: 10);

  PlayAudiosByIdTimeoutException(this.pageId);

  @override
  String toString() => 'PlayAudiosByIdTimeoutException: $pageId';
}
