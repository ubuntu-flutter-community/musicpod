import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../l10n.dart';
import '../../podcasts.dart';
import '../../theme.dart';
import '../globals.dart';
import '../library/library_model.dart';

class PodcastsCollectionBody extends StatelessWidget {
  const PodcastsCollectionBody({
    super.key,
    required this.isOnline,
    required this.startPlaylist,
    required this.onTapText,
    required this.addPodcast,
    required this.removePodcast,
    required this.loading,
  });

  final bool isOnline;
  final Future<void> Function({
    required Set<Audio> audios,
    required String listName,
    int? index,
  }) startPlaylist;
  final void Function(String text) onTapText;
  final void Function(String, Set<Audio>) addPodcast;
  final void Function(String) removePodcast;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final subs = context.select((LibraryModel m) => m.podcasts);
    context.select((LibraryModel m) => m.podcastUpdatesLength);
    final libraryModel = context.read<LibraryModel>();
    final podcastUpdateAvailable = libraryModel.podcastUpdateAvailable;
    final feedHasDownload = libraryModel.feedHasDownload;
    final updatesLength =
        context.select((LibraryModel m) => m.podcastUpdatesLength);
    final model = context.read<PodcastModel>();
    final updatesOnly = context.select((PodcastModel m) => m.updatesOnly);
    final downloadsOnly = context.select((PodcastModel m) => m.downloadsOnly);
    final subsLength = context.select((LibraryModel m) => m.podcastsLength);
    final feedsWithDownloadLength =
        context.select((LibraryModel m) => m.feedsWithDownloadsLength);
    final setUpdatesOnly = model.setUpdatesOnly;
    final setDownloadsOnly = model.setDownloadsOnly;
    final subscribed = libraryModel.podcastSubscribed;
    final removeUpdate = libraryModel.removePodcastUpdate;

    final itemCount = updatesOnly
        ? updatesLength
        : (downloadsOnly ? feedsWithDownloadLength : subsLength);

    return subsLength == 0
        ? NoSearchResultPage(
            message: Text(context.l10n.noPodcastSubsFound),
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 25,
                  ),
                  YaruChoiceChipBar(
                    chipBackgroundColor: chipColor(theme),
                    selectedChipBackgroundColor:
                        chipSelectionColor(theme, loading),
                    borderColor: chipBorder(theme, loading),
                    yaruChoiceChipBarStyle: YaruChoiceChipBarStyle.wrap,
                    clearOnSelect: false,
                    selectedFirst: false,
                    labels: [
                      Text(context.l10n.newEpisodes),
                      Text(
                        context.l10n.downloadsOnly,
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
                                setUpdatesOnly(false);
                              } else {
                                model.update(context.l10n.newEpisodeAvailable);

                                setUpdatesOnly(true);
                                setDownloadsOnly(false);
                              }
                            } else {
                              if (downloadsOnly) {
                                setDownloadsOnly(false);
                              } else {
                                setDownloadsOnly(true);
                                setUpdatesOnly(false);
                              }
                            }
                          },
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Expanded(
                child: loading
                    ? LoadingGrid(limit: subsLength)
                    : GridView.builder(
                        padding: gridPadding,
                        itemCount: itemCount,
                        gridDelegate: imageGridDelegate,
                        itemBuilder: (context, index) {
                          final MapEntry<String, Set<Audio>> podcast;
                          if (updatesOnly) {
                            podcast = subs.entries
                                .where((e) => podcastUpdateAvailable(e.key))
                                .elementAt(index);
                          } else if (downloadsOnly) {
                            podcast = subs.entries
                                .where((e) => feedHasDownload(e.key))
                                .elementAt(index);
                          } else {
                            podcast = subs.entries.elementAt(index);
                          }

                          final artworkUrl600 =
                              podcast.value.firstOrNull?.albumArtUrl ??
                                  podcast.value.firstOrNull?.imageUrl;
                          final image = SafeNetworkImage(
                            url: artworkUrl600,
                            fit: BoxFit.cover,
                            height: kSmallCardHeight,
                            width: kSmallCardHeight,
                          );

                          return AudioCard(
                            image: image,
                            bottom: AudioCardBottom(
                              style: podcastUpdateAvailable(podcast.key)
                                  ? theme.textTheme.bodyMedium?.copyWith(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ) ??
                                      TextStyle(
                                        color: theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      )
                                  : null,
                              text: podcast.value.firstOrNull?.album ??
                                  podcast.value.firstOrNull?.title ??
                                  podcast.value.firstOrNull.toString(),
                            ),
                            onPlay: () {
                              runOrConfirm(
                                context: context,
                                noConfirm: podcast.value.length <
                                    kAudioQueueThreshHold,
                                message: podcast.value.length.toString(),
                                run: () => startPlaylist(
                                  audios: podcast.value,
                                  listName: podcast.key,
                                ).then((_) => removeUpdate(podcast.key)),
                              );
                            },
                            onTap: () => navigatorKey.currentState?.push(
                              MaterialPageRoute(
                                builder: (context) {
                                  if (!isOnline) return const OfflinePage();

                                  return PodcastPage(
                                    subscribed: subscribed(podcast.key),
                                    pageId: podcast.key,
                                    title: podcast.value.firstOrNull?.album ??
                                        podcast.value.firstOrNull?.title ??
                                        podcast.value.firstOrNull.toString(),
                                    audios: podcast.value,
                                    addPodcast: addPodcast,
                                    removePodcast: removePodcast,
                                    imageUrl: podcast
                                            .value.firstOrNull?.albumArtUrl ??
                                        podcast.value.firstOrNull?.imageUrl,
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
  }
}
