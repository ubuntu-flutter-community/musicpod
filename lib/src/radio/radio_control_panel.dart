import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../build_context_x.dart';
import '../../l10n.dart';
import '../../library.dart';
import '../../radio.dart';
import '../../theme.dart';
import 'radio_search.dart';

class RadioControlPanel extends StatelessWidget {
  const RadioControlPanel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final libraryModel = context.read<LibraryModel>();
    final model = context.read<RadioModel>();
    final index = context.select((LibraryModel m) => m.radioindex);

    return Padding(
      padding: const EdgeInsets.only(left: 30),
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
          model.loadQueryBySearch(RadioSearch.values[index]);
        },
      ),
    );
  }
}
