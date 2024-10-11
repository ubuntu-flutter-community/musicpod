import '../data/mpv_meta_data.dart';
import 'icons.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru/yaru.dart';
import 'safe_network_image.dart';
import 'stream_provider_share_button.dart';

class MpvMetadataDialog extends StatelessWidget {
  const MpvMetadataDialog({
    super.key,
    this.image,
    required this.mpvMetaData,
  });

  final String? image;
  final MpvMetaData mpvMetaData;

  @override
  Widget build(BuildContext context) {
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
                errorIcon: Icon(Iconz.imageMissing),
                fit: BoxFit.fitHeight,
                url: image,
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
          child: StreamProviderRow(
            text: mpvMetaData.icyTitle,
          ),
        ),
        ...mpvMetaData
            .toMap()
            .entries
            .map(
              (e) => ListTile(
                onTap: switch (e.key) {
                  'icy-url' => () => launchUrl(Uri.parse(e.value)),
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
  }
}
