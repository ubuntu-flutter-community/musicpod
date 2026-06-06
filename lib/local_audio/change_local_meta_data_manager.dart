import 'package:flutter_it/flutter_it.dart';
import 'package:injectable/injectable.dart';
import 'package:safe_change_notifier/safe_change_notifier.dart';

import '../common/data/audio.dart';
import '../common/logging.dart';
import 'data/change_metadata_capsule.dart';
import 'local_audio_service.dart';

@Injectable(cache: true)
class ChangeLocalMetaDataManager {
  ChangeLocalMetaDataManager({
    @factoryParam required Audio audio,
    required LocalAudioService localAudioService,
  }) : _audio = audio,
       _localAudioService = localAudioService {
    printMessageInDebugMode(
      'Initializing ChangeLocalMetaDataManager for ${audio.path}',
    );
  }

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
