import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../common/data/audio.dart';
import '../common/data/audio_type.dart';
import '../common/logging.dart';
import '../local_audio/manager/find_album_manager.dart';
import '../local_audio/manager/playlist_manager.dart';
import '../local_audio/manager/local_audio_manager.dart';
import '../player/player_manager.dart';
import '../podcasts/data/podcast_update_capsule.dart';
import '../podcasts/manager/episodes_manager.dart';
import '../podcasts/manager/podcast_manager.dart';
import '../podcasts/manager/subscribed_podcasts_manager.dart';
import '../radio/radio_manager.dart';
import '../radio/station_manager.dart';

@Injectable(cache: true)
class SidebarAudiosManager {
  final PodcastManager _podcastManager;
  final SubscribedPodcastsManager _podcastToggleManager;
  final RadioManager _radioManager;
  final PlayerManager _playerManager;

  SidebarAudiosManager({
    required PodcastManager podcastManager,
    required LocalAudioManager localAudioManager,
    required RadioManager radioManager,
    required SubscribedPodcastsManager podcastToggleManager,
    required PlayerManager playerManager,
  }) : _podcastManager = podcastManager,
       _podcastToggleManager = podcastToggleManager,
       _radioManager = radioManager,
       _playerManager = playerManager {
    printInfoInDebugMode(
      '$SidebarAudiosManager created',
      tag: '$SidebarAudiosManager',
    );
  }

  late final Command<({String pageId}), ({String pageId, List<Audio> audios})?>
  playAudiosByIdCommand = Command.createAsync((param) async {
    final audios = await _getAudiosById(pageId: param.pageId);

    if (audios?.firstOrNull?.audioType == AudioType.radio) {
      await _radioManager.clickStation(audios?.firstOrNull);
    }
    final isEnQueued =
        _playerManager.queueName != null &&
        _playerManager.queueName == param.pageId;
    if (isEnQueued) {
      _playerManager.isPlaying
          ? await _playerManager.pause()
          : await _playerManager.resume();
    } else if (audios != null) {
      await _podcastManager.manageUpdatesCommand.runAsync(
        PodcastUpdateCapsule(
          type: PodcastUpdateType.remove,
          feedUrls: [param.pageId],
        ),
      );

      return (pageId: param.pageId, audios: audios);
    }
    return null;
  }, initialValue: null);

  Future<List<Audio>?> _getAudiosById({required String pageId}) async {
    if (_radioManager.toggleStarStationCommand.value.contains(pageId)) {
      final audio = await di<StationManager>(param1: pageId).command.runAsync();
      return audio == null ? [] : [audio];
    }

    if (_podcastToggleManager.command.value.contains(pageId)) {
      return di<EpisodesManager>(param1: pageId).command.runAsync();
    }

    if (di<PlaylistManager>(param1: pageId).command.value != null) {
      return di<PlaylistManager>(param1: pageId).command.value;
    }

    final albumId = int.tryParse(pageId);
    if (albumId != null) {
      return di<FindAlbumManager>(param1: albumId).command.runAsync();
    }
    return null;
  }
}
