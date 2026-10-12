import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/page_ids.dart';
import '../../app/routing_manager.dart';
import '../../common/data/audio.dart';
import '../../common/data/audio_type.dart';
import '../../common/view/clean_up_caches.dart';
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
import '../manager/podcast_collection_filter_manager.dart';
import '../manager/podcast_feeds_with_downloads_manager.dart';
import '../manager/podcast_updates_manager.dart';
import '../manager/subscribed_podcasts_manager.dart';
import 'podcast_collection_card.dart';
import 'podcast_collection_control_panel.dart';
import 'sliver_podcast_page_list.dart';

class PodcastsCollectionBody extends ConsumerStatefulWidget {
  const PodcastsCollectionBody({super.key});

  @override
  ConsumerState<PodcastsCollectionBody> createState() =>
      _PodcastsCollectionBodyState();
}

class _PodcastsCollectionBodyState
    extends ConsumerState<PodcastsCollectionBody> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      clearInMemoryImageCache();
      ref
          .read(podcastCleanManagerProvider.notifier)
          .clean(reclaimDiskSpace: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final updatesState = ref.watch(podcastUpdatesManagerProvider);
    final updates = updatesState.updates;
    final checkingForUpdates = updatesState.isRunning;
    final progress = updatesState.progress;

    final subsAsync = ref.watch(subscribedPodcastsManagerProvider);
    if (subsAsync.hasError) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: ErrorBody(
          error: subsAsync.error!,
          stackTrace: subsAsync.stackTrace,
          onRetry: () =>
              ref.read(subscribedPodcastsManagerProvider.notifier).refresh(),
        ),
      );
    }

    final subs = subsAsync.value ?? <String>{};
    final subsLength = subs.length;

    final updatesOnly = ref.watch(podcastUpdatesOnlyManagerProvider);
    final downloadsOnly = ref.watch(podcastDownloadsOnlyManagerProvider);
    final feedsWithDownloads =
        ref.watch(podcastFeedsWithDownloadsManagerProvider).value ??
        <String>{};
    final feedsWithDownloadLength = feedsWithDownloads.length;

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
            onConfirm: () => ref
                .read(podcastUpdatesManagerProvider.notifier)
                .run(const PodcastUpdateCapsule.updateAll()),
          );
        } else {
          await ref
              .read(podcastUpdatesManagerProvider.notifier)
              .run(const PodcastUpdateCapsule.updateAll());
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
          ? SliverNewEpispdesList(updates: updates)
          : (subsLength == 0)
          ? SliverNoSearchResultPage(
              message: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.l10n.noPodcastSubsFound),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      ref
                          .read(routingManagerProvider.notifier)
                          .push(pageId: PageIDs.searchPage);
                      ref.read(searchManagerProvider.notifier)
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
                        (e) => feedsWithDownloads.contains(e),
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

class SliverNewEpispdesList extends ConsumerStatefulWidget {
  const SliverNewEpispdesList({super.key, required this.updates});

  final Map<String, Set<Audio>> updates;

  @override
  ConsumerState<SliverNewEpispdesList> createState() =>
      _SliverNewEpispdesListState();
}

class _SliverNewEpispdesListState
    extends ConsumerState<SliverNewEpispdesList> {
  late final PodcastUpdatesManager _updatesManager;

  @override
  void initState() {
    super.initState();
    _updatesManager = ref.read(podcastUpdatesManagerProvider.notifier);
  }

  @override
  void dispose() {
    Future(() {
      _updatesManager.run(
        PodcastUpdateCapsule(
          feedUrls: widget.updates.keys.toList(),
          type: PodcastUpdateType.remove,
        ),
      );
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverPodcastPageList(
      audios: widget.updates.values.expand((e) => e).toList(),
      feedUrl: 'newPodcastEpisodes',
      includePodcastImage: true,
    );
  }
}
