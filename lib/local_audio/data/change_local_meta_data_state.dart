import '../../common/data/audio.dart';
import 'change_metadata_capsule.dart';

class ChangeLocalMetaDataState {
  const ChangeLocalMetaDataState({this.draft, this.savedAudio});

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
