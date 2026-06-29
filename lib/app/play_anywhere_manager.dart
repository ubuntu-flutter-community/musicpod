import 'dart:async';

import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';

import '../common/data/app_exceptions.dart';
import '../common/logging.dart';
import '../common/view/audio_page_type.dart';
import '../extensions/command_x.dart';
import '../local_audio/manager/find_album_manager.dart';
import '../local_audio/manager/liked_audios_manager.dart';
import '../local_audio/manager/playlist_manager.dart';
import '../player/manager/player_manager.dart';
import '../podcasts/manager/episodes_manager.dart';
import '../radio/manager/station_manager.dart';
import 'data/play_anywhere_bad_audios_exception.dart';
import 'data/play_anywhere_param.dart';
import 'data/play_anywhere_result.dart';

@Injectable(cache: true)
class PlayAnywhereManager {
  final PlayerManager _playerManager;

  PlayAnywhereManager({required PlayerManager playerManager})
    : _playerManager = playerManager {
    Logger.o(tag: '$PlayAnywhereManager');
  }

  late final Command<PlayAnywhereParam, PlayAnywhereResult?> command =
      Command.createAsync(
        (param) => _playAudiosById(param).timeout(
          PlayAudiosByIdTimeoutException.timeoutDuration,
          onTimeout: () {
            throw PlayAudiosByIdTimeoutException(param.pageId);
          },
        ),
        initialValue: null,
      );

  Future<PlayAnywhereResult?> _playAudiosById(PlayAnywhereParam param) async {
    final result = await _getAudiosById(param: param);

    if (result == null || result.audios.isEmpty) {
      throw PlayAnywhereBadAudiosException(
        result ?? PlayAnywhereResult(audios: [], param: param),
      );
    }

    final isEnQueued = _playerManager.queue.name == param.pageId;
    if (isEnQueued) {
      _playerManager.isPlaying
          ? await _playerManager.pause()
          : await _playerManager.resume();
    } else {
      await _playerManager.play(audios: result.audios, listName: param.pageId);
    }

    return result;
  }

  Future<PlayAnywhereResult?> _getAudiosById({
    required PlayAnywhereParam param,
  }) async => switch (param.audioPageType) {
    AudioPageType.playlist => PlayAnywhereResult(
      audios:
          await di<PlaylistManager>(
            param1: param.pageId,
          ).command.runRestrictedAsync() ??
          [],
      param: param,
    ),
    AudioPageType.likedAudio => PlayAnywhereResult(
      audios: await di<LikedAudiosManager>().command.runRestrictedAsync() ?? [],
      param: param,
    ),
    AudioPageType.album => PlayAnywhereResult(
      audios:
          await di<FindAlbumManager>(
            param1: param.pageId,
          ).command.runRestrictedAsync() ??
          [],
      param: param,
    ),
    AudioPageType.radio => PlayAnywhereResult(
      audios: [
        ?await di<StationManager>(
          param1: param.pageId,
        ).command.runRestrictedAsync(),
      ],
      param: param,
    ),
    AudioPageType.podcast => PlayAnywhereResult(
      audios:
          (await di<EpisodesManager>(
            param1: param.pageId,
          ).command.runRestrictedAsync())?.episodes ??
          [],
      param: param,
    ),
    _ => null,
  };
}
