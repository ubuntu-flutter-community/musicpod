import '../../local_audio.dart';
import '../l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class LocalAudioControlPanel extends StatelessWidget {
  const LocalAudioControlPanel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final model = context.read<LocalAudioModel>();

    final localAudioView =
        context.select((LocalAudioModel m) => m.localAudioView);
    final setLocalAudioView = model.setLocalAudioView;

    return Row(
      children: [
        const SizedBox(
          width: 20,
        ),
        YaruChoiceChipBar(
          yaruChoiceChipBarStyle: YaruChoiceChipBarStyle.wrap,
          selectedFirst: false,
          clearOnSelect: false,
          labels: LocalAudioView.values
              .map((e) => Text(e.localize(context.l10n)))
              .toList(),
          isSelected:
              LocalAudioView.values.map((e) => e == localAudioView).toList(),
          onSelected: (index) =>
              setLocalAudioView(LocalAudioView.values[index]),
        ),
      ],
    );
  }
}
