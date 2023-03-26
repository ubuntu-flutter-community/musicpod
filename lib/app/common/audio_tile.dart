import 'package:flutter/material.dart';
import 'package:musicpod/data/audio.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AudioTile extends StatelessWidget {
  const AudioTile({
    super.key,
    required this.selected,
    required this.audio,
    this.onLike,
    this.likeIcon,
    required this.isPlayerPlaying,
    required this.play,
    required this.pause,
    required this.resume,
    this.onArtistTap,
    this.onAlbumTap,
    this.showTrack = true,
  });

  final Audio audio;
  final bool selected;
  final void Function()? onLike;
  final Widget? likeIcon;
  final bool isPlayerPlaying;
  final Future<void> Function() play;
  final Future<void> Function() resume;
  final void Function() pause;
  final bool showTrack;
  final void Function(String artist)? onArtistTap;
  final void Function(String artist)? onAlbumTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = TextStyle(
      color: selected ? theme.colorScheme.onSurface : theme.hintColor,
      fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
    );

    return ListTile(
      contentPadding: const EdgeInsets.only(left: 8, right: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kYaruButtonRadius),
      ),
      onTap: () {
        if (isPlayerPlaying && selected) {
          pause();
        } else {
          if (selected) {
            resume();
          } else {
            play();
          }
        }
      },
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (audio.trackNumber != null && showTrack)
            Expanded(
              flex: 1,
              child: Text(
                audio.trackNumber != null ? '${audio.trackNumber}' : ' ',
                style: textStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Expanded(
            flex: 5,
            child: Text(
              audio.title ?? 'unknown',
              style: textStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (audio.artist != null)
            Expanded(
              flex: 4,
              child: _TapAbleText(
                onTap: onArtistTap == null
                    ? null
                    : () => onArtistTap!(audio.artist!),
                text: audio.artist!,
                selected: selected,
              ),
            ),
          if (audio.album != null)
            Expanded(
              flex: 4,
              child: _TapAbleText(
                onTap:
                    onAlbumTap == null ? null : () => onAlbumTap!(audio.album!),
                text: audio.album!,
                selected: selected,
              ),
            ),
        ],
      ),
      trailing: likeIcon,
    );
  }
}

class _TapAbleText extends StatelessWidget {
  const _TapAbleText({
    this.onTap,
    required this.text,
    required this.selected,
  });

  final void Function()? onTap;
  final String text;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = TextStyle(
      color: selected ? theme.colorScheme.onSurface : theme.hintColor,
      fontWeight: selected ? FontWeight.w500 : FontWeight.normal,
    );
    return Row(
      children: [
        Flexible(
          fit: FlexFit.loose,
          child: InkWell(
            hoverColor: theme.primaryColor.withOpacity(0.3),
            borderRadius: BorderRadius.circular(4),
            onTap: onTap == null ? null : () => onTap!(),
            child: Text(
              text,
              style: textStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}
