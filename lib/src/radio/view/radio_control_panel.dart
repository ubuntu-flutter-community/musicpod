import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../../build_context_x.dart';
import '../../../l10n.dart';
import '../../../library.dart';
import '../../../radio.dart';
import '../../../theme.dart';

class RadioControlPanel extends StatelessWidget with WatchItMixin {
  const RadioControlPanel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final libraryModel = di<LibraryModel>();
    final model = di<RadioModel>();
    final index = watchPropertyValue((LibraryModel m) => m.radioindex);

    return Align(
      alignment: isMobile ? Alignment.center : Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: kYaruPagePadding),
        child: YaruChoiceChipBar(
          chipBackgroundColor: chipColor(theme),
          selectedChipBackgroundColor: chipSelectionColor(theme, false),
          borderColor: chipBorder(theme, false),
          yaruChoiceChipBarStyle: YaruChoiceChipBarStyle.wrap,
          clearOnSelect: false,
          selectedFirst: false,
          labels: RadioSearch.values
              .map((e) => Text(e.localize(context.l10n)))
              .toList(),
          isSelected: RadioSearch.values
              .map((e) => e == RadioSearch.values[index])
              .toList(),
          onSelected: (index) {
            libraryModel.setRadioIndex(index);
            model.setSearchQuery(search: RadioSearch.values[index]);
          },
        ),
      ),
    );
  }
}
