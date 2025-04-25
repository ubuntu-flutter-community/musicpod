import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/icons.dart';
import '../../l10n/l10n.dart';
import '../local_audio_model.dart';
import '../local_audio_view.dart';

class LocalAudioControlPanel extends StatelessWidget with WatchItMixin {
  const LocalAudioControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final index = watchPropertyValue((LocalAudioModel m) => m.localAudioindex);
    final audios = watchPropertyValue((LocalAudioModel m) => m.audios);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: YaruChoiceChipBar(
        goNextIcon: Icon(Iconz.goNext),
        goPreviousIcon: Icon(Iconz.goBack),
        style: YaruChoiceChipBarStyle.stack,
        selectedFirst: false,
        clearOnSelect: false,
        labels: LocalAudioView.values
            .map((e) => Text(e.localize(context.l10n)))
            .toList(),
        isSelected: LocalAudioView.values
            .map((e) => e == LocalAudioView.values[index])
            .toList(),
        onSelected:
            audios == null ? null : di<LocalAudioModel>().setLocalAudioindex,
      ),
    );
  }
}
