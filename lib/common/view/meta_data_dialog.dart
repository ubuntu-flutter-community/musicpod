import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yaru/yaru.dart';

import '../../extensions/build_context_x.dart';
import '../../local_audio/local_audio_manager.dart';
import '../../local_audio/change_local_meta_data_manager.dart';
import '../../radio/view/radio_page_tag_bar.dart';
import '../data/audio.dart';
import 'copy_clipboard_content.dart';
import 'local_metadata_covers.dart';
import 'local_metadata_tile.dart';
import 'modals.dart';
import 'ui_constants.dart';

class MetaDataContent extends StatelessWidget with WatchItMixin {
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

  static const double dimension = 300.0;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    ListenableSubscription? _sub;

    final manager = di<ChangeLocalMetaDataManager>(param1: audio);
    final command = manager.command;

    final wasChanged = watch(manager.draft.select((v) => v != null)).value;

    callOnceAfterThisBuild((context) {
      _sub = command.listen((res, sub) {
        if (res != null) {
          context.toast(const Text('Changed metadata successfully'));
          di<LocalAudioManager>()
              .findAlbumCommand(audio.albumDbId!, force: true)
              .run();
        }
      });
    });

    onDispose(() => _sub?.cancel());

    final body = SizedBox(
      width: MetaDataContent.dimension,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (audio.isLocal &&
              audio.path != null &&
              audio.albumDbId != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kLargestSpace),
              child: SizedBox.square(
                dimension: MetaDataContent.dimension,
                child: LocalMetadataCovers(audio: audio),
              ),
            ),
            LocalMetdadataItems(audio: audio),
          ] else
            ...createRadioItems(audio, context),
        ],
      ),
    );

    return switch (_mode) {
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
        actions: [
          if (audio.isLocal)
            ElevatedButton(
              onPressed: wasChanged
                  ? di<ChangeLocalMetaDataManager>(param1: audio).command.run
                  : null,
              child: Text(context.l10n.save),
            ),
        ],
      ),
      ModalMode.bottomSheet => BottomSheet(
        onClosing: () {},
        builder: (context) => body,
      ),
    };
  }

  List<Widget> createRadioItems(Audio audio, BuildContext context) {
    final l10n = context.l10n;

    return [
      ListTile(title: Text(l10n.stationName), subtitle: Text('${audio.title}')),
      ListTile(
        title: Text(l10n.tags),
        subtitle: Align(
          alignment: Alignment.centerLeft,
          child: RadioPageTagBar(station: audio),
        ),
      ),
      ListTile(
        title: Text(l10n.language),
        subtitle: Text(audio.language ?? ''),
      ),
      ListTile(
        title: Text(l10n.quality),
        subtitle: Text('${audio.codec ?? ''}'),
      ),
      ListTile(title: Text(l10n.clicks), subtitle: Text('${audio.clicks}')),
      ListTile(
        title: Text(l10n.url),
        subtitle: Text(audio.url ?? ''),
        onTap: () => context.toast(
          CopyClipboardContent(
            text: audio.title ?? '',
            onSearch: () => launchUrl(Uri.parse(audio.url!)),
          ),
        ),
      ),
    ];
  }
}

class LocalMetdadataItems extends StatelessWidget with WatchItMixin {
  const LocalMetdadataItems({super.key, required this.audio});

  final Audio audio;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: kLargestSpace),
          title: TextField(
            readOnly: true,
            decoration: InputDecoration(
              labelText: l10n.path,
              suffixIcon: IconButton(
                style: IconButton.styleFrom(
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(kYaruButtonRadius),
                      bottomRight: Radius.circular(kYaruButtonRadius),
                    ),
                  ),
                ),
                icon: const Icon(Icons.copy),
                onPressed: () {
                  if (audio.path != null) {
                    context.toast(CopyClipboardContent(text: audio.path!));
                  }
                },
              ),
            ),
            controller: TextEditingController(text: audio.path),
          ),
        ),
        LocalMetadataTile.title(audio: audio),
        LocalMetadataTile.album(audio: audio),
        LocalMetadataTile.artist(audio: audio),
        LocalMetadataTile.trackNumber(audio: audio),
        LocalMetadataTile.diskNumber(audio: audio),
        LocalMetadataTile.totalDisks(audio: audio),
        LocalMetadataTile.genre(audio: audio),
      ],
    );
  }
}
