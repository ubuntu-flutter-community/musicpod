import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';

import '../../app/connectivity_manager.dart';
import '../../app/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../app/page_ids.dart';
import '../../common/view/audio_card.dart';
import '../../common/view/audio_card_bottom.dart';
import '../../common/view/confirm.dart';
import '../../common/view/icons.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/offline_page.dart';
import '../../common/view/progress.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/sliver_body.dart';
import '../../common/view/snackbars.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../player/player_model.dart';
import '../../search/search_model.dart';
import '../../settings/view/settings_action.dart';
import '../podcast_manager.dart';
import 'podcast_collection_control_panel.dart';

class PodcastsCollectionBody extends StatelessWidget with WatchItMixin {
  const PodcastsCollectionBody({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isOnline = watchValue(
      (ConnectivityManager m) =>
          m.connectivityCommand.select((p) => p.isOnline),
    );
    if (!isOnline) return const OfflineBody();

    final subs = watchPropertyValue((PodcastManager m) => m.podcastFeedUrls);
    final podcastManager = di<PodcastManager>();
    final updatesLength = watchPropertyValue(
      (PodcastManager m) => m.podcastUpdatesLength,
    );
    final updatesOnly = watchValue((PodcastManager m) => m.updatesOnly);
    final downloadsOnly = watchValue((PodcastManager m) => m.downloadsOnly);
    final subsLength = watchPropertyValue(
      (PodcastManager m) => m.podcastsLength,
    );
    final feedsWithDownloadLength = watchPropertyValue(
      (PodcastManager m) => m.feedsWithDownloadsLength,
    );

    final checkingForUpdates = watchValue(
      (PodcastManager m) => m.checkForUpdateAndRefreshIfNeededCommand.isRunning,
    );
    final progress = watchValue(
      (PodcastManager m) => m.checkForUpdateAndRefreshIfNeededCommand.progress,
    );

    final itemCount = updatesOnly
        ? updatesLength
        : (downloadsOnly ? feedsWithDownloadLength : subsLength);

    return SliverBody(
      controlPanel: const PodcastCollectionControlPanel(),
      controlPanelSuffix: const SettingsButton.icon(scrollIndex: 1),
      onStretchTrigger: () async {
        if (subsLength > 10) {
          ConfirmationDialog.show(
            context: context,
            title: Text(context.l10n.checkForUpdates),
            confirmLabel: context.l10n.checkForUpdates,
            content: Text(
              context.l10n.checkForUpdatesConfirm(subsLength.toString()),
            ),
            onConfirm: () => di<PodcastManager>()
                .checkForUpdateAndRefreshIfNeededCommand
                .runAsync((
                  feedUrls: di<PodcastManager>().podcastFeedUrls,

                  multiUpdateMessage: (length) =>
                      context.l10n.newEpisodesAvailableFor(length),
                )),
          );
        } else {
          di<PodcastManager>().checkForUpdateAndRefreshIfNeededCommand
              .runAsync((
                feedUrls: di<PodcastManager>().podcastFeedUrls,
                multiUpdateMessage: (length) =>
                    context.l10n.newEpisodesAvailableFor(length),
              ));
        }
      },
      contentBuilder: (context, constraints) => checkingForUpdates
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
                      di<SearchModel>()
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
                if (updatesOnly) {
                  feedUrl = subs
                      .where((e) => podcastManager.podcastUpdateAvailable(e))
                      .elementAtOrNull(index);
                } else if (downloadsOnly) {
                  feedUrl = subs
                      .where((e) => podcastManager.feedHasDownload(e))
                      .elementAtOrNull(index);
                } else {
                  feedUrl = subs.elementAtOrNull(index);
                }

                if (feedUrl == null) {
                  return const SizedBox.shrink();
                }

                return AudioCard(
                  key: ValueKey(feedUrl),
                  image: SafeNetworkImage(
                    url: di<PodcastManager>().getSubscribedPodcastImage(
                      feedUrl,
                    ),
                    fit: BoxFit.cover,
                    height: audioCardDimension,
                    width: audioCardDimension,
                    fallBackIcon: Icon(Iconz.podcast, size: 70),
                  ),
                  bottom: AudioCardBottom(
                    style: podcastManager.podcastUpdateAvailable(feedUrl)
                        ? theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ) ??
                              TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              )
                        : null,
                    text: di<PodcastManager>().getSubscribedPodcastName(
                      feedUrl,
                    ),
                  ),
                  onPlay: () =>
                      showFutureLoadingDialog(
                        barrierDismissible: true,
                        title: context.l10n.loadingPodcastFeed,
                        context: context,
                        future: () => di<PodcastManager>()
                            .getEpisodesCommand(feedUrl!)
                            .runAsync((item: null, feedUrl: feedUrl)),
                      ).then((res) {
                        if (res.isValue) {
                          di<PlayerModel>().startPlaylist(
                            audios: res.asValue!.value,
                            listName: feedUrl!,
                          );
                        } else {
                          showSnackBar(
                            context: context,
                            content: Text(context.l10n.podcastFeedIsEmpty),
                          );
                        }
                      }),
                  onTap: () => di<RoutingManager>().push(pageId: feedUrl!),
                );
              },
            ),
    );
  }
}
