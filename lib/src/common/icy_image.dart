import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru/yaru.dart';

import '../../common.dart';
import '../../constants.dart';
import '../../l10n.dart';
import '../../online_album_art_utils.dart';
import '../../url_store.dart';
import '../data/mpv_meta_data.dart';

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
    this.onGenreTap,
    this.fallBackImageUrl,
  });

  final MpvMetaData mpvMetaData;

  final double height, width;
  final BorderRadius? borderRadius;
  final Widget? fallBackWidget;
  final Widget? errorWidget;
  final BoxFit? fit;
  final Function(String tag)? onGenreTap;
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
              return SimpleDialog(
                titlePadding: EdgeInsets.zero,
                contentPadding: const EdgeInsets.only(bottom: 10),
                children: [
                  if (image != null)
                    ClipRRect(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(kYaruContainerRadius),
                        topRight: Radius.circular(kYaruContainerRadius),
                      ),
                      child: SizedBox(
                        width: 250,
                        child: SafeNetworkImage(
                          errorIcon:
                              widget.errorWidget ?? Icon(Iconz().imageMissing),
                          fit: widget.fit ?? BoxFit.fitHeight,
                          url: image,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                    child: StreamProviderRow(
                      text: widget.mpvMetaData.icyTitle,
                    ),
                  ),
                  ...widget.mpvMetaData
                      .toMap()
                      .entries
                      .map(
                        (e) => ListTile(
                          onTap: switch (e.key) {
                            'icy-url' => () => launchUrl(Uri.parse(e.value)),
                            'icy-genre' => () {
                                widget.onGenreTap?.call(e.value);
                                Navigator.of(context).maybePop();
                              },
                            _ => null,
                          },
                          dense: true,
                          title: Text(e.key),
                          subtitle: Text(e.value),
                        ),
                      )
                      .toList()
                      .reversed,
                ],
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
        fallBackIcon: widget.fallBackWidget ?? Icon(Iconz().info),
        filterQuality: FilterQuality.medium,
        fit: widget.fit ?? BoxFit.fitHeight,
      );
}
