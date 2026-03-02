import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../extensions/build_context_x.dart';
import '../../extensions/duration_x.dart';
import '../../extensions/taget_platform_x.dart';
import '../../extensions/theme_data_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../data/audio.dart';
import '../data/audio_type.dart';
import 'audio_page_type.dart';
import 'audio_tile_image.dart';
import 'audio_tile_option_button.dart';
import 'like_icon_button.dart';
import 'tapable_text.dart';
import 'theme.dart';
import 'ui_constants.dart';

class AudioTile extends StatefulWidget {
  const AudioTile({
    super.key,
    required this.pageId,
    required this.selected,
    required this.audio,
    required this.isPlayerPlaying,
    this.onSubTitleTap,
    this.onSubSubTitleTap,
    required this.onTap,
    required this.audioPageType,
    required this.allowLeadingImage,
    this.selectedColor,
    this.onTitleTap,
    this.showDuration = true,
    this.showSubTitle = true,
    this.showSubSubTitle = false,
  });

  final String pageId;
  final Audio audio;
  final AudioPageType audioPageType;
  final bool selected;

  final bool isPlayerPlaying;
  final void Function() onTap;
  final void Function()? onTitleTap;
  final void Function(String text)? onSubTitleTap;
  final void Function(Audio audio)? onSubSubTitleTap;
  final bool allowLeadingImage, showDuration, showSubTitle, showSubSubTitle;
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

    final selectedColor = widget.selectedColor ?? theme.contrastyPrimary;
    final color = widget.selected && widget.isPlayerPlaying
        ? selectedColor
        : null;

    const titleOverflow = TextOverflow.ellipsis;
    const titleMaxLines = 1;

    final title = Padding(
      padding: const EdgeInsets.only(right: kLargestSpace),
      child: widget.onTitleTap == null
          ? TapAbleText(
              onTap: isMobile ? null : widget.onTap,
              text: widget.audio.title ?? l10n.unknown,
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

    final subTitle = _useDiscnumberAsSubTitle
        ? Text('${l10n.disc} ${widget.audio.discNumber}', maxLines: 1)
        : TapAbleText(
            maxLines: 1,
            wrapInFlexible: true,
            text: switch (widget.audioPageType) {
              AudioPageType.artist => widget.audio.album ?? l10n.unknown,
              _ => widget.audio.artist ?? l10n.unknown,
            },
            onTap: widget.onSubTitleTap == null
                ? null
                : () =>
                      widget.onSubTitleTap?.call(switch (widget.audioPageType) {
                        AudioPageType.artist =>
                          widget.audio.album ?? l10n.unknown,
                        _ => widget.audio.artist ?? l10n.unknown,
                      }),
          );

    const notTitleFlex = 2;

    return MouseRegion(
      key: ObjectKey(widget.audio),
      onEnter: (e) => setState(() => _hovered = true),
      onExit: (e) => setState(() => _hovered = false),
      child: ListTile(
        key: ObjectKey(widget.audio),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        minLeadingWidth: kAudioTrackWidth,
        leading: _AudioTileLeading(
          audioPageType: widget.audioPageType,
          audio: widget.audio,
          dimension: kAudioTrackWidth,
          color: color,
          selected: widget.selected,
          isPlayerPlaying: widget.isPlayerPlaying,
          hovered: _hovered,
          onTap: widget.onTap,
          hideIfNotSelected: !widget.allowLeadingImage,
        ),
        selected: widget.selected,
        selectedColor: widget.isPlayerPlaying
            ? selectedColor
            : theme.colorScheme.onSurface,
        selectedTileColor: isMobile
            ? theme.colorScheme.onSurface.withValues(alpha: 0.05)
            : Colors.transparent,
        contentPadding: audioTilePadding.copyWith(
          left: widget.audioPageType == AudioPageType.album ? 10 : null,
          right: 0,
        ),
        onTap: isMobile ? widget.onTap : null,
        title: Row(
          spacing: kLargestSpace,
          children: [
            Expanded(flex: 5, child: title),
            if (widget.showSubTitle)
              Expanded(flex: notTitleFlex, child: subTitle),
            if ((widget.audioPageType == AudioPageType.allTitlesView ||
                    widget.audioPageType == AudioPageType.playlist) &&
                widget.showSubSubTitle &&
                widget.audio.album != null)
              Expanded(
                flex: notTitleFlex,
                child: TapAbleText(
                  text: widget.audio.album!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  onTap: widget.onSubSubTitleTap != null
                      ? () => widget.onSubSubTitleTap!.call(widget.audio)
                      : null,
                ),
              ),
            if (widget.showDuration)
              SizedBox(
                width: 65,
                child: _AudioTileDuration(splitter: '', audio: widget.audio),
              ),
          ],
        ),
        trailing: _AudioTileTrailing(
          hovered: _hovered,
          audio: widget.audio,
          selected: widget.selected,
          isPlayerPlaying: widget.isPlayerPlaying,
          pageId: widget.pageId,
          audioPageType: widget.audioPageType,
          selectedColor: selectedColor,
        ),
      ),
    );
  }

  bool get _useDiscnumberAsSubTitle =>
      widget.audioPageType == AudioPageType.album &&
      widget.audio.discNumber != null &&
      widget.audio.discTotal != null &&
      widget.audio.discTotal! > 1;
}

class _AudioTileTrailing extends StatelessWidget with WatchItMixin {
  const _AudioTileTrailing({
    required this.audio,
    required this.selected,
    required this.isPlayerPlaying,
    required this.pageId,
    required this.audioPageType,
    required this.hovered,
    required this.selectedColor,
  });

