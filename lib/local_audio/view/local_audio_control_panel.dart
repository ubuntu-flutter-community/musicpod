import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/app_model.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
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
    final appModel = di<AppModel>();

    final index = watchPropertyValue((AppModel m) => m.localAudioindex);
    final manualFilter = watchPropertyValue((AppModel m) => m.manualFilter);

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
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.only(top: 10, right: 20, left: 20),
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
            appModel.setManualFilter(true);
            appModel.localAudioindex = index;
          },
        ),
      ),
    );
  }
}
