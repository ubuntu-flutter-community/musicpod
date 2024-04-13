import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../build_context_x.dart';
import '../../get.dart';
import '../../library.dart';
import '../../local_audio.dart';
import '../../theme.dart';
import '../l10n/l10n.dart';
import 'local_audio_view.dart';

class LocalAudioControlPanel extends StatelessWidget with WatchItMixin {
  const LocalAudioControlPanel({
    super.key,
    this.titlesCount,
    this.artistCount,
    this.albumCount,
    this.genresCounts,
  });

  final int? titlesCount, artistCount, albumCount, genresCounts;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final libraryModel = getIt<LibraryModel>();
    final localAudioModel = getIt<LocalAudioModel>();

    final index =
        watchPropertyValue((LibraryModel m) => m.localAudioindex ?? 0);
    final manualFilter =
        watchPropertyValue((LocalAudioModel m) => m.manualFilter);

    var i = index;
    if (!manualFilter) {
      if (titlesCount != null &&
          titlesCount! > 0 &&
          (artistCount == null || artistCount == 0) &&
          (albumCount == null || albumCount == 0)) {
        i = LocalAudioView.titles.index;
      } else if (artistCount != null && artistCount! > 0) {
        i = LocalAudioView.artists.index;
      } else if (albumCount != null && albumCount! > 0) {
        i = LocalAudioView.albums.index;
      } else if (genresCounts != null && genresCounts! > 0) {
        i = LocalAudioView.genres.index;
      }
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: kYaruPagePadding),
        child: YaruChoiceChipBar(
          chipBackgroundColor: chipColor(theme),
          selectedChipBackgroundColor: chipSelectionColor(theme, false),
          borderColor: chipBorder(theme, false),
          yaruChoiceChipBarStyle: YaruChoiceChipBarStyle.wrap,
          selectedFirst: false,
          clearOnSelect: false,
          labels: LocalAudioView.values.map((e) {
            return switch (e) {
              LocalAudioView.titles => Text(
                  '${e.localize(context.l10n)}${titlesCount != null ? ' ($titlesCount)' : ''}',
                ),
              LocalAudioView.artists => Text(
                  '${e.localize(context.l10n)}${artistCount != null ? ' ($artistCount)' : ''}',
                ),
              LocalAudioView.albums => Text(
                  '${e.localize(context.l10n)}${albumCount != null ? ' ($albumCount)' : ''}',
                ),
              LocalAudioView.genres => Text(
                  '${e.localize(context.l10n)}${genresCounts != null ? ' ($genresCounts)' : ''}',
                ),
            };
          }).toList(),
          isSelected: LocalAudioView.values
              .map((e) => e == LocalAudioView.values[i])
              .toList(),
          onSelected: (index) {
            localAudioModel.setManualFilter(true);
            libraryModel.setLocalAudioindex(index);
          },
        ),
      ),
    );
  }
}
