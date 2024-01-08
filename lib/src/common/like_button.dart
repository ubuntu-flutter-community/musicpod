import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../common.dart';
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
    final lik = libraryModel.liked(audio);

    final heartButton = InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => lik
          ? libraryModel.removeLikedAudio(audio)
          : libraryModel.addLikedAudio(audio),
      child: Iconz().getAnimatedHeartIcon(
        liked: lik,
      ),
    );

    return YaruPopupMenuButton(
      tooltip: context.l10n.moreOptions,
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          side: BorderSide.none,
          borderRadius: BorderRadius.circular(kYaruButtonRadius),
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
