import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../common/data/app_exceptions.dart';
import '../common/logging.dart';
import '../common/view/audio_page_type.dart';
import '../dependencies.dart';
import '../local_audio/service/local_audio_service.dart';
import '../player/manager/play_pause_manager.dart';
import '../player/manager/queue_manager.dart';
import '../podcasts/service/podcast_service.dart';
import '../radio/manager/station_manager.dart';
import '../radio/service/radio_service.dart';
import 'data/play_anywhere_bad_audios_exception.dart';
import 'data/play_anywhere_param.dart';
import 'data/play_anywhere_result.dart';

part 'play_anywhere_manager.g.dart';

@Riverpod(keepAlive: true)
class PlayAnywhereManager extends _$PlayAnywhereManager {
  PlayAnywhereParam? _activeParam;
  PlayAnywhereParam? get activeParam => _activeParam;

  @override
  AsyncValue<PlayAnywhereResult?> build() {
    Logger.o(tag: '$PlayAnywhereManager');
    return const AsyncData(null);
  }

  Future<PlayAnywhereResult?> play(PlayAnywhereParam param) async {
    _activeParam = param;
    state = const AsyncLoading();

    state = await AsyncValue.guard(() {
      return _playAudiosById(param).timeout(
        PlayAudiosByIdTimeoutException.timeoutDuration,
        onTimeout: () {
          throw PlayAudiosByIdTimeoutException(param.pageId);
        },
      );
    });

    _activeParam = null;
    return state.value;
  }

  Future<PlayAnywhereResult?> _playAudiosById(PlayAnywhereParam param) async {
    final result = await _getAudiosById(param: param);

    if (result == null || result.audios.isEmpty) {
      throw PlayAnywhereBadAudiosException(
        result ?? PlayAnywhereResult(audios: const [], param: param),
      );
    }

    final isEnQueued = ref.read(queueManagerProvider).name == param.pageId;
    if (isEnQueued) {
      ref.read(playPauseManagerProvider)
          ? await ref.read(playPauseManagerProvider.notifier).pause()
          : await ref.read(playPauseManagerProvider.notifier).resume();
    } else {
      await ref
          .read(playPauseManagerProvider.notifier)
          .play(audios: result.audios, listName: param.pageId);
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
          await di<LocalAudioService>().findAlbum(int.parse(param.pageId)) ??
          [],
      param: param,
    ),
    AudioPageType.radio => PlayAnywhereResult(
      audios: [
        ?(await ref
                .read(stationManagerProvider(param.pageId).future)
                .catchError((_) => null) ??
            await di<RadioService>().getAudioByUUID(
              param.pageId,
              fromDBOnly: false,
            )),
      ],
      param: param,
    ),
    AudioPageType.podcast => PlayAnywhereResult(
      audios: await di<PodcastService>().findEpisodes(
        feedUrl: param.pageId,
        tryFromDbOnly: true,
      ),
      param: param,
    ),
    AudioPageType.artist => PlayAnywhereResult(
      audios:
          await di<LocalAudioService>().findTitlesOfArtist(param.pageId) ?? [],
      param: param,
    ),
    _ => null,
  };
}
