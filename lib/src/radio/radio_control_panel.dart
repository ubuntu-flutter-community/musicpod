import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yaru/yaru.dart';

import '../../build_context_x.dart';
import '../../l10n.dart';
import '../../library.dart';
import '../../radio.dart';
import '../../theme.dart';
import 'radio_search.dart';

class RadioControlPanel extends ConsumerWidget {
  const RadioControlPanel({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = context.t;
    final libraryModel = ref.read(libraryModelProvider);
    final model = ref.read(radioModelProvider);
    final index = ref.watch(libraryModelProvider.select((m) => m.radioindex));

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
          model.setSearchQuery(search: RadioSearch.values[index]);
        },
      ),
    );
  }
}
