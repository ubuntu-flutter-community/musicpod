import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../common/view/common_control_panel.dart';
import '../../l10n/l10n.dart';
import '../radio_model.dart';

class RadioLibPageControlPanel extends StatelessWidget with WatchItMixin {
  const RadioLibPageControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final radioCollectionView = watchPropertyValue(
      (RadioModel m) => m.radioCollectionView,
    );
    final radioModel = di<RadioModel>();

    return CommonControlPanel(
      onSelected: (index) =>
          radioModel.setRadioCollectionView(RadioCollectionView.values[index]),
      labels: [
        Text(context.l10n.station),
        Text(context.l10n.tags),
        Text(context.l10n.hearingHistory),
      ],
      isSelected: RadioCollectionView.values
          .map((e) => e == radioCollectionView)
          .toList(),
    );
  }
}
