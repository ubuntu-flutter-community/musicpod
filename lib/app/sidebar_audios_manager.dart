import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:podcast_search/podcast_search.dart';

import '../common/data/audio.dart';
import '../common/data/audio_type.dart';
import '../common/logging.dart';
import '../local_audio/local_audio_manager.dart';
import '../player/player_model.dart';
import '../podcasts/data/find_episodes_param.dart';
import '../podcasts/data/podcast_update_capsule.dart';
import '../podcasts/podcast_manager.dart';
import '../radio/radio_manager.dart';

@Injectable(cache: true)
class SidebarAudiosManager {
  final PodcastManager _podcastManager;
  final LocalAudioManager _localAudioManager;
  final RadioManager _radioManager;
  final PlayerModel _playerModel;

  SidebarAudiosManager({
    required PodcastManager podcastManager,
    required LocalAudioManager localAudioManager,
    required RadioManager radioManager,
    required PlayerModel playerModel,
  }) : _localAudioManager = localAudioManager,
       _podcastManager = podcastManager,
       _radioManager = radioManager,
       _playerModel = playerModel {
    printMessageInDebugMode('$SidebarAudiosManager created');
  }

  late final Command<
    ({String pageId, Item? podcastItem}),
    ({String pageId, List<Audio> audios})?
  >
  playAudiosByIdCommand = Command.createAsync((param) async {
    final audios = await _getAudiosById(
      pageId: param.pageId,
      podcastItem: param.podcastItem,
    );

    if (audios?.firstOrNull?.audioType == AudioType.radio) {
      await _radioManager.clickStation(audios?.firstOrNull);
    }
    final isEnQueued =
        _playerModel.queueName != null &&
        _playerModel.queueName == param.pageId;
    if (isEnQueued) {
      _playerModel.isPlaying
          ? await _playerModel.pause()
          : await _playerModel.resume();
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

  Future<List<Audio>?> _getAudiosById({
    required String pageId,
    required Item? podcastItem,
  }) async {
    if (_radioManager.toggleStarStationCommand.value.contains(pageId)) {
      final audio = await _radioManager
          .getStationByUUIDCommand(pageId)
          .runAsync();
      return audio == null ? [] : [audio];
    }

    if (_podcastManager.isPodcastSubscribed(pageId) || podcastItem != null) {
      return _podcastManager
          .getEpisodesCommand(pageId)
          .runAsync(
            FindEpisodesParam(
              item: podcastItem,
              feedUrl: pageId,
              tryFromDbOnly: true,
            ),
          );
    }

    if (_localAudioManager.isPlaylistSaved(pageId)) {
      return _localAudioManager.playlistCommand(pageId).value;
    }

    final albumId = int.tryParse(pageId);
    if (albumId != null) {
      return _localAudioManager.findAlbumCommand(albumId).runAsync();
    }

    return null;
  }
}
