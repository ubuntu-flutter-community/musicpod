import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/data/mpv_meta_data.dart';
import '../../common/view/icons.dart';
import '../../common/view/mpv_metadata_dialog.dart';
import '../../common/view/safe_network_image.dart';
import '../../constants.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import '../radio_model.dart';

class IcyImage extends StatelessWidget with WatchItMixin {
  const IcyImage({
    super.key,
    required this.mpvMetaData,
    this.height = kAudioTrackWidth,
    this.width = kAudioTrackWidth,
    this.borderRadius,
    this.fallBackWidget,
    this.fit,
  });

  final MpvMetaData mpvMetaData;

  final double height, width;
  final BorderRadius? borderRadius;
  final Widget? fallBackWidget;
  final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    final bR = borderRadius ?? BorderRadius.circular(4);
    watchPropertyValue(
      (PlayerModel m) => m.remoteImageUrl,
    );

    return Tooltip(
      message: context.l10n.metadata,
      child: ClipRRect(
        borderRadius: bR,
        child: InkWell(
          borderRadius: bR,
          onTap: () => showDialog(
            context: context,
            builder: (context) => MpvMetadataDialog(
              image: di<RadioModel>().getCover(mpvMetaData.icyTitle),
              mpvMetaData: mpvMetaData,
            ),
          ),
          child: SizedBox(
            height: height,
            width: width,
            child: SafeNetworkImage(
              url: di<RadioModel>().getCover(mpvMetaData.icyTitle),
              fallBackIcon: fallBackWidget ?? Icon(Iconz.radio),
              filterQuality: FilterQuality.medium,
              fit: fit ?? BoxFit.fitHeight,
            ),
          ),
        ),
      ),
    );
  }
}
