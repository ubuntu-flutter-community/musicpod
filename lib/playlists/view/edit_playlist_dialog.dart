import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/view/routing_manager.dart';
import '../../common/data/audio.dart';
import '../../common/page_ids.dart';
import '../../common/view/confirm.dart';
import '../../common/view/icons.dart';
import '../../common/view/ui_constants.dart';
import '../../custom_content/custom_content_model.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../local_audio/local_audio_model.dart';
import '../../local_audio/local_audio_view.dart';

class EditPlaylistDialog extends StatefulWidget
    with WatchItStatefulWidgetMixin {
  const EditPlaylistDialog({
    super.key,
    this.playlistName,
    this.initialValue,
    this.audios,
  });

  final List<Audio>? audios;
  final String? playlistName, initialValue;

  @override
  State<EditPlaylistDialog> createState() => _EditPlaylistDialogState();
}

class _EditPlaylistDialogState extends State<EditPlaylistDialog> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final libraryModel = di<LibraryModel>();
    final routingManager = di<RoutingManager>();
    final l10n = context.l10n;
    return ConfirmationDialog(
      scrollable: true,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: kMediumSpace),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                label: Text(context.l10n.setPlaylistNameAndAddMoreLater),
              ),
              controller: _controller,
            ),
          ),
          const SizedBox(height: kLargestSpace),
          Align(
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                TextButton.icon(
                  icon: Icon(Iconz.export),
                  onPressed:
                      widget.playlistName == null || widget.audios == null
                      ? null
                      : () => di<CustomContentModel>().exportPlaylistToM3u(
                          id: widget.playlistName!,
                          audios: widget.audios!,
                        ),
                  label: Text(l10n.exportPlaylistToM3UFile),
                ),
                if (widget.playlistName != null)
                  TextButton.icon(
                    icon: Icon(Iconz.remove),
                    onPressed: () {
                      if (context.mounted && Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                      di<LocalAudioModel>().setLocalAudioindex(
                        LocalAudioView.playlists.index,
                      );
                      routingManager.push(
                        pageId: PageIDs.localAudio,
                        replace: true,
                      );
                      libraryModel.removePlaylist(widget.playlistName!);
                    },
                    label: Text(context.l10n.deletePlaylist),
                  ),
              ],
            ),
          ),
        ],
      ),
      confirmLabel: context.l10n.save,
      confirmEnabled: watchPropertyValue(
        (CustomContentModel m) => !m.processing,
      ),
      onConfirm: () {
        di<LocalAudioModel>().setLocalAudioindex(
          LocalAudioView.playlists.index,
        );
        routingManager.push(pageId: PageIDs.localAudio);
        libraryModel.updatePlaylistName(widget.playlistName!, _controller.text);
        Navigator.of(context).maybePop();
      },
    );
  }
}
