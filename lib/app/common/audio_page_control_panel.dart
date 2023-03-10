import 'package:flutter/material.dart';
import 'package:musicpod/app/player_model.dart';
import 'package:musicpod/app/playlists/playlist_dialog.dart';
import 'package:musicpod/app/playlists/playlist_model.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:musicpod/utils.dart';
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
    // final playlistModel = context.read<PlaylistModel>();
    final theme = Theme.of(context);
    final isPlaying = context.select((PlayerModel m) => m.isPlaying);
    final startPlaylist = context.read<PlayerModel>().startPlaylist;
    final resume = context.read<PlayerModel>().resume;
    final pause = context.read<PlayerModel>().pause;
    final queue = context.select((PlayerModel m) => m.queue);
    final playlistModel = context.read<PlaylistModel>();
    final addLikedAudios = context.read<PlaylistModel>().addLikedAudios;
    final removeLikedAudios = context.read<PlaylistModel>().removeLikedAudios;
    final liked = context.read<PlaylistModel>().liked;

    final listIsQueue = listsAreEqual(queue, audios.toList());
    final allLiked =
        audios.where((a) => liked(a)).toList().length == audios.length;

    return Row(
      children: [
        CircleAvatar(
          backgroundColor: theme.colorScheme.inverseSurface,
          child: IconButton(
            onPressed: () {
              if (isPlaying) {
                if (listIsQueue) {
                  pause();
                } else {
                  WidgetsBinding.instance
                      .addPostFrameCallback((timeStamp) async {
                    if (context.mounted) {
                      await startPlaylist(audios);
                    }
                  });
                }
              } else {
                if (listIsQueue) {
                  resume();
                } else {
                  WidgetsBinding.instance
                      .addPostFrameCallback((timeStamp) async {
                    if (context.mounted) {
                      await startPlaylist(audios);
                    }
                  });
                }
              }
            },
            icon: Icon(
              isPlaying && listIsQueue
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
            onPressed: () =>
                allLiked ? removeLikedAudios(audios) : addLikedAudios(audios),
            icon: Icon(
              allLiked ? YaruIcons.heart_filled : YaruIcons.heart,
            ),
          ),
        const SizedBox(
          width: 10,
        ),
        if (editableName)
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
