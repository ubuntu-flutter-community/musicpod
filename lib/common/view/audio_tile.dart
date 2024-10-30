import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/duration_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import '../data/audio.dart';
import 'audio_page_type.dart';
import 'audio_tile_image.dart';
import 'audio_tile_option_button.dart';
import 'like_icon.dart';
import 'tapable_text.dart';
import 'theme.dart';

class AudioTile extends StatefulWidget with WatchItStatefulWidgetMixin {
  const AudioTile({
    super.key,
    required this.pageId,
    this.insertIntoQueue,
    required this.selected,
    required this.audio,
    required this.isPlayerPlaying,
    this.onSubTitleTap,
    this.onTap,
    required this.audioPageType,
    required this.showLeading,
    this.selectedColor,
    this.onTitleTap,
  });

  final String pageId;
  final Audio audio;
  final AudioPageType audioPageType;
  final bool selected;

  final bool isPlayerPlaying;
  final void Function()? onTap;
  final void Function()? onTitleTap;
  final void Function(String text)? onSubTitleTap;
  final void Function(Audio audio)? insertIntoQueue;
  final bool showLeading;
  final Color? selectedColor;

  @override
  State<AudioTile> createState() => _AudioTileState();
}

class _AudioTileState extends State<AudioTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final l10n = context.l10n;
    final playerModel = di<PlayerModel>();
    final liked = watchPropertyValue((LibraryModel m) => m.liked(widget.audio));
    final starred = watchPropertyValue(
      (LibraryModel m) => m.isStarredStation(widget.audio.uuid),
    );
    final selectedColor = widget.selectedColor ?? theme.contrastyPrimary;
    final subTitle = switch (widget.audioPageType) {
      AudioPageType.artist => widget.audio.album ?? l10n.unknown,
      AudioPageType.radioSearch => _buildRadioSubTitle(widget.audio, l10n),
      _ => widget.audio.artist ?? l10n.unknown,
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

    const titleOverflow = TextOverflow.ellipsis;
    const titleMaxLines = 1;

    return MouseRegion(
      key: ObjectKey(widget.audio),
      onEnter: (e) {
        if (isMobile) return;
        setState(() => _hovered = true);
      },
      onExit: (e) {
        if (isMobile) return;
        setState(() => _hovered = false);
      },
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minLeadingWidth: kAudioTrackWidth,
        leading: leading,
        selected: widget.selected,
        selectedColor: widget.isPlayerPlaying
            ? selectedColor
            : theme.colorScheme.onSurface,
        selectedTileColor: theme.colorScheme.onSurface.withOpacity(0.05),
        contentPadding: audioTilePadding,
        onTap: () {
          if (widget.selected) {
            if (widget.isPlayerPlaying) {
              playerModel.pause();
            } else {
              playerModel.resume();
            }
          } else {
            widget.onTap?.call();
          }
        },
        title: Padding(
          padding: const EdgeInsets.only(right: kYaruPagePadding),
          child: widget.onTitleTap == null
              ? Text(
                  widget.audio.title ?? l10n.unknown,
                  overflow: titleOverflow,
                  maxLines: titleMaxLines,
                )
              : TapAbleText(
                  onTap: widget.onTitleTap,
                  text: widget.audio.title ?? l10n.unknown,
                  overflow: titleOverflow,
                  maxLines: titleMaxLines,
                ),
        ),
        subtitle: TapAbleText(
          text: subTitle,
          onTap: widget.onSubTitleTap == null
              ? null
              : () => widget.onSubTitleTap?.call(subTitle),
        ),
        trailing: _AudioTileTrail(
          hovered: isMobile ? true : _hovered,
          liked: liked || starred,
          audio: widget.audio,
          selected: widget.selected,
          isPlayerPlaying: widget.isPlayerPlaying,
          pageId: widget.pageId,
          audioPageType: widget.audioPageType,
          insertIntoQueue: widget.insertIntoQueue,
          selectedColor: selectedColor,
        ),
      ),
    );
  }

  String _buildRadioSubTitle(
    Audio audio,
    AppLocalizations l10n,
  ) =>
      '${audio.albumArtist?.isNotEmpty == true ? '${audio.albumArtist}' : ''}${audio.bitRate > 0 ? ' • ${audio.fileSize} kbps' : ''}${audio.clicks > 0 ? ' • ${audio.clicks} ${l10n.clicks}' : ''}${audio.language.trim().isNotEmpty ? ' • ${audio.language}' : ''}';
}

class _AudioTileTrail extends StatelessWidget with WatchItMixin {
  const _AudioTileTrail({
    required this.audio,
    required this.selected,
    required this.isPlayerPlaying,
    required this.pageId,
    required this.audioPageType,
    this.insertIntoQueue,
    required this.hovered,
    required this.liked,
    required this.selectedColor,
  });

  final Audio audio;
  final bool selected;
  final bool isPlayerPlaying;
  final String pageId;
  final AudioPageType audioPageType;
  final void Function(Audio audio)? insertIntoQueue;
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
            playlistId: pageId,
            audio: audio,
            allowRemove: audioPageType == AudioPageType.playlist,
            insertIntoQueue:
                insertIntoQueue != null ? () => insertIntoQueue!(audio) : null,
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
                dimension: context.theme.buttonTheme.height,
              ),
          },
        ),
        if (!isMobile &&
            audio.audioType != AudioType.radio &&
            audio.durationMs != null)
          Padding(
            padding: const EdgeInsets.only(left: 5),
            child: SizedBox(
              width: 60,
              child: Align(
                alignment: Alignment.centerRight,
                child: Text(
                  Duration(milliseconds: audio.durationMs!.toInt())
                      .formattedTime,
                  style: context.theme.textTheme.labelMedium?.copyWith(
                    color: selected && isPlayerPlaying ? selectedColor : null,
                  ),
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
          style: context.theme.textTheme.labelMedium,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
