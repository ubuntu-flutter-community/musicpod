import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/connectivity_model.dart';
import '../../common/view/confirm.dart';
import '../../common/view/icons.dart';
import '../../common/view/offline_page.dart';
import '../../common/view/ui_constants.dart';
import '../../custom_content/custom_content_model.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../settings/view/settings_action.dart';
import '../podcast_model.dart';

class PodcastCollectionControlPanel extends StatelessWidget with WatchItMixin {
  const PodcastCollectionControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final model = di<PodcastModel>();

    final isOnline = watchPropertyValue((ConnectivityModel m) => m.isOnline);
    if (!isOnline) return const OfflineBody();

    final checkingForUpdates = watchPropertyValue(
      (PodcastModel m) => m.checkingForUpdates,
    );
    final updatesOnly = watchPropertyValue((PodcastModel m) => m.updatesOnly);
    final downloadsOnly = watchPropertyValue(
      (PodcastModel m) => m.downloadsOnly,
    );
    final processing = watchPropertyValue(
      (CustomContentModel m) => m.processing,
    );

    return Row(
      spacing: kSmallestSpace,
      children: [
        const SizedBox(width: kSmallestSpace + 2 * kLargestSpace),
        Expanded(
          child: Center(
            child: YaruChoiceChipBar(
              showCheckMarks: false,
              goNextIcon: Icon(Iconz.goNext),
              goPreviousIcon: Icon(Iconz.goBack),
              style: YaruChoiceChipBarStyle.wrap,
              clearOnSelect: false,
              selectedFirst: false,
              labels: [
                Text(context.l10n.newEpisodes),
                Text(context.l10n.downloadsOnly),
              ],
              isSelected: [updatesOnly, downloadsOnly],
              onSelected: processing || checkingForUpdates
                  ? null
                  : (index) {
                      if (index == 0) {
                        if (updatesOnly) {
                          model.setUpdatesOnly(false);
                        } else {
                          if (di<LibraryModel>().podcastsLength > 10) {
                            showDialog(
                              context: context,
                              builder: (context) => ConfirmationDialog(
                                title: Text(context.l10n.checkForUpdates),
                                confirmLabel: context.l10n.checkForUpdates,
                                content: Text(
                                  context.l10n.checkForUpdatesConfirm(
                                    di<LibraryModel>().podcastsLength
                                        .toString(),
                                  ),
                                ),
                                onConfirm: () => model.update(
                                  updateMessage:
                                      context.l10n.newEpisodeAvailable,
                                ),
                              ),
                            );
                          } else {
                            model.update(
                              updateMessage: context.l10n.newEpisodeAvailable,
                            );
                          }
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
        const SettingsButton.icon(scrollIndex: 1),
        const SizedBox(width: kSmallestSpace),
      ],
    );
  }
}
