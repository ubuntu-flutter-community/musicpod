import 'package:flutter/material.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../app.dart';
import '../../build_context_x.dart';
import '../../theme.dart';
import '../l10n/l10n.dart';
import 'local_audio_view.dart';

class LocalAudioControlPanel extends StatelessWidget {
  const LocalAudioControlPanel({
    super.key,
    this.titlesCount,
    this.artistCount,
    this.albumCount,
  });

  final int? titlesCount, artistCount, albumCount;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final appStateService = getService<AppStateService>();
    final index = appStateService.localAudioIndex;

    return Row(
      children: [
        const SizedBox(
          width: 20,
        ),
        Watch.builder(
          builder: (context) {
            return YaruChoiceChipBar(
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
                };
              }).toList(),
              isSelected: LocalAudioView.values
                  .map((e) => e == LocalAudioView.values[index.value])
                  .toList(),
              onSelected: appStateService.setLocalAudioIndex,
            );
          },
        ),
      ],
    );
  }
}
