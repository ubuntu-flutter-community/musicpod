import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
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
import 'audio_tile_option_button.dart';
import 'like_icon.dart';
import 'tapable_text.dart';

class AudioTile extends StatefulWidget with WatchItStatefulWidgetMixin {
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
    required this.showLeading,
    this.selectedColor,
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
  final bool showLeading;
  final Color? selectedColor;

  @override
  State<AudioTile> createState() => _AudioTileState();
}

class _AudioTileState extends State<AudioTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final liked = watchPropertyValue((LibraryModel m) => m.liked(widget.audio));
    final selectedColor = widget.selectedColor ?? theme.contrastyPrimary;
    final subTitle = switch (widget.audioPageType) {
      AudioPageType.artist => widget.audio.album ?? context.l10n.unknown,
      _ => widget.audio.artist ?? context.l10n.unknown,
    };

    var leading = !widget.showLeading
        ? null
        : switch (widget.audioPageType) {
            AudioPageType.album =>
              AlbumTileLead(trackNumber: widget.audio.trackNumber),
            _ => AudioTileImage(
                size: kAudioTrackWidth,
                audio: widget.audio,
              ),
          };

    return MouseRegion(
      key: ValueKey(widget.audio.audioType?.index),
      onEnter: (e) => setState(() => _hovered = true),
      onExit: (e) => setState(() => _hovered = false),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minLeadingWidth: kAudioTrackWidth,
        leading: leading,
        selected: widget.selected,
        selectedColor: widget.isPlayerPlaying
            ? selectedColor
            : theme.colorScheme.onSurface,
        selectedTileColor: theme.colorScheme.onSurface.withOpacity(0.05),
        contentPadding: kModernAudioTilePadding,
        onTap: () {
          if (widget.selected) {
            if (widget.isPlayerPlaying) {
              widget.pause();
            } else {
              widget.resume();
            }
          } else {
            widget.startPlaylist?.call();
          }
        },
        title: Padding(
          padding: const EdgeInsets.only(right: kYaruPagePadding),
          child: Text(
            widget.audio.title ?? context.l10n.unknown,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        subtitle: TapAbleText(
          text: subTitle,
          onTap: widget.onSubTitleTap == null
              ? null
              : () => widget.onSubTitleTap?.call(subTitle),
        ),
        trailing: _AudioTileTrail(
          hovered: _hovered,
          liked: liked,
          audio: widget.audio,
          selected: widget.selected,
          isPlayerPlaying: widget.isPlayerPlaying,
          libraryModel: widget.libraryModel,
          pageId: widget.pageId,
          audioPageType: widget.audioPageType,
          insertIntoQueue: widget.insertIntoQueue,
          selectedColor: selectedColor,
        ),
      ),
    );
  }
}

class _AudioTileTrail extends StatelessWidget with WatchItMixin {
  const _AudioTileTrail({
    required this.audio,
    required this.selected,
    required this.isPlayerPlaying,
    required this.libraryModel,
    required this.pageId,
    required this.audioPageType,
    required this.insertIntoQueue,
    required this.hovered,
    required this.liked,
    required this.selectedColor,
  });

  final Audio audio;
  final bool selected;
  final bool isPlayerPlaying;
  final LibraryModel libraryModel;
  final String pageId;
  final AudioPageType audioPageType;
  final void Function(Audio audio) insertIntoQueue;
  final bool hovered;
  final bool liked;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: hovered || selected ? 1 : 0,
          child: AudioTileOptionButton(
            selected: selected && isPlayerPlaying,
            libraryModel: libraryModel,
            playlistId: pageId,
            audio: audio,
            allowRemove: audioPageType == AudioPageType.playlist,
            insertIntoQueue: () => insertIntoQueue(audio),
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        Opacity(
          opacity: hovered || selected || liked ? 1 : 0,
          child: switch (audio.audioType) {
            AudioType.radio => RadioLikeIcon(
                audio: audio,
                color: selected && isPlayerPlaying ? selectedColor : null,
              ),
            AudioType.local => LikeIcon(
                audio: audio,
                color: selected && isPlayerPlaying ? selectedColor : null,
              ),
            _ => SizedBox.square(
                dimension: context.t.buttonTheme.height,
              ),
          },
        ),
        const SizedBox(
          width: 5,
        ),
        if (audio.audioType != AudioType.radio && audio.durationMs != null)
          SizedBox(
            width: 60,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                Duration(milliseconds: audio.durationMs!.toInt()).formattedTime,
                style: context.t.textTheme.labelMedium?.copyWith(
                  color: selected && isPlayerPlaying ? selectedColor : null,
                ),
              ),
            ),
          ),
      ],
    );
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
          style: context.t.textTheme.labelMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
