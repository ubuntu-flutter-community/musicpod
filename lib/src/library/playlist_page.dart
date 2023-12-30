import 'package:flutter/material.dart';

import '../../common.dart';
import '../../data.dart';
import '../../library.dart';
import '../common/fall_back_header_image.dart';
import '../l10n/l10n.dart';
import '../theme.dart';

class PlaylistPage extends StatelessWidget {
  const PlaylistPage({
    super.key,
    required this.playlist,
    this.onTextTap,
    required this.libraryModel,
  });

  final MapEntry<String, Set<Audio>> playlist;
  final LibraryModel libraryModel;
  final void Function({
    required String text,
    required AudioType audioType,
  })? onTextTap;

  @override
  Widget build(BuildContext context) {
    return AudioPage(
      showAudioTileHeader:
          playlist.value.any((e) => e.audioType != AudioType.podcast),
      onTextTap: onTextTap,
      audioPageType: AudioPageType.playlist,
      image: FallBackHeaderImage(
        color: getAlphabetColor(playlist.key),
        child: Icon(
          Iconz().playlist,
          size: 65,
        ),
      ),
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
            allowDelete: true,
            allowRename: true,
            libraryModel: libraryModel,
          ),
        ),
      ),
    );
  }
}
