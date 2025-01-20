import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru/yaru.dart';

import '../../app_config.dart';
import '../../l10n/l10n.dart';
import '../data/audio.dart';
import '../data/audio_type.dart';
import 'copy_clipboard_content.dart';
import 'modals.dart';
import 'snackbars.dart';

class MetaDataContent extends StatelessWidget {
  const MetaDataContent.dialog({
    super.key,
    required this.audio,
  }) : _mode = ModalMode.dialog;

  const MetaDataContent.bottomSheet({
    super.key,
    required this.audio,
  }) : _mode = ModalMode.bottomSheet;

  final Audio audio;
  final ModalMode _mode;

  @override
  Widget build(BuildContext context) {
    final radio = audio.audioType == AudioType.radio;
    final l10n = context.l10n;
    final items = <(String, String)>{
      (
        radio ? l10n.stationName : l10n.title,
        '${audio.title}',
      ),
      (
        radio ? l10n.tags : l10n.album,
        '${radio ? audio.album?.replaceAll(',', ', ') : audio.album}',
      ),
      (
        radio ? l10n.language : l10n.artist,
        '${radio ? audio.language : audio.artist}',
      ),
      (
        radio ? l10n.quality : l10n.albumArtists,
        '${audio.albumArtist}',
      ),
      if (!radio)
        (
          l10n.trackNumber,
          '${audio.trackNumber}',
        ),
      if (!radio)
        (
          l10n.diskNumber,
          '${audio.discNumber}',
        ),
      (
        radio ? l10n.clicks : l10n.totalDisks,
        '${radio ? audio.clicks : audio.discTotal}',
      ),
      if (!radio)
        (
          l10n.genre,
          '${audio.genre}',
        ),
      (
        l10n.url,
        (audio.url ?? ''),
      ),
    };

    final title = yaruStyled
        ? YaruDialogTitleBar(
            title: Text(l10n.metadata),
          )
        : Center(child: Text(l10n.metadata));

    final titlePadding =
        yaruStyled ? EdgeInsets.zero : const EdgeInsets.only(top: 10);

    const edgeInsets = EdgeInsets.only(bottom: 12);

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (e) => ListTile(
              dense: true,
              title: Text(e.$1),
              subtitle: Text(e.$2),
              onTap: e.$1 == l10n.url
                  ? () {
                      final maybeUri = Uri.tryParse(e.$2);
                      if (maybeUri != null) {
                        showSnackBar(
                          context: context,
                          content: CopyClipboardContent(
                            text: maybeUri.toString(),
                            onSearch: () => launchUrl(maybeUri),
                          ),
                        );
                        Navigator.of(context).pop();
                      }
                    }
                  : null,
            ),
          )
          .toList(),
    );

    return switch (_mode) {
      ModalMode.dialog => AlertDialog(
          title: title,
          titlePadding: titlePadding,
          contentPadding: edgeInsets,
          scrollable: true,
          content: body,
        ),
      ModalMode.bottomSheet => BottomSheet(
          onClosing: () {},
          builder: (context) => body,
        )
    };
  }
}
