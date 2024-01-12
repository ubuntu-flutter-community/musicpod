import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../l10n.dart';
import 'radio_model.dart';
import 'radio_search.dart';

class RadioControlPanel extends StatelessWidget {
  const RadioControlPanel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final model = context.read<RadioModel>();

    final radioSearch = context.select((RadioModel m) => m.radioSearch);
    final setRadioSearch = model.setRadioSearch;
    return Padding(
      padding: const EdgeInsets.only(left: 30),
      child: YaruChoiceChipBar(
        yaruChoiceChipBarStyle: YaruChoiceChipBarStyle.wrap,
        clearOnSelect: false,
        selectedFirst: false,
        labels: RadioSearch.values
            .map((e) => Text(e.localize(context.l10n)))
            .toList(),
        isSelected: RadioSearch.values.map((e) => e == radioSearch).toList(),
        onSelected: (index) => setRadioSearch(RadioSearch.values[index]),
      ),
    );
  }
}
