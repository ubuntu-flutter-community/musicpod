import 'package:audio_metadata_reader/audio_metadata_reader.dart';

import '../l10n/l10n.dart';

extension PictureTypeX on PictureType {
  String localize(AppLocalizations l10n) {
    return switch (this) {
      PictureType.other => l10n.localPictureTypeOther,
      PictureType.fileIcon32x32 => l10n.localPictureTypeFileIcon32x32,
      PictureType.otherFileIcon => l10n.localPictureTypeOtherFileIcon,
      PictureType.coverFront => l10n.localPictureTypeCoverFront,
      PictureType.coverBack => l10n.localPictureTypeCoverBack,
      PictureType.leafletPage => l10n.localPictureTypeLeafletPage,
      PictureType.mediaLabelCD => l10n.localPictureTypeMediaLabelCD,
      PictureType.leadArtist => l10n.localPictureTypeLeadArtist,
      PictureType.artistPerformer => l10n.localPictureTypeArtistPerformer,
      PictureType.conductor => l10n.localPictureTypeConductor,
      PictureType.bandOrchestra => l10n.localPictureTypeBandOrchestra,
      PictureType.composer => l10n.localPictureTypeComposer,
      PictureType.lyricistTextWriter => l10n.localPictureTypeLyricistTextWriter,
      PictureType.recordingLocation => l10n.localPictureTypeRecordingLocation,
      PictureType.duringRecording => l10n.localPictureTypeDuringRecording,
      PictureType.duringPerformance => l10n.localPictureTypeDuringPerformance,
      PictureType.movieVideoScreenCapture =>
        l10n.localPictureTypeMovieVideoScreenCapture,
      PictureType.brightColouredFish => l10n.localPictureTypeBrightColouredFish,
      PictureType.illustration => l10n.localPictureTypeIllustration,
      PictureType.bandArtistLogotype => l10n.localPictureTypebandArtistLogotype,
      PictureType.publisherStudioLogotype =>
        l10n.localPictureTypepublisherStudioLogotype,
    };
  }
}
