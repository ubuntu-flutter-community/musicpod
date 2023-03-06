import 'package:flutter/material.dart';
import 'package:music/app/local_audio/local_audio_model.dart';
import 'package:music/l10n/l10n.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AudioPageHeader extends StatelessWidget {
  const AudioPageHeader({
    super.key,
    this.onAudioFilterSelected,
    required this.audioFilter,
    this.showTrack = true,
  });

  final void Function(AudioFilter audioFilter)? onAudioFilterSelected;
  final AudioFilter audioFilter;
  final bool showTrack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            label: context.l10n.title,
            audioFilter: AudioFilter.title,
            flex: 5,
          ),
          _HeaderElement(
            onAudioFilterSelected: onAudioFilterSelected,
            label: context.l10n.artist,
            audioFilter: AudioFilter.artist,
            flex: 4,
          ),
          _HeaderElement(
            onAudioFilterSelected: onAudioFilterSelected,
            label: context.l10n.album,
            audioFilter: AudioFilter.album,
            flex: 4,
          ),
        ],
      ),
      trailing: YaruPopupMenuButton<AudioFilter>(
        initialValue: audioFilter,
        onSelected: onAudioFilterSelected,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            side: BorderSide.none,
            borderRadius: BorderRadius.circular(kYaruButtonRadius),
          ),
        ),
        child: Icon(
          YaruIcons.ordered_list,
          color: theme.colorScheme.onSurface,
        ),
        itemBuilder: (a) => [
          for (final filter in AudioFilter.values)
            PopupMenuItem(
              value: filter,
              child: Text(filter.name),
            )
        ],
      ),
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
    const textStyle = TextStyle(
      fontWeight: FontWeight.w100,
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
