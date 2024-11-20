import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/icons.dart';
import '../../common/view/modals.dart';
import '../../common/view/mpv_metadata_dialog.dart';
import '../../common/view/safe_network_image.dart';
import '../../constants.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import '../online_art_model.dart';

class RadioHistoryTileImage extends StatelessWidget with WatchItMixin {
  const RadioHistoryTileImage({
    super.key,
    required this.icyTitle,
    this.height = kAudioTrackWidth,
    this.width = kAudioTrackWidth,
    this.fit,
  });

  final String? icyTitle;

  final double height, width;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    final bR = BorderRadius.circular(4);
    final imageUrl = watchPropertyValue(
      (OnlineArtModel m) => m.getCover(icyTitle!),
    );

    return Tooltip(
      message: context.l10n.metadata,
      child: ClipRRect(
        borderRadius: bR,
        child: InkWell(
          borderRadius: bR,
          onTap: () {
            final metadata = di<PlayerModel>().getMetadata(icyTitle);
            if (metadata == null) return;
            showModal(
              context: context,
              content: isMobile
                  ? MpvMetadataDialog.bottomSheet(
                      image: imageUrl,
                      mpvMetaData: metadata,
                    )
                  : MpvMetadataDialog.dialog(
                      image: imageUrl,
                      mpvMetaData: metadata,
                    ),
            );
          },
          child: SizedBox(
            height: height,
            width: width,
            child: SafeNetworkImage(
              url: imageUrl,
              fallBackIcon: Icon(Iconz.radio),
              filterQuality: FilterQuality.medium,
              fit: fit ?? BoxFit.fitHeight,
            ),
          ),
        ),
      ),
    );
  }
}
