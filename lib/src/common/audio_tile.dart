import 'package:flutter/material.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../l10n.dart';
import '../../library.dart';

class AudioTile extends StatelessWidget {
  const AudioTile({
    super.key,
    required this.audioPageType,
    required this.pageId,
    required this.libraryModel,
    required this.insertIntoQueue,
    required this.selected,
    required this.audio,
    this.onLike,
    this.likeIcon,
    required this.isPlayerPlaying,
    required this.pause,
    required this.resume,
    this.onAlbumTap,
    this.onArtistTap,
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
  final bool isPlayerPlaying;
  final Future<void> Function() resume;
  final void Function()? startPlaylist;
  final void Function() pause;
  final bool showTrack;
  final bool showArtist;
  final bool showAlbum;
  final void Function(String text)? onAlbumTap;
  final void Function(String text)? onArtistTap;

  final int titleFlex, artistFlex, albumFlex;

  final AudioPageType audioPageType;
  final String pageId;
  final LibraryModel libraryModel;
  final void Function(Audio audio) insertIntoQueue;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final listTile = ListTile(
      selected: selected,
      selectedColor: isPlayerPlaying
          ? theme.colorScheme.primary
          : theme.colorScheme.onSurface,
      selectedTileColor: theme.colorScheme.onSurface.withOpacity(0.05),
      contentPadding: kAudioTilePadding,
      onTap: () {
        if (selected) {
          if (isPlayerPlaying) {
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
            Padding(
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
                  onTap: onArtistTap == null ||
                          audio.audioType == null ||
                          audio.artist == null
                      ? null
                      : () => onArtistTap!(audio.artist!),
                  text: audio.artist?.isNotEmpty == false
                      ? context.l10n.unknown
                      : audio.artist ?? context.l10n.unknown,
                ),
              ),
            ),
          if (showAlbum)
            Expanded(
              flex: albumFlex,
              child: TapAbleText(
                onTap: onAlbumTap == null ||
                        audio.audioType == null ||
                        audio.audioType == AudioType.radio ||
                        audio.album == null
                    ? null
                    : () => onAlbumTap!(audio.album!),
                text: audio.album?.isNotEmpty == false
                    ? context.l10n.unknown
                    : audio.album ?? context.l10n.unknown,
              ),
            ),
        ],
      ),
      trailing: LikeButton(
        selected: selected && isPlayerPlaying,
        libraryModel: libraryModel,
        playlistId: pageId,
        audio: audio,
        allowRemove: audioPageType == AudioPageType.playlist,
        insertIntoQueue: () => insertIntoQueue(audio),
      ),
    );

    return listTile;
  }
}
