import 'dart:io';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru/yaru.dart';

import '../../l10n/l10n.dart';
import '../../radio/view/radio_page_tag_bar.dart';
import '../data/audio.dart';
import '../data/audio_type.dart';
import 'copy_clipboard_content.dart';
import 'local_metadata_covers.dart';
import 'local_metadata_tile.dart';
import 'modals.dart';
import 'snackbars.dart';
import 'ui_constants.dart';

class MetaDataContent extends StatefulWidget {
  const MetaDataContent.dialog({
    super.key,
    required this.audio,
    required this.pageId,
  }) : _mode = ModalMode.dialog;

  const MetaDataContent.bottomSheet({
    super.key,
    required this.audio,
    required this.pageId,
  }) : _mode = ModalMode.bottomSheet;

  final Audio audio;
  final ModalMode _mode;
  final String pageId;

  static const double dimension = 350.0;

  @override
  State<MetaDataContent> createState() => _MetaDataContentState();
}

class _MetaDataContentState extends State<MetaDataContent> {
  late Audio audio;

  @override
  void initState() {
    super.initState();
    setAudio();
  }

  void setAudio() {
    if (widget.audio.path != null) {
      audio = widget.audio.isLocal && widget.audio.path != null
          ? Audio.local(File(widget.audio.path!))
          : widget.audio;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    final body = SizedBox(
      width: MetaDataContent.dimension - kMediumSpace,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (audio.isLocal && audio.path != null && audio.albumId != null)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: kLargestSpace,
              ),
              child: SizedBox.square(
                dimension: MetaDataContent.dimension,
                child: LocalMetadataCovers(audio: audio),
              ),
            ),
          ...createItems(audio, context),
        ],
      ),
    );

    return switch (widget._mode) {
      ModalMode.dialog => AlertDialog(
          title: YaruDialogTitleBar(
            title: Text(l10n.metadata),
            border: BorderSide.none,
            backgroundColor: Colors.transparent,
          ),
          titlePadding: EdgeInsets.zero,
          contentPadding: const EdgeInsets.only(bottom: 12),
          scrollable: true,
          content: body,
        ),
      ModalMode.bottomSheet => BottomSheet(
          onClosing: () {},
          builder: (context) => body,
        )
    };
  }

  List<Widget> createItems(Audio audio, BuildContext context) {
    final l10n = context.l10n;

    return switch (audio.audioType) {
      AudioType.radio => <Widget>[
          ListTile(
            title: Text(l10n.stationName),
            subtitle: Text('${audio.title}'),
          ),
          ListTile(
            title: Text(l10n.tags),
            subtitle: Align(
              alignment: Alignment.centerLeft,
              child: RadioPageTagBar(
                station: audio,
                onTap: (_) {
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
            ),
          ),
          ListTile(
            title: Text(l10n.language),
            subtitle: Text(audio.language),
          ),
          ListTile(
            title: Text(l10n.quality),
            subtitle: Text('${audio.albumArtist}'),
          ),
          ListTile(
            title: Text(l10n.clicks),
            subtitle: Text('${audio.clicks}'),
          ),
          ListTile(
            title: Text(l10n.url),
            subtitle: Text(audio.url ?? ''),
            onTap: () => showSnackBar(
              context: context,
              content: CopyClipboardContent(
                text: audio.title ?? '',
                onSearch: () => launchUrl(Uri.parse(audio.url!)),
              ),
            ),
          ),
        ],
      AudioType.local => <Widget>[
          LocalMetadataTile.title(audio: audio),
          LocalMetadataTile.album(audio: audio),
          LocalMetadataTile.artist(audio: audio),
          LocalMetadataTile.trackNumber(audio: audio),
          LocalMetadataTile.diskNumber(audio: audio),
          LocalMetadataTile.totalDisks(audio: audio),
          LocalMetadataTile.genre(audio: audio),
        ],
      _ => [],
    };
  }
}
