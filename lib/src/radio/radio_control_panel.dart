import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:signals_flutter/signals_flutter.dart';
import 'package:ubuntu_service/ubuntu_service.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../app.dart';
import '../../build_context_x.dart';
import '../../l10n.dart';
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
    final model = context.read<RadioModel>();
    final service = getService<AppStateService>();
    final index = service.radioIndex;

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
            .map((e) => e == RadioSearch.values[index.watch(context)])
            .toList(),
        onSelected: (index) {
          service.setRadioIndex(index);
          model.setSearchQuery(search: RadioSearch.values[index]);
        },
      ),
    );
  }
}
