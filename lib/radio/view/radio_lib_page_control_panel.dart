import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../common/view/common_control_panel.dart';
import '../../extensions/build_context_x.dart';
import '../data/radio_collection_view.dart';
import '../manager/radio_collection_view_manager.dart';

class RadioLibPageControlPanel extends StatelessWidget with WatchItMixin {
  const RadioLibPageControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final radioCollectionView = watchValue(
      (RadioCollectionViewManager m) => m.radioCollectionView,
    );

    return CommonControlPanel(
      onSelected: (index) => di<RadioCollectionViewManager>()
          .setRadioCollectionView(RadioCollectionView.values[index]),
      labels: [
        Text(context.l10n.stations),
        Text(context.l10n.tags),
        Text(context.l10n.hearingHistory),
        Text(context.l10n.ignoredHearyHistoryTitlesTitle),
      ],
      isSelected: RadioCollectionView.values
          .map((e) => e == radioCollectionView)
          .toList(),
    );
  }
}
