import 'package:flutter/material.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../l10n/l10n.dart';

class AudioTileHeader extends StatelessWidget {
  const AudioTileHeader({
    super.key,
    this.onAudioFilterSelected,
    required this.audioFilter,
    this.showTrack = true,
    this.showArtist = true,
    this.showAlbum = true,
    this.titleLabel,
    this.artistLabel,
    this.albumLabel,
    this.titleFlex = 1,
    this.albumFlex = 1,
    this.artistFlex = 1,
    this.textStyle,
  });

  final void Function(AudioFilter audioFilter)? onAudioFilterSelected;
  final AudioFilter audioFilter;
  final bool showTrack;
  final bool showArtist;
  final bool showAlbum;
  final String? titleLabel, artistLabel, albumLabel;
  final int titleFlex, artistFlex, albumFlex;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: kAudioTilePadding,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showTrack)
            SizedBox(
              width: kAudioTrackWidth,
              child: _HeaderElement(
                onAudioFilterSelected: onAudioFilterSelected,
                label: '  #',
                audioFilter: AudioFilter.trackNumber,
                style: textStyle,
              ),
            ),
          Expanded(
            flex: titleFlex,
            child: Padding(
              padding: kAudioTileSpacing,
              child: _HeaderElement(
                onAudioFilterSelected: onAudioFilterSelected,
                label: titleLabel ?? context.l10n.title,
                audioFilter: AudioFilter.title,
                style: textStyle,
              ),
            ),
          ),
          if (showArtist)
            Expanded(
              flex: artistFlex,
              child: Padding(
                padding: kAudioTileSpacing,
                child: _HeaderElement(
                  onAudioFilterSelected: onAudioFilterSelected,
                  label: artistLabel ?? context.l10n.artist,
                  audioFilter: AudioFilter.artist,
                  style: textStyle,
                ),
              ),
            ),
          if (showAlbum)
            Expanded(
              flex: albumFlex,
              child: _HeaderElement(
                onAudioFilterSelected: onAudioFilterSelected,
                label: albumLabel ?? context.l10n.album,
                audioFilter: AudioFilter.album,
                style: textStyle,
              ),
            ),
        ],
      ),
      trailing: SizedBox(width: likeButtonWidth),
    );
  }
}

class _HeaderElement extends StatelessWidget {
  const _HeaderElement({
    this.onAudioFilterSelected,
    required this.label,
    required this.audioFilter,
    this.style,
  });

  final void Function(AudioFilter audioFilter)? onAudioFilterSelected;
  final AudioFilter audioFilter;
  final String label;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final textStyle = style ??
        TextStyle(
          fontWeight: mediumTextWeight,
          color: onAudioFilterSelected == null
              ? theme.colorScheme.onSurface.withOpacity(0.8)
              : theme.colorScheme.onSurface,
        );
    return TapAbleText(
      style: textStyle,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      onTap: onAudioFilterSelected == null
          ? null
          : () => onAudioFilterSelected!(audioFilter),
      text: label,
    );
  }
}
