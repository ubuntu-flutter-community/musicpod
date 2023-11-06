import 'package:flutter/material.dart';

import '../../common.dart';
import '../../data.dart';
import '../common/icons.dart';
import '../l10n/l10n.dart';
import 'playlist_dialog.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({
    super.key,
    required this.playlist,
    required this.unPinPlaylist,
    this.onTextTap,
    this.updatePlaylistName,
  });

  final MapEntry<String, Set<Audio>> playlist;
  final void Function(String playlist) unPinPlaylist;
  final void Function(String oldName, String newName)? updatePlaylistName;
  final void Function({
    required String text,
    required AudioType audioType,
  })? onTextTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final noPicture = playlist.value.firstOrNull == null ||
        playlist.value.firstOrNull!.pictureData == null;

    final noImage = playlist.value.firstOrNull == null ||
        playlist.value.firstOrNull!.imageUrl == null;

    final image = !noPicture
        ? Image.memory(
            playlist.value.firstOrNull!.pictureData!,
            width: 200.0,
            fit: BoxFit.fitWidth,
            filterQuality: FilterQuality.medium,
          )
        : !noImage
            ? SafeNetworkImage(
                fallBackIcon: SizedBox(
                  width: 200,
                  child: Center(
                    child: Icon(
                      Iconz().musicNote,
                      size: 80,
                      color: theme.hintColor,
                    ),
                  ),
                ),
                url: playlist.value.firstOrNull!.imageUrl,
                fit: BoxFit.fitWidth,
                filterQuality: FilterQuality.medium,
              )
            : null;

    return AudioPage(
      onTextTap: onTextTap,
      audioPageType: AudioPageType.playlist,
      image: image,
      headerLabel: context.l10n.playlist,
      headerTitle: playlist.key,
      audios: playlist.value,
      pageId: playlist.key,
      noResultMessage: Text(context.l10n.emptyPlaylist),
      controlPanelButton: IconButton(
        icon: Icon(Iconz().pen),
        onPressed: () => showDialog(
          context: context,
          builder: (context) => PlaylistDialog(
            playlistName: playlist.key,
            initialValue: playlist.key,
            onDeletePlaylist: () => unPinPlaylist(playlist.key),
            onUpdatePlaylistName: (name) =>
                updatePlaylistName!(playlist.key, name),
          ),
        ),
      ),
    );
  }
}
