import '../../app/connectivity_model.dart';
import '../../common/view/offline_page.dart';
import '../../common/view/snackbars.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../podcast_model.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

class PodcastCollectionControlPanel extends StatelessWidget with WatchItMixin {
  const PodcastCollectionControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final model = di<PodcastModel>();

    final isOnline = watchPropertyValue((ConnectivityModel m) => m.isOnline);
    if (!isOnline) return const OfflineBody();

    final loading =
        watchPropertyValue((PodcastModel m) => m.checkingForUpdates);
    final updatesOnly = watchPropertyValue((PodcastModel m) => m.updatesOnly);
    final downloadsOnly =
        watchPropertyValue((PodcastModel m) => m.downloadsOnly);

    return YaruChoiceChipBar(
      chipBackgroundColor: chipColor(theme),
      selectedChipBackgroundColor: chipSelectionColor(theme, loading),
      borderColor: chipBorder(theme, loading),
      yaruChoiceChipBarStyle: YaruChoiceChipBarStyle.wrap,
      clearOnSelect: false,
      selectedFirst: false,
      labels: [
        Text(
          context.l10n.newEpisodes,
          style: chipTextStyle(theme),
        ),
        Text(
          context.l10n.downloadsOnly,
          style: chipTextStyle(theme),
        ),
      ],
      isSelected: [
        updatesOnly,
        downloadsOnly,
      ],
      onSelected: loading
          ? null
          : (index) {
              if (index == 0) {
                if (updatesOnly) {
                  model.setUpdatesOnly(false);
                } else {
                  model.update(
                    updateMessage: context.l10n.newEpisodeAvailable,
                    notify: Platform.isLinux
                        ? null
                        : ({required message}) {
                            if (context.mounted) {
                              showSnackBar(
                                context: context,
                                content: Text(message),
                              );
                            }
                          },
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
    );
  }
}
