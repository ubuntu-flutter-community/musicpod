import 'package:flutter/material.dart';
import 'package:flutter_it/flutter_it.dart';
import 'package:future_loading_dialog/future_loading_dialog.dart';

import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/audio_card.dart';
import '../../common/view/audio_card_bottom.dart';
import '../../common/view/confirm.dart';
import '../../common/view/error_page.dart';
import '../../common/view/icons.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/progress.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/sliver_body.dart';
import '../../common/view/theme.dart';
import '../../common/view/ui_constants.dart';
import '../../extensions/build_context_x.dart';
import '../../player/player_model.dart';
import '../../search/search_manager.dart';
import '../../settings/view/settings_action.dart';
import '../data/podcast_update_capsule.dart';
import '../podcast_manager.dart';
import 'podcast_collection_control_panel.dart';

class PodcastsCollectionBody extends StatelessWidget with WatchItMixin {
  const PodcastsCollectionBody({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;

    final subsResults = watchValue(
      (PodcastManager m) => m.togglePodcastCommand.results,
    );
    final subs = subsResults.data ?? [];
    final podcastManager = di<PodcastManager>();
    final updates = watchValue((PodcastManager m) => m.manageUpdatesCommand);
    final updatesOnly = watchValue((PodcastManager m) => m.updatesOnly);
    final downloadsOnly = watchValue((PodcastManager m) => m.downloadsOnly);
    final subsLength = subs.length;
    final feedsWithDownloads = watchValue(
      (PodcastManager m) => m.feedsWithDownloadsCommand,
    );
    final feedsWithDownloadLength = feedsWithDownloads.length;

    final checkingForUpdates = watchValue(
      (PodcastManager m) => m.manageUpdatesCommand.isRunning,
    );
    final progress = watchValue(
      (PodcastManager m) => m.manageUpdatesCommand.progress,
    );

    if (subsResults.hasError) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorBody(
          error: subsResults.error!,
          stackTrace: subsResults.stackTrace,
          onRetry: () => di<PodcastManager>().togglePodcastCommand.run(),
        ),
      );
    }

    final itemCount = updatesOnly
        ? updates.length
        : (downloadsOnly ? feedsWithDownloadLength : subsLength);

    return SliverBody(
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
            onConfirm: () => di<PodcastManager>().manageUpdatesCommand.runAsync(
              const PodcastUpdateCapsule.updateAll(),
            ),
          );
        } else {
          await di<PodcastManager>().manageUpdatesCommand.runAsync(
            const PodcastUpdateCapsule.updateAll(),
          );
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
                if (updatesOnly) {
                  feedUrl = subs
                      .toSet()
                      .intersection(updates)
                      .elementAtOrNull(index);
                } else if (downloadsOnly) {
                  feedUrl = subs
                      .where(
                        (e) => podcastManager.feedsWithDownloadsCommand.value
                            .contains(e),
                      )
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
                    style: updates.contains(feedUrl)
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
                            .runAsync((
                              item: null,
                              feedUrl: feedUrl,
                              tryFromDbOnly: true,
                            )),
                      ).then((res) {
                        if (res.isValue) {
                          di<PlayerModel>().startPlaylist(
                            audios: res.asValue!.value,
                            listName: feedUrl!,
                          );
                        } else {
                          context.toast(Text(context.l10n.podcastFeedIsEmpty));
                        }
                      }),
                  onTap: () => di<RoutingManager>().push(pageId: feedUrl!),
                );
              },
            ),
    );
  }
}
