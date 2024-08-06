import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../local_audio_model.dart';
import 'local_audio_view.dart';

class LocalAudioControlPanel extends StatelessWidget with WatchItMixin {
  const LocalAudioControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final index = watchPropertyValue((LocalAudioModel m) => m.localAudioindex);

    return Align(
      alignment: Alignment.center,
      child: YaruChoiceChipBar(
        chipBackgroundColor: chipColor(theme),
        selectedChipBackgroundColor: chipSelectionColor(theme, false),
        borderColor: chipBorder(theme, false),
        yaruChoiceChipBarStyle: YaruChoiceChipBarStyle.wrap,
        selectedFirst: false,
        clearOnSelect: false,
        labels: LocalAudioView.values
            .map((e) => Text(e.localize(context.l10n)))
            .toList(),
        isSelected: LocalAudioView.values
            .map((e) => e == LocalAudioView.values[index])
            .toList(),
        onSelected: (index) => di<LocalAudioModel>().localAudioindex = index,
      ),
    );
  }
}
