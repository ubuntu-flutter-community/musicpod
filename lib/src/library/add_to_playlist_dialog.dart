import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../common.dart';
import '../../data.dart';
import '../../globals.dart';
import '../../l10n.dart';
import '../../library.dart';
import '../../theme.dart';
import '../common/side_bar_fall_back_image.dart';

class AddToPlaylistDialog extends StatelessWidget {
  const AddToPlaylistDialog({
    super.key,
    required this.audio,
    required this.playlistIds,
    required this.addAudioToPlaylist,
    required this.getPlaylistById,
    required this.removePlaylist,
    this.onTextTap,
  });

  final Audio audio;
  final List<String> playlistIds;
  final void Function(String, Audio) addAudioToPlaylist;
  final Set<Audio>? Function(String id) getPlaylistById;
  final void Function(String) removePlaylist;
  final void Function({required AudioType audioType, required String text})?
      onTextTap;

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: yaruStyled
          ? YaruDialogTitleBar(
              title: Text(context.l10n.addToPlaylist),
            )
          : Text(context.l10n.addToPlaylist),
      titlePadding: yaruStyled
          ? EdgeInsets.zero
          : const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0.0),
      children: playlistIds
          .map(
            (e) => ListTile(
              onTap: () {
                addAudioToPlaylist(e, audio);
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: _AddToPlaylistSnackBar(
                      id: e,
                      getPlaylistById: getPlaylistById,
                      unPinPlaylist: removePlaylist,
                      onTextTap: onTextTap,
                    ),
                  ),
                );
              },
              leading: SideBarFallBackImage(
                color: getAlphabetColor(e),
                child: Icon(Iconz().starFilled),
              ),
              title: Text(e),
            ),
          )
          .toList(),
    );
  }
}

class _AddToPlaylistSnackBar extends StatelessWidget {
  const _AddToPlaylistSnackBar({
    required this.getPlaylistById,
    required this.unPinPlaylist,
    required this.id,
    this.onTextTap,
  });

  final Set<Audio>? Function(String id) getPlaylistById;
  final void Function(String p1) unPinPlaylist;
  final String id;
  final void Function({required AudioType audioType, required String text})?
      onTextTap;

  @override
  Widget build(BuildContext context) {
    final playlist = getPlaylistById(id);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${context.l10n.addedTo} $id',
        ),
        if (playlist != null)
          ImportantButton(
            onPressed: () {
              ScaffoldMessenger.of(context).clearSnackBars();
              navigatorKey.currentState?.push(
                MaterialPageRoute(
                  builder: (context) {
                    return PlaylistPage(
                      playlist: MapEntry(id, playlist),
                      unPinPlaylist: unPinPlaylist,
                      onTextTap: onTextTap,
                    );
                  },
                ),
              );
            },
            child: Text(context.l10n.open),
          ),
      ],
    );
  }
}
