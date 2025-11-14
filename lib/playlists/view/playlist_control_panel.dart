import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/data/audio.dart';
import '../../common/view/avatar_play_button.dart';
import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../local_audio/local_audio_model.dart';
import 'edit_playlist_dialog.dart';
import 'playlst_add_audios_dialog.dart';

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
    final allowReorder = watchPropertyValue(
      (LocalAudioModel m) => m.allowReorder,
    );
    final libraryModel = di<LibraryModel>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: space(
        children: [
          IconButton(
            tooltip: l10n.editPlaylist,
            icon: Icon(Iconz.pen),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => EditPlaylistDialog(
                audios: audios,
                playlistName: pageId,
                initialValue: pageId,
              ),
            ),
          ),
          IconButton(
            tooltip: l10n.clearPlaylist,
            icon: Icon(Iconz.clearAll),
            onPressed: () => libraryModel.clearPlaylist(pageId),
          ),
          AvatarPlayButton(audios: audios, pageId: pageId),
          IconButton(
            tooltip: l10n.add,
            icon: Icon(Iconz.plus),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => PlaylistAddAudiosDialog(playlistId: pageId),
            ),
          ),
          IconButton(
            tooltip: l10n.move,
            isSelected: allowReorder,
            onPressed: () =>
                di<LocalAudioModel>().setAllowReorder(!allowReorder),
            icon: Icon(Iconz.move),
          ),
        ],
      ),
    );
  }
}
