import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/view/confirm.dart';
import '../../common/view/icons.dart';
import '../../custom_content/service/custom_content_service.dart';
import '../../dependencies.dart';
import '../../extensions/build_context_x.dart';
import '../../radio/manager/radio_star_station_manager.dart';
import '../manager/wipe_manager.dart';
import 'settings_list_tile.dart';
import 'settings_section.dart';

class RadioSection extends StatelessWidget {
  const RadioSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SettingsSection(
      heading: l10n.radio,
      children: [
        SettingsListTile(
          position: ListTilePosition.single,
          title: Text(l10n.starredStations),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: l10n.exportStarredStationsToOpmlFile,
                icon: Icon(
                  Iconz.export,
                  semanticLabel: l10n.exportStarredStationsToOpmlFile,
                ),
                onPressed: () => ConfirmationDialog.show(
                  context: context,
                  initialFuture: () => di<CustomContentService>()
                      .exportStarredStationsToOpmlFile(),
                  loadingTitle: Text(context.l10n.exportingStationsPleaseWait),
                  cancelLabel: context.l10n.back,
                ),
              ),
              Consumer(
                builder: (context, ref, _) => IconButton(
                  tooltip: l10n.importStarredStationsFromOpmlFile,
                  icon: Icon(Iconz.import),
                  onPressed: () => ConfirmationDialog.show(
                    context: context,
                    initialFuture: () => di<CustomContentService>()
                        .importStarredStationsFromOpmlFile()
                        .then(
                          (_) =>
                              ref.invalidate(radioStarStationManagerProvider),
                        ),
                    loadingTitle: Text(
                      context.l10n.importingStationsPleaseWait,
                    ),
                    cancelLabel: context.l10n.back,
                  ),
                ),
              ),
              Consumer(
                builder: (context, ref, _) => IconButton(
                  icon: Icon(
                    Iconz.remove,
                    semanticLabel: l10n.removeAllStarredStations,
                  ),
                  tooltip: context.l10n.removeAllStarredStations,
                  onPressed: () => ConfirmationDialog.show(
                    context: context,
                    modalLevel: ModalLevel.error,
                    headerIconData: Iconz.remove,
                    barrierDismissible: false,
                    title: Text(l10n.removeAllStarredStationsConfirm),
                    content: SizedBox(
                      width: 350,
                      child: Text(l10n.removeAllStarredStationsDescription),
                    ),
                    onConfirm: () => ref
                        .read(wipeManagerProvider.notifier)
                        .wipe({WipeType.radio}),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
