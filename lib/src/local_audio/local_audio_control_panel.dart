import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../build_context_x.dart';
import '../../library.dart';
import '../../local_audio.dart';
import '../../theme.dart';
import '../l10n/l10n.dart';

class LocalAudioControlPanel extends StatelessWidget {
  const LocalAudioControlPanel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final libraryModel = context.read<LibraryModel>();
    final index = context.select((LibraryModel m) => m.localAudioindex) ?? 0;

    return Row(
      children: [
        const SizedBox(
          width: 20,
        ),
        YaruChoiceChipBar(
          chipBackgroundColor: chipThemeColor(theme),
          borderColor: Colors.transparent,
          yaruChoiceChipBarStyle: YaruChoiceChipBarStyle.wrap,
          selectedFirst: false,
          clearOnSelect: false,
          labels: LocalAudioView.values
              .map((e) => Text(e.localize(context.l10n)))
              .toList(),
          isSelected: LocalAudioView.values
              .map((e) => e == LocalAudioView.values[index])
              .toList(),
          onSelected: libraryModel.setLocalAudioindex,
        ),
      ],
    );
  }
}
