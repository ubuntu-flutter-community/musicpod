import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import '../../playlists/view/add_to_playlist_dialog.dart';
import '../data/audio.dart';
import 'audio_tile_bottom_sheet.dart';
import 'icons.dart';
import 'meta_data_dialog.dart';
import 'modals.dart';
import 'snackbars.dart';
import 'stream_provider_share_button.dart';

class AudioTileOptionButton extends StatelessWidget {
  const AudioTileOptionButton({
    super.key,
    required this.audio,
    required this.playlistId,
    required this.allowRemove,
    required this.selected,
  });

  final String playlistId;
  final Audio audio;

  final bool allowRemove;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = context.l10n;
    final libraryModel = di<LibraryModel>();

    if (isMobile) {
      return AudioTileBottomSheetButton(
        audio: audio,
        allowRemove: allowRemove,
        playlistId: playlistId,
      );
    }

    return PopupMenuButton(
      tooltip: l10n.moreOptions,
      padding: EdgeInsets.zero,
      itemBuilder: (context) {
        return [
          if (audio.audioType != AudioType.radio)
            PopupMenuItem(
              onTap: () {
                di<PlayerModel>().insertIntoQueue(audio);
                showSnackBar(
                  context: context,
                  content: Text(
                    '${l10n.addedTo} ${l10n.queue}: ${audio.artist} - ${audio.title}',
                  ),
                );
              },
              child: YaruTile(
                leading: Icon(Iconz.insertIntoQueue),
                title: Text(l10n.playNext),
              ),
            ),
          if (allowRemove)
            PopupMenuItem(
              onTap: () => playlistId == kLikedAudiosPageId
                  ? libraryModel.removeLikedAudio(audio)
                  : libraryModel.removeAudioFromPlaylist(playlistId, audio),
              child: YaruTile(
                leading: Icon(Iconz.remove),
                title: Text(
                  '${l10n.removeFrom} ${playlistId == kLikedAudiosPageId ? l10n.likedSongs : playlistId}',
                ),
              ),
            ),
          if (audio.audioType != AudioType.radio)
            PopupMenuItem(
              onTap: () => showDialog(
                context: context,
                builder: (context) => AddToPlaylistDialog(audio: audio),
              ),
              child: YaruTile(
                leading: Icon(Iconz.plus),
                title: Text(
                  '${l10n.addToPlaylist} ...',
                ),
              ),
            ),
          PopupMenuItem(
            onTap: () => showDialog(
              context: context,
              builder: (context) {
                return MetaDataDialog(audio: audio);
              },
            ),
            child: YaruTile(
              leading: Icon(Iconz.info),
              title: Text(
                '${l10n.showMetaData} ...',
              ),
            ),
          ),
          if (audio.audioType != AudioType.radio)
            PopupMenuItem(
              enabled: false,
              padding: EdgeInsets.zero,
              child: Theme(
                data:
                    theme.copyWith(disabledColor: theme.colorScheme.onSurface),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  child: StreamProviderRow(
                    iconColor: theme.colorScheme.onSurface,
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    text: '${audio.artist ?? ''} - ${audio.title ?? ''}',
                  ),
                ),
              ),
            ),
        ];
      },
      icon: Icon(Iconz.viewMore),
    );
  }
}

class AudioTileBottomSheetButton extends StatelessWidget {
  const AudioTileBottomSheetButton({
    super.key,
    required this.audio,
    required this.allowRemove,
    required this.playlistId,
  });

  final Audio audio;
  final bool allowRemove;
  final String playlistId;

  @override
  Widget build(BuildContext context) => IconButton(
        tooltip: context.l10n.moreOptions,
        onPressed: () => showModal(
          context: context,
          content: AudioTileBottomSheet(
            audio: audio,
            allowRemove: allowRemove,
            playlistId: playlistId,
          ),
        ),
        icon: Icon(Iconz.viewMore),
      );
}
