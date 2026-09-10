import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../../common/data/audio.dart';
import '../../common/logging.dart';
import '../../common/util/family.dart';
import '../data/change_metadata_capsule.dart';
import '../service/local_audio_service.dart';

@injectable
class ChangeLocalMetaDataManager {
  ChangeLocalMetaDataManager._({
    required Audio audio,
    required LocalAudioService localAudioService,
  }) : _audio = audio,
       _localAudioService = localAudioService {
    Logger.o(tag: '$ChangeLocalMetaDataManager:${audio.path}');
  }

  @factoryMethod
  static ChangeLocalMetaDataManager create({
    @factoryParam required Audio audio,
    required LocalAudioService localAudioService,
  }) => Family.of(
    audio.path ?? audio.url ?? audio.hashCode,
    () => ChangeLocalMetaDataManager._(
      audio: audio,
      localAudioService: localAudioService,
    ),
    shouldDispose: (m) => m.command.listenerCount == 0 && !m.draft.hasListeners,
    onDispose: (m) {
      m.command.dispose();
      m.draft.dispose();
    },
  );

  final Audio _audio;

  final LocalAudioService _localAudioService;

  final SafeValueNotifier<ChangeMetadataCapsule?> draft = SafeValueNotifier(
    null,
  );
  void updateDraft(ChangeMetadataCapsule newDraft) {
    draft.value =
        draft.value?.copyWith(
          title: newDraft.title,
          artist: newDraft.artist,
          album: newDraft.album,
          genre: newDraft.genre,
          discTotal: newDraft.discTotal,
          discNumber: newDraft.discNumber,
          trackNumber: newDraft.trackNumber,
          durationMs: newDraft.durationMs,
          year: newDraft.year,
          pictures: newDraft.pictures,
        ) ??
        newDraft;
  }

  late final Command<void, Audio?> command = Command.createAsyncNoParam(() {
    if (draft.value == null) return Future.value(null);
    return _localAudioService.changeMetadata(_audio, draft.value!);
  }, initialValue: null);
}
