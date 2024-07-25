import 'package:flutter/material.dart';
import 'package:yaru/constants.dart';

import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/duration_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../data/audio.dart';
import 'audio_page_type.dart';
import 'audio_tile_image.dart';
import 'like_button.dart';
import 'tapable_text.dart';

class AudioTile extends StatelessWidget {
  const AudioTile({
    super.key,
    required this.pageId,
    required this.libraryModel,
    required this.insertIntoQueue,
    required this.selected,
    required this.audio,
    required this.isPlayerPlaying,
    required this.pause,
    required this.resume,
    this.onSubTitleTap,
    this.startPlaylist,
    required this.audioPageType,
  });

  final String pageId;
  final Audio audio;
  final AudioPageType audioPageType;
  final bool selected;

  final bool isPlayerPlaying;
  final Future<void> Function() resume;
  final void Function()? startPlaylist;
  final void Function() pause;
  final void Function(String text)? onSubTitleTap;
  final LibraryModel libraryModel;
  final void Function(Audio audio) insertIntoQueue;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final subTitle = switch (audioPageType) {
      AudioPageType.artist => audio.album ?? context.l10n.unknown,
      _ => audio.artist ?? context.l10n.unknown,
    };

    final leading = switch (audioPageType) {
      AudioPageType.album => AlbumTileLead(trackNumber: audio.trackNumber),
      _ => AudioTileImage(
          size: kAudioTrackWidth,
          audio: audio,
        ),
    };

    final listTile = ListTile(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      minLeadingWidth: kAudioTrackWidth,
      leading: leading,
      selected: selected,
      selectedColor: isPlayerPlaying
          ? theme.contrastyPrimary
          : theme.colorScheme.onSurface,
      selectedTileColor: theme.colorScheme.onSurface.withOpacity(0.05),
      contentPadding: kModernAudioTilePadding,
      onTap: () {
        if (selected) {
          if (isPlayerPlaying) {
            pause();
          } else {
            resume();
          }
        } else {
          startPlaylist?.call();
        }
      },
      title: Padding(
        padding: const EdgeInsets.only(right: kYaruPagePadding),
        child: Text(
          audio.title ?? context.l10n.unknown,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
      subtitle: TapAbleText(
        text: subTitle,
        onTap:
            onSubTitleTap == null ? null : () => onSubTitleTap?.call(subTitle),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (audio.audioType != AudioType.radio && audio.durationMs != null)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Text(
                Duration(milliseconds: audio.durationMs!.toInt()).formattedTime,
              ),
            ),
          LikeButton(
            selected: selected && isPlayerPlaying,
            libraryModel: libraryModel,
            playlistId: pageId,
            audio: audio,
            allowRemove: audioPageType == AudioPageType.playlist,
            insertIntoQueue: () => insertIntoQueue(audio),
          ),
        ],
      ),
    );

    return listTile;
  }
}

class AlbumTileLead extends StatelessWidget {
  const AlbumTileLead({
    super.key,
    required this.trackNumber,
  });

  final int? trackNumber;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: kAudioTrackWidth,
      child: Center(
        widthFactor: 1,
        child: Text(
          trackNumber?.toString() ?? '0',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
