import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../library.dart';
import '../../theme.dart';
import '../l10n/l10n.dart';
import '../library/add_to_playlist_dialog.dart';

class LikeButton extends StatelessWidget {
  const LikeButton({
    super.key,
    required this.audio,
    required this.playlistId,
    required this.insertIntoQueue,
    required this.libraryModel,
    required this.allowRemove,
    required this.selected,
  });

  final String playlistId;
  final Audio audio;
  final void Function()? insertIntoQueue;

  final LibraryModel libraryModel;
  final bool allowRemove;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final liked = libraryModel.liked(audio);

    final heartButton = InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        if (liked) {
          libraryModel.removeLikedAudio(audio);
        } else {
          libraryModel.addLikedAudio(audio);
          showAddedToPlaylistSnackBar(
            context: context,
            libraryModel: libraryModel,
            id: kLikedAudiosPageId,
          );
        }
      },
      child: Iconz().getAnimatedHeartIcon(
        liked: liked,
        color: selected ? theme.colorScheme.primary : null,
      ),
    );

    return YaruPopupMenuButton(
      tooltip: context.l10n.moreOptions,
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(100),
        ),
      ),
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            onTap: insertIntoQueue,
            child: Text(context.l10n.playNext),
          ),
          if (allowRemove)
            PopupMenuItem(
              onTap: () =>
                  libraryModel.removeAudioFromPlaylist(playlistId, audio),
              child: Text('${context.l10n.removeFrom} $playlistId'),
            ),
          PopupMenuItem(
            onTap: () => showDialog(
              context: context,
              builder: (context) {
                return AddToPlaylistDialog(
                  audio: audio,
                  libraryModel: libraryModel,
                );
              },
            ),
            child: Text(
              '${context.l10n.addToPlaylist} ...',
            ),
          ),
          PopupMenuItem(
            onTap: () => showDialog(
              context: context,
              builder: (context) {
                return MetaDataDialog(audio: audio);
              },
            ),
            // TODO: localize
            child: const Text(
              'Show metadata ...',
            ),
          ),
          PopupMenuItem(
            padding: EdgeInsets.zero,
            child: StreamProviderRow(
              text: '${audio.artist ?? ''} - ${audio.title ?? ''}',
            ),
          ),
        ];
      },
      child: heartButton,
    );
  }
}

class MetaDataDialog extends StatelessWidget {
  const MetaDataDialog({super.key, required this.audio});

  final Audio audio;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: yaruStyled
          ? YaruDialogTitleBar(
              title: Text(audio.title ?? ''),
            )
          : null,
      titlePadding: yaruStyled ? EdgeInsets.zero : null,
      scrollable: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            dense: true,
            title: Text(context.l10n.title),
            trailing: Text('${audio.title}'),
          ),
          ListTile(
            dense: true,
            trailing: Text('${audio.album}'),
            title: Text(context.l10n.album),
          ),
          ListTile(
            dense: true,
            trailing: Text(' ${audio.artist}'),
            title: Text(context.l10n.artist),
          ),
          // TODO: localize
          ListTile(
            dense: true,
            trailing: Text('${audio.trackNumber}'),
            title: const Text('track number'),
          ),
          ListTile(
            dense: true,
            title: const Text('discNumber'),
            trailing: Text('${audio.discNumber}'),
          ),
          ListTile(
            dense: true,
            title: const Text('totalDisc'),
            trailing: Text('${audio.discTotal}'),
          ),
          ListTile(
            dense: true,
            title: const Text('albumArtist'),
            trailing: Text('${audio.albumArtist}'),
          ),
        ],
      ),
    );
  }
}
