import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../dependencies.dart';

import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../common/data/audio.dart';
import '../../common/view/confirm.dart';
import '../../common/view/icons.dart';
import '../../common/view/ui_constants.dart';
import '../../custom_content/service/custom_content_service.dart';
import '../../extensions/build_context_x.dart';
import '../../settings/data/shared_preferences_keys.dart';
import '../../settings/manager/settings_manager.dart';
import '../data/local_audio_view.dart';
import '../data/playlist_action.dart';
import '../manager/playlist_ids_manager.dart';

class EditPlaylistDialog extends ConsumerStatefulWidget {
  const EditPlaylistDialog({
    super.key,
    this.playlistName,
    this.initialValue,
    this.audios,
  });

  final List<Audio>? audios;
  final String? playlistName, initialValue;

  @override
  ConsumerState<EditPlaylistDialog> createState() => _EditPlaylistDialogState();
}

class _EditPlaylistDialogState extends ConsumerState<EditPlaylistDialog> {
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
    final routingManager = ref.read(routingManagerProvider.notifier);
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
                      : () => di<CustomContentService>().exportPlaylistToM3u(
                          id: widget.playlistName!,
                          audios: widget.audios!,
                        ),
                  label: Text(l10n.exportPlaylistToM3UFile),
                ),
              ],
            ),
          ),
        ],
      ),
      confirmLabel: context.l10n.save,
      onConfirm: () async {
        unawaited(
          routingManager.push(pageId: PageIDs.localAudio, replace: true),
        );
        await ref
            .read(settingsIntManagerProvider(SPKeys.localAudioIndex).notifier)
            .set(LocalAudioView.playlists.index);
        await ref
            .read(playlistIDsManagerProvider.notifier)
            .createOrChangePlaylist(
              PlaylistChange(
                id: widget.playlistName!,
                action: PlaylistAction.updateName,
                newName: _controller.text,
              ),
            );
      },
    );
  }
}
