import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../common/data/audio.dart';
import '../common/data/audio_type.dart';
import '../library/library_model.dart';
import '../local_audio/local_audio_manager.dart';
import '../player/player_model.dart';
import '../podcasts/podcast_model.dart';
import '../radio/radio_model.dart';

@lazySingleton
class SidebarAudiosManager {
  final LibraryModel _libraryModel;
  final LocalAudioManager _localAudioManager;
  final PodcastModel _podcastModel;
  final RadioManager _radioManager;
  final PlayerModel _playerModel;

  SidebarAudiosManager({
    required LibraryModel libraryModel,
    required LocalAudioManager localAudioManager,
    required PodcastModel podcastModel,
    required RadioManager radioManager,
    required PlayerModel playerModel,
  }) : _libraryModel = libraryModel,
       _localAudioManager = localAudioManager,
       _podcastModel = podcastModel,
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
              .then((_) => _libraryModel.removePodcastUpdate(pageId));
        }
      });

  Future<List<Audio>?> _getAudiosById(String pageId) async {
    if (_libraryModel.isStarredStation(pageId)) {
      final audio = await _radioManager
          .getStationByUUIDCommand(pageId)
          .runAsync();
      return audio == null ? [] : [audio];
    }

    if (_libraryModel.isPodcastSubscribed(pageId)) {
      final episodes =
          _podcastModel.getPodcastEpisodesFromCache(pageId) ??
          await _podcastModel.findEpisodes(feedUrl: pageId);
      return episodes;
    }

    if (_libraryModel.isPlaylistSaved(pageId)) {
      return _libraryModel.getPlaylistById(pageId);
    }

    return _localAudioManager.findAlbumCommand(pageId).runAsync();
  }
}
