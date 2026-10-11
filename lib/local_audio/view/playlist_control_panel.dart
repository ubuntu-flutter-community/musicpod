import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../common/data/audio.dart';
import '../../common/view/audio_page_type.dart';
import '../../common/view/avatar_play_button.dart';
import '../../common/view/confirm.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../settings/manager/settings_manager.dart';
import '../data/local_audio_view.dart';
import '../manager/show_playlist_add_audios_manager.dart';
import '../data/playlist_action.dart';
import '../manager/playlist_ids_manager.dart';
import 'edit_playlist_dialog.dart';

class PlaylistControlPanel extends ConsumerWidget {
  const PlaylistControlPanel({
    super.key,
    required this.pageId,
    required this.audios,
  });

  final String pageId;
  final List<Audio> audios;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            onPressed: () => ref
                .read(playlistIDsManagerProvider.notifier)
                .createOrChangePlaylist(
                  PlaylistChange(
                    id: pageId,
                    audios: [],
                    action: PlaylistAction.replaceWith,
                  ),
                ),
          ),
          AvatarPlayButton(
            pageId: pageId,
            audioPageType: AudioPageType.playlist,
          ),
          IconButton(
            isSelected: ref.watch(showPlaylistAddAudiosManagerProvider(pageId)),
            tooltip: l10n.add,
            icon: Icon(Iconz.plus),
            onPressed: () => ref
                .read(showPlaylistAddAudiosManagerProvider(pageId).notifier)
                .toggle(),
          ),
          IconButton(
            icon: Icon(Iconz.remove),
            onPressed: () => ConfirmationDialog.show(
              title: Text(l10n.deletePlaylist),
              modalLevel: ModalLevel.error,
              headerIconData: Iconz.remove,
              context: context,
              onConfirm: () {
                if (context.mounted && context.canPop()) {
                  context.pop();
                }

                ref.read(playlistIDsManagerProvider.notifier).createOrChangePlaylist(
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
