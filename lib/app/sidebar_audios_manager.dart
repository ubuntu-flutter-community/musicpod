import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../common/data/audio.dart';
import '../common/data/audio_type.dart';
import '../local_audio/local_audio_manager.dart';
import '../player/player_model.dart';
import '../podcasts/podcast_manager.dart';
import '../radio/radio_model.dart';

@lazySingleton
class SidebarAudiosManager {
  final PodcastManager _podcastModel;
  final LocalAudioManager _localAudioManager;
  final RadioManager _radioManager;
  final PlayerModel _playerModel;

  SidebarAudiosManager({
    required PodcastManager podcastManager,
    required LocalAudioManager localAudioManager,
    required RadioManager radioManager,
    required PlayerModel playerModel,
  }) : _localAudioManager = localAudioManager,
       _podcastModel = podcastManager,
       _radioManager = radioManager,
       _playerModel = playerModel;

  late final Command<String, void> playAudiosByIdCommand =
      Command.createAsyncNoResult((pageId) async {
        final audios = await _getAudiosById(pageId);

        if (audios?.firstOrNull?.audioType == AudioType.radio) {
          _radioManager.clickStation(audios?.firstOrNull);
        }
        final isEnQueued =
            _playerModel.queueName != null && _playerModel.queueName == pageId;
        if (isEnQueued) {
          _playerModel.isPlaying ? _playerModel.pause() : _playerModel.resume();
        } else if (audios != null) {
          _playerModel
              .startPlaylist(audios: audios, listName: pageId)
              .then((_) => _podcastModel.removePodcastUpdate(pageId));
        }
      });

  Future<List<Audio>?> _getAudiosById(String pageId) async {
    if (_radioManager.isStarredStation(pageId)) {
      final audio = await _radioManager
          .getStationByUUIDCommand(pageId)
          .runAsync();
      return audio == null ? [] : [audio];
    }

    if (_podcastModel.isPodcastSubscribed(pageId)) {
      final episodes = _podcastModel.getEpisodesCommand(pageId).runAsync((
        item: null,
        feedUrl: pageId,
      ));
      return episodes;
    }

    if (_localAudioManager.isPlaylistSaved(pageId)) {
      return _localAudioManager.getPlaylistById(pageId);
    }

    final albumId = int.tryParse(pageId);
    if (albumId != null) {
      return _localAudioManager.findAlbumCommand(albumId).runAsync();
    }

    return null;
  }
}
