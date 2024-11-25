import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import 'ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../extensions/duration_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import '../data/audio.dart';
import '../data/audio_type.dart';
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

    final selectedColor = widget.selectedColor ?? theme.contrastyPrimary;
    final color =
        widget.selected && widget.isPlayerPlaying ? selectedColor : null;

    final subTitle = switch (widget.audioPageType) {
      AudioPageType.artist => widget.audio.album ?? l10n.unknown,
      AudioPageType.radioSearch => _buildRadioSubTitle(widget.audio, l10n),
      _ => widget.audio.artist ?? l10n.unknown,
    };

    final leading = !widget.showLeading
        ? null
        : switch (widget.audioPageType) {
            AudioPageType.album => _AlbumTileLead(
                trackNumber: widget.audio.trackNumber,
                color: color,
              ),
            _ => AudioTileImage(
                size: kAudioTrackWidth,
                audio: widget.audio,
              ),
          };

    const titleOverflow = TextOverflow.ellipsis;
    const titleMaxLines = 1;

    final listTile = ListTile(
      key: ObjectKey(widget.audio),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      minLeadingWidth: kAudioTrackWidth,
      leading: leading,
      selected: widget.selected,
      selectedColor:
          widget.isPlayerPlaying ? selectedColor : theme.colorScheme.onSurface,
      selectedTileColor: theme.colorScheme.onSurface.withOpacity(0.05),
      contentPadding: audioTilePadding.copyWith(
        left: widget.audioPageType == AudioPageType.album ? 10 : null,
      ),
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
        padding: const EdgeInsets.only(right: kLargestSpace),
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
      subtitle: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: TapAbleText(
              wrapInFlexible: false,
              text: subTitle,
              onTap: widget.onSubTitleTap == null
                  ? null
                  : () => widget.onSubTitleTap?.call(subTitle),
            ),
          ),
          Flexible(
            child: _AudioTileDuration(
              audio: widget.audio,
            ),
          ),
        ],
      ),
      trailing: _AudioTileTrail(
        hovered: _hovered,
        audio: widget.audio,
        selected: widget.selected,
        isPlayerPlaying: widget.isPlayerPlaying,
        pageId: widget.pageId,
        audioPageType: widget.audioPageType,
        selectedColor: selectedColor,
        showDuration: !isMobile,
        showLikeIcon: !isMobile,
        alwaysShowOptionButton: isMobile,
      ),
    );

    if (isMobile) return listTile;

    return MouseRegion(
      key: ObjectKey(widget.audio),
      onEnter: (e) => setState(() => _hovered = true),
      onExit: (e) => setState(() => _hovered = false),
      child: listTile,
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
    required this.hovered,
    required this.selectedColor,
    required this.showLikeIcon,
    required this.showDuration,
    required this.alwaysShowOptionButton,
  });

  final Audio audio;
  final bool selected;
  final bool isPlayerPlaying;
  final String pageId;
  final AudioPageType audioPageType;
  final bool hovered;
  final Color selectedColor;
  final bool showLikeIcon, showDuration;
  final bool alwaysShowOptionButton;

  @override
  Widget build(BuildContext context) {
    final liked = watchPropertyValue((LibraryModel m) => m.liked(audio));
    final starred = watchPropertyValue(
      (LibraryModel m) => m.isStarredStation(audio.uuid),
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: alwaysShowOptionButton || hovered || selected ? 1 : 0,
          child: AudioTileOptionButton(
            title: Text(audio.title ?? ''),
            subTitle: Text(audio.artist ?? ''),
            selected: selected && isPlayerPlaying,
            playlistId: pageId,
            audios: [audio],
            searchTerm: '${audio.artist ?? ''} - ${audio.title ?? ''}',
            allowRemove: (audioPageType == AudioPageType.playlist ||
                    audioPageType == AudioPageType.likedAudio) &&
                audio.audioType != AudioType.radio,
          ),
        ),
        const SizedBox(
          width: 5,
        ),
        if (showLikeIcon)
          Opacity(
            opacity: hovered || selected || liked || starred ? 1 : 0,
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
      ],
    );
  }
}

class _AudioTileDuration extends StatelessWidget {
  const _AudioTileDuration({
    required this.audio,
  });

  final Audio audio;

  @override
  Widget build(BuildContext context) {
    return Text(
      audio.audioType != AudioType.radio && audio.durationMs != null
          ? ' · ${Duration(milliseconds: audio.durationMs!.toInt()).formattedTime}'
          : '',
    );
  }
}

class _AlbumTileLead extends StatelessWidget {
  const _AlbumTileLead({required this.trackNumber, this.color});

  final int? trackNumber;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: kAudioTrackWidth,
      child: Center(
        widthFactor: 1,
        child: Text(
          trackNumber?.toString() ?? '0',
          style: context.theme.textTheme.labelLarge?.copyWith(color: color),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
