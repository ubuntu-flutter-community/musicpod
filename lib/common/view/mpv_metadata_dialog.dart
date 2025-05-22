import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru/yaru.dart';

import 'ui_constants.dart';
import '../data/mpv_meta_data.dart';
import 'icons.dart';
import 'modals.dart';
import 'safe_network_image.dart';
import 'stream_provider_share_button.dart';

class MpvMetadataDialog extends StatelessWidget {
  const MpvMetadataDialog({
    super.key,
    this.image,
    required this.mpvMetaData,
    required ModalMode mode,
  }) : _mode = mode;

  const MpvMetadataDialog.dialog({
    super.key,
    this.image,
    required this.mpvMetaData,
  }) : _mode = ModalMode.dialog;

  const MpvMetadataDialog.bottomSheet({
    super.key,
    this.image,
    required this.mpvMetaData,
  }) : _mode = ModalMode.bottomSheet;

  final String? image;
  final MpvMetaData mpvMetaData;
  final ModalMode _mode;

  @override
  Widget build(BuildContext context) {
    final children = [
      if (image != null)
        if (_mode == ModalMode.dialog)
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
          )
        else
          ListTile(
            title: Text(mpvMetaData.icyTitle),
            subtitle: Text(mpvMetaData.icyName),
            leading: ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(kAudioTrackWidth / 10),
                topRight: Radius.circular(kAudioTrackWidth / 10),
              ),
              child: SafeNetworkImage(
                url: image,
                height: kAudioTrackWidth,
                fit: BoxFit.cover,
                fallBackIcon: Icon(Iconz.radio),
                errorIcon: Icon(Iconz.radio),
              ),
            ),
          ),
      Padding(
        padding: EdgeInsets.only(
          left: 8,
          right: 8,
          top: _mode == ModalMode.dialog ? 8 : 4,
        ),
        child: StreamProviderRow(text: mpvMetaData.icyTitle),
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
    ];

    return switch (_mode) {
      ModalMode.dialog => SimpleDialog(
        titlePadding: EdgeInsets.zero,
        contentPadding: const EdgeInsets.only(bottom: 10),
        children: children,
      ),
      ModalMode.bottomSheet => BottomSheet(
        enableDrag: false,
        onClosing: () {},
        builder: (context) =>
            SizedBox(height: 800, child: Column(children: children)),
      ),
    };
  }
}
