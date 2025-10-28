import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';

import '../../app/connectivity_model.dart';
import '../../app/view/routing_manager.dart';
import '../../common/data/audio_type.dart';
import '../../common/page_ids.dart';
import '../../common/view/audio_card.dart';
import '../../common/view/audio_card_bottom.dart';
import '../../common/view/confirm.dart';
import '../../common/view/icons.dart';
import '../../common/view/no_search_result_page.dart';
import '../../common/view/offline_page.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/sliver_body.dart';
import '../../common/view/theme.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import '../../search/search_model.dart';
import '../../settings/view/settings_action.dart';
import '../podcast_model.dart';
import 'podcast_collection_control_panel.dart';

class PodcastsCollectionBody extends StatelessWidget with WatchItMixin {
  const PodcastsCollectionBody({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isOnline = watchPropertyValue((ConnectivityModel m) => m.isOnline);
    if (!isOnline) return const OfflineBody();

    final subs = watchPropertyValue((LibraryModel m) => m.podcastFeedUrls);
    final libraryModel = di<LibraryModel>();
    final updatesLength = watchPropertyValue(
      (LibraryModel m) => m.podcastUpdatesLength,
    );
    final updatesOnly = watchPropertyValue((PodcastModel m) => m.updatesOnly);
    final downloadsOnly = watchPropertyValue(
      (PodcastModel m) => m.downloadsOnly,
    );
    final subsLength = watchPropertyValue((LibraryModel m) => m.podcastsLength);
    final feedsWithDownloadLength = watchPropertyValue(
      (LibraryModel m) => m.feedsWithDownloadsLength,
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
            onConfirm: () => di<PodcastModel>().checkForUpdates(
              updateMessage: context.l10n.newEpisodeAvailable,
              multiUpdateMessage: (length) =>
                  context.l10n.newEpisodesAvailableFor(length),
            ),
          );
        } else {
          di<PodcastModel>().checkForUpdates(
            updateMessage: context.l10n.newEpisodeAvailable,
            multiUpdateMessage: (length) =>
                context.l10n.newEpisodesAvailableFor(length),
          );
        }
      },
      contentBuilder: (context, constraints) => (subsLength == 0)
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
                      .where((e) => libraryModel.podcastUpdateAvailable(e))
                      .elementAtOrNull(index);
                } else if (downloadsOnly) {
                  feedUrl = subs
                      .where((e) => libraryModel.feedHasDownload(e))
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
                    url: di<LibraryModel>().getSubscribedPodcastImage(feedUrl),
                    fit: BoxFit.cover,
                    height: audioCardDimension,
                    width: audioCardDimension,
                    fallBackIcon: Icon(Iconz.podcast, size: 70),
                  ),
                  bottom: AudioCardBottom(
                    style: libraryModel.podcastUpdateAvailable(feedUrl)
                        ? theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ) ??
                              TextStyle(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              )
                        : null,
                    text: di<LibraryModel>().getSubscribedPodcastName(feedUrl),
                  ),
                  onPlay: () async {
                    final episodes = await di<PodcastModel>().findEpisodes(
                      feedUrl: feedUrl,
                    );
                    di<PlayerModel>().startPlaylist(
                      audios: episodes,
                      listName: feedUrl!,
                    );
                  },
                  onTap: () => di<RoutingManager>().push(pageId: feedUrl!),
                );
              },
            ),
    );
  }
}
