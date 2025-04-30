import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app_config.dart';
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
import 'like_icon_button.dart';
import 'stared_station_icon_button.dart';
import 'tapable_text.dart';
import 'theme.dart';
import 'ui_constants.dart';

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
    required this.allowLeadingImage,
    this.selectedColor,
    this.onTitleTap,
    this.showDuration = true,
    this.alwaysShowOptionButton = true,
    this.neverShowLikeIcon = false,
  });

  final String pageId;
  final Audio audio;
  final AudioPageType audioPageType;
  final bool selected;

  final bool isPlayerPlaying;
  final void Function()? onTap;
  final void Function()? onTitleTap;
  final void Function(String text)? onSubTitleTap;
  final bool allowLeadingImage,
      showDuration,
      alwaysShowOptionButton,
      neverShowLikeIcon;
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
    final slimTile = widget.audioPageType == AudioPageType.allTitlesView ||
        widget.audioPageType == AudioPageType.album;

    final selectedColor = widget.selectedColor ?? theme.contrastyPrimary;
    final color =
        widget.selected && widget.isPlayerPlaying ? selectedColor : null;

    final subTitle = switch (widget.audioPageType) {
      AudioPageType.artist => widget.audio.album ?? l10n.unknown,
      AudioPageType.radioSearch => _buildRadioSubTitle(widget.audio, l10n),
      _ => widget.audio.artist ?? l10n.unknown,
    };

    const dimension = kAudioTrackWidth;

    final leading = switch (widget.audioPageType) {
      AudioPageType.album => _AlbumTileLead(
          trackNumber: widget.audio.trackNumber,
          color: color,
          dimension: dimension / 2,
        ),
      _ => widget.allowLeadingImage
          ? AudioTileImage(
              size: dimension,
              audio: widget.audio,
            )
          : null,
    };

    const titleOverflow = TextOverflow.ellipsis;
    const titleMaxLines = 1;

    final title = Padding(
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
    );

    final subtitle = widget.audioPageType == AudioPageType.album &&
            widget.audio.discNumber != null &&
            widget.audio.discTotal != null &&
            widget.audio.discTotal! > 1
        ? Text('${l10n.disc} ${widget.audio.discNumber}')
        : TapAbleText(
            wrapInFlexible: slimTile,
            text: subTitle,
            onTap: widget.onSubTitleTap == null
                ? null
                : () => widget.onSubTitleTap?.call(subTitle),
          );

    final listTile = ListTile(
      key: ObjectKey(widget.audio),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      minLeadingWidth: dimension,
      leading: leading,
      selected: widget.selected,
      selectedColor:
          widget.isPlayerPlaying ? selectedColor : theme.colorScheme.onSurface,
      selectedTileColor: theme.colorScheme.onSurface.withValues(alpha: 0.05),
      contentPadding: audioTilePadding.copyWith(
        left: widget.audioPageType == AudioPageType.album ? 10 : null,
        right: slimTile ? 0 : null,
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
      title: !slimTile
          ? title
          : Row(
              spacing: kMediumSpace,
              children: [
                Expanded(
                  flex: 4,
                  child: title,
                ),
                Expanded(
                  flex: 3,
                  child: subtitle,
                ),
                if (widget.showDuration)
                  Expanded(
                    child: _AudioTileDuration(
                      splitter: '',
                      audio: widget.audio,
                    ),
                  ),
              ],
            ),
      subtitle: slimTile
          ? null
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: subtitle,
                ),
                if (widget.showDuration)
                  Flexible(
                    child: _AudioTileDuration(
                      audio: widget.audio,
                    ),
                  ),
              ],
            ),
      trailing: AudioTileTrail(
        hovered: _hovered,
        audio: widget.audio,
        selected: widget.selected,
        isPlayerPlaying: widget.isPlayerPlaying,
        pageId: widget.pageId,
        audioPageType: widget.audioPageType,
        selectedColor: selectedColor,
        showLikeIcon: !widget.neverShowLikeIcon,
        alwaysShowOptionButton: widget.alwaysShowOptionButton,
      ),
    );

    if (AppConfig.isMobilePlatform) return listTile;

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

class AudioTileTrail extends StatelessWidget with WatchItMixin {
  const AudioTileTrail({
    super.key,
    required this.audio,
    required this.selected,
    required this.isPlayerPlaying,
    required this.pageId,
    required this.audioPageType,
    required this.hovered,
    required this.selectedColor,
    required this.showLikeIcon,
    required this.alwaysShowOptionButton,
  });

  final Audio audio;
  final bool selected;
  final bool isPlayerPlaying;
  final String pageId;
  final AudioPageType audioPageType;
  final bool hovered;
  final Color selectedColor;
  final bool showLikeIcon;
  final bool alwaysShowOptionButton;

  @override
  Widget build(BuildContext context) {
    final liked = watchPropertyValue((LibraryModel m) => m.isLikedAudio(audio));
    final starred = watchPropertyValue(
      (LibraryModel m) => m.isStarredStation(audio.uuid),
    );
    return Row(
      spacing: kSmallestSpace,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLikeIcon)
          Opacity(
            opacity: hovered || selected || liked || starred ? 1 : 0,
            child: switch (audio.audioType) {
              AudioType.radio => StaredStationIconButton(
                  audio: audio,
                  color: selected && isPlayerPlaying ? selectedColor : null,
                ),
              AudioType.local => LikeIconButton(
                  audio: audio,
                  color: selected && isPlayerPlaying ? selectedColor : null,
                ),
              _ => SizedBox.square(
                  dimension: context.theme.buttonTheme.height,
                ),
            },
          ),
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
      ],
    );
  }
}

class _AudioTileDuration extends StatelessWidget {
  const _AudioTileDuration({
    required this.audio,
    this.splitter = ' · ',
  });

  final Audio audio;
  final String splitter;

  @override
  Widget build(BuildContext context) {
    return Text(
      audio.audioType != AudioType.radio && audio.durationMs != null
          ? '$splitter${Duration(milliseconds: audio.durationMs!.toInt()).formattedTime}'
          : '',
      overflow: TextOverflow.ellipsis,
    );
  }
}

class _AlbumTileLead extends StatelessWidget {
  const _AlbumTileLead({
    required this.trackNumber,
    this.color,
    this.dimension = kAudioTrackWidth,
  });

  final int? trackNumber;
  final Color? color;
  final double? dimension;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: dimension,
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
