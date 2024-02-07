import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../build_context_x.dart';
import '../../library.dart';
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

    return Consumer(
      builder: (context, ref, _) {
        final index = ref.watch(
          libraryModelProvider.select((value) => value.localAudioindex ?? 0),
        );
        final libraryModel = ref.read(libraryModelProvider);
        return Row(
          children: [
            const SizedBox(
              width: 20,
            ),
            YaruChoiceChipBar(
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
                  .map((e) => e == LocalAudioView.values[index])
                  .toList(),
              onSelected: libraryModel.setLocalAudioindex,
            ),
          ],
        );
      },
    );
  }
}
