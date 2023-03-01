import 'package:flutter/material.dart';
import 'package:music/app/player_model.dart';
import 'package:music/data/audio.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AudioTile extends StatelessWidget {
  const AudioTile({
    super.key,
    required this.selected,
    required this.audio,
    this.onLike,
    this.likeIcon,
  });

  final Audio audio;
  final bool selected;
  final void Function()? onLike;
  final Widget? likeIcon;

  @override
  Widget build(BuildContext context) {
    final playerModel = context.watch<PlayerModel>();
    final theme = Theme.of(context);
    final textStyle = TextStyle(
      color: selected ? theme.colorScheme.onSurface : theme.hintColor,
    );

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 8, right: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kYaruButtonRadius),
      ),
      onTap: () async {
        if (playerModel.isPlaying && selected) {
          playerModel.pause();
        } else {
          WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
            playerModel.audio = audio;
            playerModel.stop().then((_) => playerModel.play());
          });
        }
      },
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              audio.metadata?.title ?? audio.name ?? '',
              style: textStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (audio.metadata?.artist != null)
            Expanded(
              child: Text(
                audio.metadata!.artist!,
                style: textStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          if (audio.metadata?.album != null)
            Expanded(
              child: Text(
                audio.metadata!.album!,
                style: textStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
      trailing: likeIcon,
    );
  }
}
