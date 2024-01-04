import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../l10n.dart';
import '../../player.dart';

class AudioTile extends StatelessWidget {
  const AudioTile({
    super.key,
    required this.selected,
    required this.audio,
    this.onLike,
    this.likeIcon,
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
    this.trackLabel,
  });

  final String? trackLabel;
  final Audio audio;
  final bool selected;
  final void Function()? onLike;
  final Widget? likeIcon;
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
    bool? playing;
    if (selected && showTrack) {
      playing = context.select((PlayerModel m) => m.isPlaying);
    }

    final listTile = ListTile(
      selected: selected,
      contentPadding: kAudioTilePadding,
      onTap: () {
        if (selected) {
          if (playing == true) {
            pause();
          } else {
            resume();
          }
        } else {
          startPlaylist!();
        }
      },
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showTrack)
            playing == true
                ? const Padding(
                    padding: EdgeInsets.only(right: 15, left: 0),
                    child: SizedBox(
                      height: 26,
                      width: 26,
                      child: MusicIndicator(
                        thickness: 2,
                      ),
                    ),
                  )
                : Padding(
                    padding: kAudioTileTrackPadding,
                    child: Text(
                      trackLabel ??
                          (audio.trackNumber != null
                              ? audio.trackNumber!.toString().padLeft(2, '0')
                              : '00'),
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
