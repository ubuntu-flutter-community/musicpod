import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/common_control_panel.dart';
import '../../l10n/l10n.dart';
import '../radio_model.dart';

class RadioLibPageControlPanel extends StatelessWidget with WatchItMixin {
  const RadioLibPageControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final radioCollectionView = watchValue(
      (RadioManager m) => m.radioCollectionView,
    );

    return CommonControlPanel(
      onSelected: (index) => di<RadioManager>().setRadioCollectionView(
        RadioCollectionView.values[index],
      ),
      labels: [
        Text(context.l10n.stations),
        Text(context.l10n.tags),
        Text(context.l10n.hearingHistory),
      ],
      isSelected: RadioCollectionView.values
          .map((e) => e == radioCollectionView)
          .toList(),
    );
  }
}
