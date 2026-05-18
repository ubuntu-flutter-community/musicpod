import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../common/data/audio.dart';
import '../common/data/audio_type.dart';
import '../local_audio/local_audio_manager.dart';
import '../player/player_model.dart';
import '../podcasts/podcast_manager.dart';
import '../radio/radio_manager.dart';

@lazySingleton
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
       _playerModel = playerModel;

  late final Command<String, void> playAudiosByIdCommand =
      Command.createAsyncNoResult((pageId) async {
        final audios = await _getAudiosById(pageId);

        if (audios?.firstOrNull?.audioType == AudioType.radio) {
          await _radioManager.clickStation(audios?.firstOrNull);
        }
        final isEnQueued =
            _playerModel.queueName != null && _playerModel.queueName == pageId;
        if (isEnQueued) {
          _playerModel.isPlaying
              ? await _playerModel.pause()
              : await _playerModel.resume();
        } else if (audios != null) {
          await _playerModel.startPlaylist(audios: audios, listName: pageId);
          await _podcastManager.updatesCommand.runAsync(
            PodcastUpdateCapsule(
              type: PodcastUpdateCapsuleType.remove,
              feedUrls: [pageId],
            ),
          );
        }
      });

  Future<List<Audio>?> _getAudiosById(String pageId) async {
    if (_radioManager.toggleStarStationCommand.value.contains(pageId)) {
      final audio = await _radioManager
          .getStationByUUIDCommand(pageId)
          .runAsync();
      return audio == null ? [] : [audio];
    }

    if (_podcastManager.isPodcastSubscribed(pageId)) {
      final episodes = await _podcastManager
          .getEpisodesCommand(pageId)
          .runAsync((item: null, feedUrl: pageId));
      return episodes;
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
