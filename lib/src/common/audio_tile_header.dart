import 'package:flutter/material.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../common.dart';
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
    this.titleFlex = 5,
    this.albumFlex = 4,
    this.artistFlex = 5,
  });

  final void Function(AudioFilter audioFilter)? onAudioFilterSelected;
  final AudioFilter audioFilter;
  final bool showTrack;
  final bool showArtist;
  final bool showAlbum;
  final String? titleLabel, artistLabel, albumLabel;
  final int titleFlex, artistFlex, albumFlex;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.only(left: 8, right: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(kYaruButtonRadius),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (showTrack)
            _HeaderElement(
              onAudioFilterSelected: onAudioFilterSelected,
              label: '#',
              audioFilter: AudioFilter.trackNumber,
              flex: 1,
            ),
          _HeaderElement(
            onAudioFilterSelected: onAudioFilterSelected,
            label: titleLabel ?? context.l10n.title,
            audioFilter: AudioFilter.title,
            flex: titleFlex,
          ),
          if (showArtist)
            _HeaderElement(
              onAudioFilterSelected: onAudioFilterSelected,
              label: artistLabel ?? context.l10n.artist,
              audioFilter: AudioFilter.artist,
              flex: artistFlex,
            ),
          if (showAlbum)
            _HeaderElement(
              onAudioFilterSelected: onAudioFilterSelected,
              label: albumLabel ?? context.l10n.album,
              audioFilter: AudioFilter.album,
              flex: albumFlex,
            ),
        ],
      ),
      trailing: const SizedBox(width: 61),
    );
  }
}

class _HeaderElement extends StatelessWidget {
  const _HeaderElement({
    this.onAudioFilterSelected,
    required this.label,
    required this.audioFilter,
    this.flex = 1,
  });

  final void Function(AudioFilter audioFilter)? onAudioFilterSelected;
  final AudioFilter audioFilter;
  final String label;
  final int flex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = TextStyle(
      fontWeight: FontWeight.w100,
      color: onAudioFilterSelected == null ? theme.hintColor : null,
    );
    return Expanded(
      flex: flex,
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(5),
            onTap: onAudioFilterSelected == null
                ? null
                : () => onAudioFilterSelected!(audioFilter),
            child: Text(
              label,
              style: textStyle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
