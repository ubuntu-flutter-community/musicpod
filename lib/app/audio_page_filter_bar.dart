import 'package:flutter/widgets.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AudioPageFilterBar extends StatelessWidget {
  const AudioPageFilterBar({
    super.key,
    required this.mainPageType,
    required this.audioPageType,
    required this.setAudioPageType,
  });

  final Iterable<AudioPageType> mainPageType;
  final AudioPageType? audioPageType;
  final Function(AudioPageType? value) setAudioPageType;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 5,
          bottom: 5,
          right: 18,
          left: 28,
        ),
        child: YaruChoiceChipBar(
          yaruChoiceChipBarStyle: YaruChoiceChipBarStyle.stack,
          labels:
              mainPageType.map((e) => Text(e.localize(context.l10n))).toList(),
          onSelected: (index) =>
              setAudioPageType(mainPageType.elementAt(index)),
          isSelected: mainPageType.map((e) => e == audioPageType).toList(),
        ),
      ),
    );
  }
}
