import 'package:flutter/material.dart';
import 'package:music/app/player_model.dart';
import 'package:music/app/playlists/playlist_dialog.dart';
import 'package:music/app/playlists/playlist_model.dart';
import 'package:music/data/audio.dart';
import 'package:music/l10n/l10n.dart';
import 'package:music/utils.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AudioPageControlPanel extends StatelessWidget {
  const AudioPageControlPanel({
    super.key,
    required this.audios,
    required this.listName,
    this.editableName = true,
    required this.deletable,
    this.likeButton,
  });

  final Set<Audio> audios;
  final String listName;
  final bool editableName;
  final bool deletable;
  final Widget? likeButton;

  @override
  Widget build(BuildContext context) {
    final playlistModel = context.watch<PlaylistModel>();
    final playerModel = context.watch<PlayerModel>();
    final theme = Theme.of(context);
    final listIsQueue = listsAreEqual(playerModel.queue, audios.toList());
    final allLiked =
        audios.where((a) => playlistModel.liked(a)).toList().length ==
            audios.length;
    return Row(
      children: [
        CircleAvatar(
          backgroundColor: theme.colorScheme.inverseSurface,
          child: IconButton(
            onPressed: () {
              if (playerModel.isPlaying) {
                if (listIsQueue) {
                  playerModel.pause();
                } else {
                  playerModel.startPlaylist(audios);
                }
              } else {
                if (listIsQueue) {
                  playerModel.resume();
                } else {
                  playerModel.startPlaylist(audios);
                }
              }
            },
            icon: Icon(
              playerModel.isPlaying && listIsQueue
                  ? YaruIcons.media_pause
                  : YaruIcons.media_play,
              color: theme.colorScheme.onInverseSurface,
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        if (likeButton != null)
          likeButton!
        else
          IconButton(
            onPressed: () => allLiked
                ? playlistModel.removeLikedAudios(audios)
                : playlistModel.addLikedAudios(audios),
            icon: Icon(
              allLiked ? YaruIcons.heart_filled : YaruIcons.heart,
            ),
          ),
        const SizedBox(
          width: 10,
        ),
        if (editableName || deletable)
          YaruIconButton(
            icon: const Icon(YaruIcons.pen),
            onPressed: () => showDialog(
              context: context,
              builder: (context) => ChangeNotifierProvider<PlaylistModel>.value(
                value: playlistModel,
                child: PlaylistDialog(
                  editableName: editableName,
                  deletable: deletable,
                  name: listName,
                  audios: audios,
                ),
              ),
            ),
          ),
        Expanded(
          child: Text(
            '${listName == 'likedAudio' ? context.l10n.likedSongs : listName}  •  ${audios.length} ${context.l10n.titles}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.headlineSmall
                ?.copyWith(fontWeight: FontWeight.w100),
          ),
        ),
      ],
    );
  }
}