  final Audio audio;
  final bool selected;
  final bool isPlayerPlaying;
  final String pageId;
  final AudioPageType audioPageType;
  final bool hovered;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    final liked = watchPropertyValue((LibraryModel m) => m.isLikedAudio(audio));

    return Row(
      spacing: kSmallestSpace,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!isMobile)
          Opacity(
            opacity: hovered || selected || liked ? 1 : 0,
            child: switch (audio.audioType) {
              AudioType.local => LikeIconButton(
                audio: audio,
                color: selected && isPlayerPlaying ? selectedColor : null,
              ),
              _ => SizedBox.square(dimension: context.theme.buttonTheme.height),
            },
          ),
        AudioTileOptionButton(
          title: Text(audio.title ?? ''),
          subTitle: Text(audio.artist ?? ''),
          playlistId: pageId,
          audios: [audio],
          searchTerm: '${audio.artist ?? ''} - ${audio.title ?? ''}',
          allowRemove:
              (audioPageType == AudioPageType.playlist ||
                  audioPageType == AudioPageType.likedAudio) &&
              audio.audioType != AudioType.radio,
        ),
      ],
    );
  }
}

class _AudioTileDuration extends StatelessWidget {
  const _AudioTileDuration({required this.audio, this.splitter = ' · '});

  final Audio audio;
  final String splitter;

  @override
  Widget build(BuildContext context) => Text(
    audio.audioType != AudioType.radio && audio.durationMs != null
        ? '$splitter${Duration(milliseconds: audio.durationMs!.toInt()).formattedTime}'
        : '',
    overflow: TextOverflow.ellipsis,
  );
}

class _AudioTileLeading extends StatelessWidget {
  const _AudioTileLeading({
    required this.audio,
    required this.audioPageType,
    required this.selected,
    required this.isPlayerPlaying,
    this.color,
    required this.dimension,
    required this.hovered,
    required this.onTap,
    this.hideIfNotSelected = true,
  });

  final Audio audio;
  final AudioPageType audioPageType;
  final bool selected;

  final bool isPlayerPlaying;

  final Color? color;
  final double dimension;
  final bool hovered;
  final VoidCallback onTap;
  final bool hideIfNotSelected;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: dimension,
    child: hovered || selected
        ? IconButton(
            onPressed: onTap,
            icon: switch ((isPlayerPlaying, selected)) {
              (true, true) => const Icon(Icons.pause),
              (true, false) => const Icon(Icons.play_arrow),
              (false, true) => const Icon(Icons.play_arrow),
              (false, false) => const Icon(Icons.play_arrow),
            },
          )
        : hideIfNotSelected
        ? null
        : switch (audioPageType) {
            AudioPageType.album => _AlbumTileLead(
              trackNumber: audio.trackNumber,
              color: color,
            ),
            _ => Center(
              child: AudioTileImage(
                key: switch (audio.audioType) {
                  AudioType.radio => ValueKey(audio.uuid),
                  _ => null,
                },
                size: dimension * 0.5,
                audio: audio,
              ),
            ),
          },
  );
}

class _AlbumTileLead extends StatelessWidget {
  const _AlbumTileLead({required this.trackNumber, this.color});

  final int? trackNumber;
  final Color? color;

  @override
  Widget build(BuildContext context) => Center(
    widthFactor: 1,
    child: Text(
      trackNumber?.toString() ?? '0',
      style: context.theme.textTheme.labelLarge?.copyWith(color: color),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    ),
  );
}
