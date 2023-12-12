import 'package:flutter/material.dart';

import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../l10n.dart';

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
    this.onTextTap,
    this.showTrack = true,
    this.showAlbum = true,
    this.showArtist = true,
    this.titleFlex = 1,
    this.artistFlex = 1,
    this.albumFlex = 1,
    this.startPlaylist,
  });

  final Audio audio;
  final bool selected;
  final void Function()? onLike;
  final Widget? likeIcon;
  final bool isPlayerPlaying;
  final Future<void> Function({Duration? newPosition, Audio? newAudio}) play;
  final Future<void> Function() resume;
  final void Function()? startPlaylist;
  final void Function() pause;
  final bool showTrack;
  final bool showArtist;
  final bool showAlbum;
  final void Function({
    required String text,
    required AudioType audioType,
  })? onTextTap;

  final int titleFlex, artistFlex, albumFlex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = TextStyle(
      color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
    );

    final listTile = ListTile(
      contentPadding: kAudioTilePadding,
      onTap: () {
        if (selected) {
          if (isPlayerPlaying) {
            pause();
          } else {
            resume();
          }
        } else {
          if (startPlaylist != null) {
            startPlaylist!();
          } else {
            play(newAudio: audio);
          }
        }
      },
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showTrack)
            Padding(
              padding: kAudioTileTrackPadding,
              child: Text(
                audio.trackNumber != null
                    ? audio.trackNumber!.toString().padLeft(2, '0')
                    : '00',
                style: textStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          Expanded(
            flex: titleFlex,
            child: Padding(
              padding: kAudioTileSpacing,
              child: Text(
                audio.title ?? context.l10n.unknown,
                style: textStyle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (showArtist)
            Expanded(
              flex: artistFlex,
              child: Padding(
                padding: kAudioTileSpacing,
                child: TapAbleText(
                  onTap: onTextTap == null || audio.audioType == null
                      ? null
                      : () => onTextTap!(
                            text: audio.artist!,
                            audioType: audio.audioType!,
                          ),
                  text: audio.artist?.isNotEmpty == false
                      ? context.l10n.unknown
                      : audio.artist!,
                  selected: selected,
                ),
              ),
            ),
          if (showAlbum)
            Expanded(
              flex: albumFlex,
              child: TapAbleText(
                onTap: onTextTap == null ||
                        audio.audioType == null ||
                        audio.audioType == AudioType.radio
                    ? null
                    : () => onTextTap!(
                          text: audio.album!,
                          audioType: audio.audioType!,
                        ),
                text: audio.album?.isNotEmpty == false
                    ? context.l10n.unknown
                    : audio.album!,
                selected: selected,
              ),
            ),
        ],
      ),
      trailing: likeIcon,
    );

    return listTile;
  }
}
