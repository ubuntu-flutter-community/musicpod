import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../data.dart';
import '../l10n/l10n.dart';
import '../library/library_model.dart';
import 'podcast_model.dart';

class PodcastPage extends StatelessWidget {
  const PodcastPage({
    super.key,
    this.imageUrl,
    required this.pageId,
    this.audios,
    required this.title,
  });

  static Widget createIcon({
    required BuildContext context,
    String? imageUrl,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox(
        width: sideBarImageSize,
        height: sideBarImageSize,
        child: SafeNetworkImage(
          url: imageUrl,
          fit: BoxFit.fitHeight,
          filterQuality: FilterQuality.medium,
          fallBackIcon: Icon(
            Iconz().podcast,
            size: sideBarImageSize,
          ),
          errorIcon: Icon(
            Iconz().podcast,
            size: sideBarImageSize,
          ),
        ),
      ),
    );
  }

  final String? imageUrl;
  final String pageId;
  final String title;
  final Set<Audio>? audios;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final genre = audios?.firstWhereOrNull((e) => e.genre != null)?.genre;

    return Consumer(
      builder: (context, ref, _) {
        final libraryModel = ref.read(libraryModelProvider);

        final subscribed = libraryModel.podcastSubscribed(pageId);

        ref.watch(libraryModelProvider.select((p) => p.lastPositions?.length));
        ref.watch(libraryModelProvider.select((p) => p.downloadsLength));

        final checkingForUpdates =
            ref.watch(podcastModelProvider.select((p) => p.checkingForUpdates));
        return AudioPage(
          showAudioTileHeader: false,
          audioPageType: AudioPageType.podcast,
          image: imageUrl == null
              ? null
              : SafeNetworkImage(
                  fallBackIcon: Icon(
                    Iconz().podcast,
                    size: 80,
                    color: theme.hintColor,
                  ),
                  errorIcon: Icon(
                    Iconz().podcast,
                    size: 80,
                    color: theme.hintColor,
                  ),
                  url: imageUrl,
                  fit: BoxFit.fitWidth,
                  filterQuality: FilterQuality.medium,
                ),
          headerLabel: genre ?? context.l10n.podcast,
          headerTitle: title,
          headerSubtile: audios?.firstOrNull?.artist,
          headerDescription: audios?.firstOrNull?.albumArtist,
          audios: audios,
          pageId: pageId,
          title: Text(title),
          controlPanelTitle: Text(title),
          controlPanelButton: Row(
            children: [
              IconButton(
                tooltip: subscribed
                    ? context.l10n.removeFromCollection
                    : context.l10n.addToCollection,
                icon: checkingForUpdates
                    ? const SideBarProgress()
                    : Icon(
                        subscribed
                            ? Iconz().removeFromLibrary
                            : Iconz().addToLibrary,
                        color: subscribed
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                onPressed: checkingForUpdates
                    ? null
                    : () {
                        if (subscribed) {
                          libraryModel.removePodcast(pageId);
                        } else if (audios?.isNotEmpty == true) {
                          libraryModel.addPodcast(pageId, audios!);
                        }
                      },
              ),
              StreamProviderRow(
                spacing: const EdgeInsets.only(right: 10),
                text: title,
              ),
            ],
          ),
        );
      },
    );
  }
}

class PodcastPageTitle extends StatelessWidget {
  const PodcastPageTitle({
    super.key,
    required this.feedUrl,
    required this.title,
  });

  final String feedUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) {
        ref.watch(libraryModelProvider.select((p) => p.podcastUpdatesLength));
        final visible =
            ref.read(libraryModelProvider).podcastUpdateAvailable(feedUrl);
        return Badge(
          backgroundColor: context.t.colorScheme.primary,
          isLabelVisible: visible,
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.only(right: visible ? 10 : 0),
            child: Text(title),
          ),
        );
      },
    );
  }
}
