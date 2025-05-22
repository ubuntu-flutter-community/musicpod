import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/icons.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../settings/view/settings_action.dart';
import '../radio_model.dart';

class RadioLibPageControlPanel extends StatelessWidget with WatchItMixin {
  const RadioLibPageControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final radioCollectionView = watchPropertyValue(
      (RadioModel m) => m.radioCollectionView,
    );
    final radioModel = di<RadioModel>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Container(
        alignment: Alignment.center,
        margin: filterPanelPadding,
        height: context.theme.appBarTheme.toolbarHeight,
        child: Row(
          spacing: kSmallestSpace,
          children: [
            const SizedBox(width: kSmallestSpace + 2 * kLargestSpace),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: YaruChoiceChipBar(
                    showCheckMarks: false,
                    goNextIcon: Icon(Iconz.goNext),
                    goPreviousIcon: Icon(Iconz.goBack),
                    selectedFirst: false,
                    clearOnSelect: false,
                    onSelected: (index) => radioModel.setRadioCollectionView(
                      RadioCollectionView.values[index],
                    ),
                    style: YaruChoiceChipBarStyle.wrap,
                    labels: [
                      Text(context.l10n.station),
                      Text(context.l10n.tags),
                      Text(context.l10n.hearingHistory),
                    ],
                    isSelected: RadioCollectionView.values
                        .map((e) => e == radioCollectionView)
                        .toList(),
                  ),
                ),
              ),
            ),
            const SettingsButton.icon(scrollIndex: 3),
            const SizedBox(width: kSmallestSpace),
          ],
        ),
      ),
    );
  }
}
