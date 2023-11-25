import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common.dart';
import '../../constants.dart';
import '../../data.dart';
import '../../podcasts.dart';
import '../globals.dart';
import '../../l10n.dart';
import '../library/library_model.dart';

class PodcastsCollectionBody extends StatelessWidget {
  const PodcastsCollectionBody({
    super.key,
    required this.isOnline,
    required this.startPlaylist,
    required this.onTapText,
    required this.addPodcast,
    required this.removePodcast,
  });

  final bool isOnline;
  final Future<void> Function(Set<Audio>, String) startPlaylist;
  final void Function(String text) onTapText;
  final void Function(String, Set<Audio>) addPodcast;
  final void Function(String) removePodcast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subs = context.select((LibraryModel m) => m.podcasts);
    final updates = context.select((LibraryModel m) => m.podcastUpdates);
    final updatesLength =
        context.select((LibraryModel m) => m.podcastUpdates.length);
    final updatesOnly = context.select((PodcastModel m) => m.updatesOnly);
    final subsLength = context.select((LibraryModel m) => m.podcastsLength);
    final setUpdatesOnly = context.read<PodcastModel>().setUpdatesOnly;
    var libraryModel = context.read<LibraryModel>();
    final subscribed = libraryModel.podcastSubscribed;
    final removeUpdate = libraryModel.removePodcastUpdate;

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
                  ChoiceChip(
                    selected: updatesOnly,
                    onSelected: (v) => setUpdatesOnly(v),
                    label: Text(context.l10n.newEpisodes),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              Expanded(
                child: GridView.builder(
                  padding: gridPadding,
                  itemCount: updatesOnly ? updatesLength : subsLength,
                  gridDelegate: imageGridDelegate,
                  itemBuilder: (context, index) {
                    final podcast = updatesOnly
                        ? subs.entries
                            .where((e) => updates.contains(e.key))
                            .elementAt(index)
                        : subs.entries.elementAt(index);

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
                        style: updates.contains(podcast.key)
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
                          noConfirm:
                              podcast.value.length < kAudioQueueThreshHold,
                          message: podcast.value.length.toString(),
                          run: () => startPlaylist(
                            podcast.value,
                            podcast.key,
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
                              onTextTap: ({
                                required audioType,
                                required text,
                              }) =>
                                  onTapText(text),
                              addPodcast: addPodcast,
                              removePodcast: removePodcast,
                              imageUrl:
                                  podcast.value.firstOrNull?.albumArtUrl ??
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
