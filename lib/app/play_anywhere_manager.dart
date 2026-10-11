import 'dart:async';

import 'package:flutter_it/flutter_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:injectable/injectable.dart';

import '../common/data/app_exceptions.dart';
import '../common/logging.dart';
import '../common/view/audio_page_type.dart';
import '../extensions/command_x.dart';
import '../local_audio/service/local_audio_service.dart';
import '../player/manager/player_manager.dart';
import '../podcasts/manager/episodes_manager.dart';
import '../radio/manager/station_manager.dart';
import '../radio/service/radio_service.dart';
import 'data/play_anywhere_bad_audios_exception.dart';
import 'data/play_anywhere_param.dart';
import 'data/play_anywhere_result.dart';

import '../common/util/family.dart';

@injectable
class PlayAnywhereManager {
  final PlayerManager _playerManager;

  PlayAnywhereManager._({required PlayerManager playerManager})
    : _playerManager = playerManager {
    Logger.o(tag: '$PlayAnywhereManager');
  }

  @factoryMethod
  static PlayAnywhereManager create({required PlayerManager playerManager}) =>
      Family.of(
        '$PlayAnywhereManager',
        () => PlayAnywhereManager._(playerManager: playerManager),
        shouldDispose: (m) => m.command.safeToDispose,
        onDispose: (m) => m.command.dispose(),
      );

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
          await di<LocalAudioService>().findPlaylistById(param.pageId) ?? [],
      param: param,
    ),
    AudioPageType.likedAudio => PlayAnywhereResult(
      audios: await di<LocalAudioService>().findLikedAudios(),
      param: param,
    ),
    AudioPageType.album => PlayAnywhereResult(
      audios:
          await di<LocalAudioService>().findAlbum(
            int.parse(param.pageId),
          ) ??
          [],
      param: param,
    ),
    AudioPageType.radio => PlayAnywhereResult(
      audios: [
        ?(di.isRegistered<ProviderContainer>()
            ? await di<ProviderContainer>()
                .read(stationManagerProvider(param.pageId).future)
            : await di<RadioService>()
                .getAudioByUUID(param.pageId, fromDBOnly: false)),
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
    AudioPageType.artist => PlayAnywhereResult(
      audios:
          await di<LocalAudioService>().findTitlesOfArtist(param.pageId) ??
          [],
      param: param,
    ),
    _ => null,
  };
}
