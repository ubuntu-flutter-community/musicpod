import 'package:flutter/widgets.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/app/library_model.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class AudioPageFilterBar extends StatelessWidget {
  const AudioPageFilterBar({
    super.key,
    required this.mainPageType,
  });

  final Iterable<AudioPageType> mainPageType;

  @override
  Widget build(BuildContext context) {
    final audioPageType = context.select((LibraryModel m) => m.audioPageType);
    final setAudioPageType = context.read<LibraryModel>().setAudioPageType;
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(
          top: 10,
          bottom: 5,
          right: 18,
          left: 28,
        ),
        child: YaruChoiceChipBar(
          yaruChoiceChipBarStyle: YaruChoiceChipBarStyle.wrap,
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
