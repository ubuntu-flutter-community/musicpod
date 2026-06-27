import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';

import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/confirm.dart';
import '../../common/view/default_page_body.dart';
import '../../common/view/error_page.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/progress.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../search/manager/search_manager.dart';
import '../../settings/view/settings_action.dart';
import '../data/podcast_update_capsule.dart';
import '../manager/podcast_clean_manager.dart';
import '../manager/podcast_feeds_with_downloads_manager.dart';
import '../manager/podcast_manager.dart';
import '../manager/podcast_updates_manager.dart';
import '../manager/subscribed_podcasts_manager.dart';
import 'podcast_collection_card.dart';
import 'podcast_collection_control_panel.dart';
import 'sliver_podcast_page_list.dart';

class PodcastsCollectionBody extends StatelessWidget with WatchItMixin {
  const PodcastsCollectionBody({super.key});

  @override
  Widget build(BuildContext context) {
    callOnceAfterThisBuild(
      (context) => di<PodcastCleanManager>().command.run(),
    );

    final subsResults = watchValue(
      (SubscribedPodcastsManager m) => m.command.results,
    );
    final subs = subsResults.data ?? {};
    final updates = watchValue((PodcastUpdatesManager m) => m.command);
    final updatesOnly = watchValue((PodcastManager m) => m.updatesOnly);
    final downloadsOnly = watchValue((PodcastManager m) => m.downloadsOnly);

    final subsLength = subs.length;
    final feedsWithDownloads = watchValue(
      (PodcastFeedsWithDownloadsManager m) => m.command,
    );
    final feedsWithDownloadLength = feedsWithDownloads.length;

    final checkingForUpdates = watchValue(
      (PodcastUpdatesManager m) => m.command.isRunning,
    );
    final progress = watchValue(
      (PodcastUpdatesManager m) => m.command.progress,
    );

    if (subsResults.hasError) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorBody(
          error: subsResults.error!,
          stackTrace: subsResults.stackTrace,
          onRetry: () => di<SubscribedPodcastsManager>().command.run(),
        ),
      );
    }

    final itemCount = updatesOnly
        ? updates.length
        : (downloadsOnly ? feedsWithDownloadLength : subsLength);

    return DefaultPageBody(
      controlPanel: const PodcastCollectionControlPanel(),
      controlPanelSuffix: const SettingsButton.icon(scrollIndex: 1),
      onStretchTrigger: () async {
        if (subsLength > 10) {
          await ConfirmationDialog.show(
            context: context,
            title: Text(context.l10n.checkForUpdates),
            confirmLabel: context.l10n.checkForUpdates,
            content: Text(
              context.l10n.checkForUpdatesConfirm(subsLength.toString()),
            ),
            onConfirm: () => di<PodcastUpdatesManager>().command.runAsync(
              const PodcastUpdateCapsule.updateAll(),
            ),
          );
        } else {
          await di<PodcastUpdatesManager>().command.runAsync(
            const PodcastUpdateCapsule.updateAll(),
          );
        }
      },
      sliverContentBuilder: (context, constraints) => checkingForUpdates
          ? SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Column(
                  spacing: kLargestSpace,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Progress(value: progress, adaptive: false),
                    Text(
                      context.l10n.checkingForUpdatesPleaseWait(
                        (progress * 100).toInt(),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : updates.isNotEmpty && updatesOnly
          ? SliverPodcastPageList(
              audios: updates.values.expand((e) => e).toList(),
              pageId: 'newPodcastEpisodes',
            )
          : (subsLength == 0)
          ? SliverNoSearchResultPage(
              message: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.l10n.noPodcastSubsFound),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      di<RoutingManager>().push(pageId: PageIDs.searchPage);
                      di<SearchManager>()
                        ..setAudioType(AudioType.podcast)
                        ..setSearchQuery(null)
                        ..search();
                    },
                    child: Text(context.l10n.discover),
                  ),
                ],
              ),
            )
          : SliverGrid.builder(
              itemCount: itemCount,
              gridDelegate: audioCardGridDelegate,
              itemBuilder: (context, index) {
                final String? feedUrl;
                if (downloadsOnly) {
                  feedUrl = subs
                      .where(
                        (e) => di<PodcastFeedsWithDownloadsManager>()
                            .command
                            .value
                            .contains(e),
                      )
                      .elementAtOrNull(index);
                } else {
                  feedUrl = subs.elementAtOrNull(index);
                }

                if (feedUrl == null) {
                  return const SizedBox.shrink();
                }

                return PodcastCollectionCard(
                  key: ValueKey(feedUrl),
                  feedUrl: feedUrl,
                  hasUpdated: updates.containsKey(feedUrl),
                );
              },
            ),
    );
  }
}
