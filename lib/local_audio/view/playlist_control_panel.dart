import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../common/data/audio.dart';
import '../../common/view/avatar_play_button.dart';
import '../../common/view/confirm.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../settings/manager/settings_manager.dart';
import '../data/local_audio_view.dart';
import '../manager/playlist_manager.dart';
import '../data/playlist_action.dart';
import '../manager/playlist_ids_manager.dart';
import 'edit_playlist_dialog.dart';

class PlaylistControlPanel extends StatelessWidget with WatchItMixin {
  const PlaylistControlPanel({
    super.key,
    required this.pageId,
    required this.audios,
  });

  final String pageId;
  final List<Audio> audios;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: space(
        children: [
          IconButton(
            tooltip: l10n.editPlaylist,
            icon: Icon(Iconz.pen),
            onPressed: () => context.dialog(
              (context) => EditPlaylistDialog(
                audios: audios,
                playlistName: pageId,
                initialValue: pageId,
              ),
            ),
          ),
          IconButton(
            tooltip: l10n.clearPlaylist,
            icon: Icon(Iconz.clearAll),
            onPressed: () => di<PlaylistIDsManager>().command.run(
              PlaylistChange(
                id: pageId,
                audios: [],
                action: PlaylistAction.replaceWith,
              ),
            ),
          ),
          AvatarPlayButton(audios: audios, pageId: pageId),
          IconButton(
            isSelected: watchValue(
              (PlaylistManager m) => m.showPlaylistAddAudios,
              param1: pageId,
            ),
            tooltip: l10n.add,
            icon: Icon(Iconz.plus),
            onPressed: () => di<PlaylistManager>(
              param1: pageId,
            ).toggleShowPlaylistAddAudios(),
          ),
          IconButton(
            icon: Icon(Iconz.remove),
            onPressed: () => ConfirmationDialog.show(
              context: context,
              onConfirm: () {
                if (context.mounted && context.canPop()) {
                  context.pop();
                }

                di<PlaylistIDsManager>().command.run(
                  PlaylistChange(id: pageId, action: PlaylistAction.delete),
                );

                di<SettingsManager>().setLocalAudioindex(
                  LocalAudioView.playlists.index,
                );
                di<RoutingManager>().push(
                  pageId: PageIDs.localAudio,
                  replace: true,
                );
              },
            ),
            tooltip: context.l10n.deletePlaylist,
          ),
        ],
      ),
    );
  }
}
