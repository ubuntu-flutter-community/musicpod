import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../library.dart';
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
  });

  final String playlistId;
  final Audio audio;
  final void Function()? insertIntoQueue;

  final LibraryModel libraryModel;
  final bool allowRemove;

  @override
  Widget build(BuildContext context) {
    final liked = libraryModel.liked(audio);

    final heartButton = InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        if (liked) {
          libraryModel.removeLikedAudio(audio);
        } else {
          libraryModel.addLikedAudio(audio);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: AddToPlaylistSnackBar(
                id: kLikedAudiosPageId,
                libraryModel: libraryModel,
              ),
            ),
          );
        }
      },
      child: Iconz().getAnimatedHeartIcon(
        liked: liked,
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
            child: Text(context.l10n.insertIntoQueue),
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
