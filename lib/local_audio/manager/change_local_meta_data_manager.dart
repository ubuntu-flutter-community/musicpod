import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../common/data/audio.dart';
import '../../dependencies.dart';
import '../data/change_metadata_capsule.dart';
import '../service/local_audio_service.dart';

part 'change_local_meta_data_manager.g.dart';

class ChangeLocalMetaDataState {
  const ChangeLocalMetaDataState({
    this.draft,
    this.savedAudio,
  });

  final ChangeMetadataCapsule? draft;
  final Audio? savedAudio;

  ChangeLocalMetaDataState copyWith({
    ChangeMetadataCapsule? Function()? draft,
    Audio? Function()? savedAudio,
  }) => ChangeLocalMetaDataState(
    draft: draft != null ? draft() : this.draft,
    savedAudio: savedAudio != null ? savedAudio() : this.savedAudio,
  );
}

@riverpod
class ChangeLocalMetaDataManager extends _$ChangeLocalMetaDataManager {
  @override
  ChangeLocalMetaDataState build(Audio audio) => const ChangeLocalMetaDataState();

  void updateDraft(ChangeMetadataCapsule newDraft) {
    final currentDraft = state.draft;
    final updated = currentDraft?.copyWith(
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
    ) ?? newDraft;
    state = state.copyWith(draft: () => updated);
  }

  Future<Audio?> save() async {
    final draft = state.draft;
    if (draft == null) return null;
    final result = await di<LocalAudioService>().changeMetadata(audio, draft);
    state = state.copyWith(savedAudio: () => result);
    return result;
  }
}
