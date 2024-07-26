import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/app_model.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../radio_model.dart';
import 'radio_search.dart';

class RadioControlPanel extends StatelessWidget with WatchItMixin {
  const RadioControlPanel({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final index = watchPropertyValue((AppModel m) => m.radioindex);

    return Align(
      alignment: Alignment.center,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(top: 10),
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
            di<AppModel>().radioindex = index;
            di<RadioModel>().setSearchQuery(search: RadioSearch.values[index]);
          },
        ),
      ),
    );
  }
}
