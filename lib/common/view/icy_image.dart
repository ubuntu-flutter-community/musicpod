import 'package:flutter/material.dart';

import '../../common/view/icons.dart';
import '../../constants.dart';
import '../../l10n/l10n.dart';
import '../../online_album_art_utils.dart';
import '../data/mpv_meta_data.dart';
import 'mpv_metadata_dialog.dart';
import 'safe_network_image.dart';

class IcyImage extends StatefulWidget {
  const IcyImage({
    super.key,
    required this.mpvMetaData,
    this.height = kAudioTrackWidth,
    this.width = kAudioTrackWidth,
    this.borderRadius,
    this.fallBackWidget,
    this.fit,
    this.errorWidget,
    this.fallBackImageUrl,
  });

  final MpvMetaData mpvMetaData;

  final double height, width;
  final BorderRadius? borderRadius;
  final Widget? fallBackWidget;
  final Widget? errorWidget;
  final BoxFit? fit;
  final String? fallBackImageUrl;

  @override
  State<IcyImage> createState() => _IcyImageState();
}

class _IcyImageState extends State<IcyImage> {
  late Future<String?> _imageUrl;

  @override
  void initState() {
    super.initState();
    _imageUrl = fetchAlbumArt(widget.mpvMetaData.icyTitle);
  }

  @override
  Widget build(BuildContext context) {
    final bR = widget.borderRadius ?? BorderRadius.circular(4);
    final storedUrl = UrlStore().get(widget.mpvMetaData.icyTitle);

    return Tooltip(
      message: context.l10n.metadata,
      child: ClipRRect(
        borderRadius: bR,
        child: InkWell(
          borderRadius: bR,
          onTap: () => showDialog(
            context: context,
            builder: (context) {
              final image = UrlStore().get(widget.mpvMetaData.icyTitle);
              return MpvMetadataDialog(
                image: image,
                mpvMetaData: widget.mpvMetaData,
              );
            },
          ),
          child: SizedBox(
            height: widget.height,
            width: widget.width,
            child: storedUrl != null
                ? _buildImage(storedUrl)
                : FutureBuilder(
                    future: _imageUrl,
                    builder: (context, snapshot) {
                      return _buildImage(
                        UrlStore().put(
                          key: widget.mpvMetaData.icyTitle,
                          url: snapshot.data,
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildImage(String? url) => SafeNetworkImage(
        errorIcon: widget.errorWidget ?? Icon(Iconz().imageMissing),
        url: url,
        fallBackIcon: widget.fallBackWidget ?? Icon(Iconz().radio),
        filterQuality: FilterQuality.medium,
        fit: widget.fit ?? BoxFit.fitHeight,
      );
}
