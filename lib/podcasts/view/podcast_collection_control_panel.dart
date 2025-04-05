import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/connectivity_model.dart';
import '../../common/view/confirm.dart';
import '../../common/view/icons.dart';
import '../../common/view/offline_page.dart';
import '../../common/view/progress.dart';
import '../../common/view/ui_constants.dart';
import '../../custom_content/custom_content_model.dart';
import '../../l10n/l10n.dart';
import '../podcast_model.dart';

class PodcastCollectionControlPanel extends StatelessWidget with WatchItMixin {
  const PodcastCollectionControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final model = di<PodcastModel>();

    final isOnline = watchPropertyValue((ConnectivityModel m) => m.isOnline);
    if (!isOnline) return const OfflineBody();

    final checkingForUpdates =
        watchPropertyValue((PodcastModel m) => m.checkingForUpdates);
    final updatesOnly = watchPropertyValue((PodcastModel m) => m.updatesOnly);
    final downloadsOnly =
        watchPropertyValue((PodcastModel m) => m.downloadsOnly);
    final importingExporting =
        watchPropertyValue((CustomContentModel m) => m.importingExporting);

    return Row(
      spacing: kSmallestSpace,
      children: [
        const SizedBox(width: 4 * kLargestSpace),
        Expanded(
          child: Center(
            child: YaruChoiceChipBar(
              goNextIcon: Icon(Iconz.goNext),
              goPreviousIcon: Icon(Iconz.goBack),
              style: YaruChoiceChipBarStyle.wrap,
              clearOnSelect: false,
              selectedFirst: false,
              labels: [
                Text(
                  context.l10n.newEpisodes,
                ),
                Text(
                  context.l10n.downloadsOnly,
                ),
              ],
              isSelected: [
                updatesOnly,
                downloadsOnly,
              ],
              onSelected: importingExporting || checkingForUpdates
                  ? null
                  : (index) {
                      if (index == 0) {
                        if (updatesOnly) {
                          model.setUpdatesOnly(false);
                        } else {
                          model.update(
                            updateMessage: context.l10n.newEpisodeAvailable,
                          );
                          model.setUpdatesOnly(true);
                          model.setDownloadsOnly(false);
                        }
                      } else {
                        if (downloadsOnly) {
                          model.setDownloadsOnly(false);
                        } else {
                          model.setDownloadsOnly(true);
                          model.setUpdatesOnly(false);
                        }
                      }
                    },
            ),
          ),
        ),
        if (importingExporting || checkingForUpdates)
          const SizedBox(
            width: 22,
            height: 22,
            child: Progress(
              strokeWidth: 2,
            ),
          )
        else ...[
          IconButton(
            icon: Icon(
              Iconz.download,
              semanticLabel: context.l10n.exportPodcastsToOpmlFile,
            ),
            tooltip: context.l10n.exportPodcastsToOpmlFile,
            onPressed: () =>
                di<CustomContentModel>().exportPodcastsToOpmlFile(),
          ),
          IconButton(
            icon: Icon(
              Iconz.upload,
              semanticLabel: context.l10n.importPodcastsFromOpmlFile,
            ),
            tooltip: context.l10n.importPodcastsFromOpmlFile,
            onPressed: () =>
                di<CustomContentModel>().importPodcastsFromOpmlFile(),
          ),
          IconButton(
            icon: Icon(Iconz.remove),
            tooltip: context.l10n.podcasts,
            onPressed: () => showDialog(
              context: context,
              builder: (_) => ConfirmationDialog(
                title: Text(context.l10n.removeAllPodcastsConfirm),
                content: Text(context.l10n.removeAllPodcastsDescription),
                confirmLabel: context.l10n.ok,
                cancelLabel: context.l10n.cancel,
                onConfirm: () => model.removeAllPodcasts(),
              ),
            ),
          ),
        ],
        const SizedBox(width: kSmallestSpace),
      ],
    );
  }
}
