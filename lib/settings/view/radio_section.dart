import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';
import 'package:yaru/yaru.dart';

import '../../common/view/confirm.dart';
import '../../common/view/icons.dart';
import '../../common/view/ui_constants.dart';
import '../../custom_content/custom_content_model.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../radio/radio_model.dart';

class RadioSection extends StatelessWidget with WatchItMixin {
  const RadioSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    watchPropertyValue((RadioModel m) => m.radioCollectionView);

    return YaruSection(
      margin: const EdgeInsets.all(kLargestSpace),
      headline: Text(l10n.radio),
      child: Column(
        children: [
          YaruTile(
            title: Text(l10n.starredStations),
            trailing: Row(
              children: [
                IconButton(
                  tooltip: l10n.exportStarredStationsToOpmlFile,
                  icon: Icon(
                    Iconz.export,
                    semanticLabel: l10n.exportStarredStationsToOpmlFile,
                  ),
                  onPressed: () => showFutureLoadingDialog(
                    context: context,
                    future: () => di<CustomContentModel>()
                        .exportStarredStationsToOpmlFile(),
                    title: context.l10n.exportingStationsPleaseWait,
                    backLabel: context.l10n.back,
                  ),
                ),
                IconButton(
                  tooltip: l10n.importStarredStationsFromOpmlFile,
                  icon: Icon(
                    Iconz.import,
                    semanticLabel: l10n.importStarredStationsFromOpmlFile,
                  ),
                  onPressed: () => showFutureLoadingDialog(
                    context: context,
                    future: () => di<CustomContentModel>()
                        .importStarredStationsFromOpmlFile(),
                    title: context.l10n.importingStationsPleaseWait,
                    backLabel: context.l10n.back,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Iconz.remove,
                    semanticLabel: l10n.removeAllStarredStations,
                  ),
                  tooltip: context.l10n.removeAllStarredStations,
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => ConfirmationDialog(
                      showCloseIcon: false,
                      title: Text(l10n.removeAllStarredStationsConfirm),
                      content: SizedBox(
                        width: 350,
                        child: Text(l10n.removeAllStarredStationsDescription),
                      ),
                      onConfirm: () async =>
                          di<LibraryModel>().unStarAllStations(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
