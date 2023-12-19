import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../build_context_x.dart';
import '../../common.dart';
import '../../data.dart';
import '../l10n/l10n.dart';
import '../library/library_model.dart';

class PodcastPage extends StatelessWidget {
  const PodcastPage({
    super.key,
    this.onTextTap,
    this.imageUrl,
    required this.pageId,
    this.audios,
    this.subscribed = true,
    required this.removePodcast,
    required this.addPodcast,
    required this.title,
  });

  static Widget createIcon({
    required BuildContext context,
    String? imageUrl,
    required bool isOnline,
  }) {
    if (!isOnline) {
      return Icon(Iconz().offline);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(5),
      child: SizedBox(
        width: masterTrailingSize,
        height: masterTrailingSize,
        child: SafeNetworkImage(
          url: imageUrl,
          fit: BoxFit.fitHeight,
          filterQuality: FilterQuality.medium,
          fallBackIcon: Icon(
            Iconz().podcast,
          ),
          errorIcon: Icon(
            Iconz().podcast,
          ),
        ),
      ),
    );
  }

  final void Function(String feedUrl) removePodcast;
  final void Function(String feedUrl, Set<Audio> audios) addPodcast;
  final void Function({
    required String text,
    required AudioType audioType,
  })? onTextTap;
  final String? imageUrl;
  final String pageId;
  final String title;
  final Set<Audio>? audios;
  final bool subscribed;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final genre = audios?.firstWhereOrNull((e) => e.genre != null)?.genre;

    context.select((LibraryModel m) => m.lastPositions?.length);
    context.select((LibraryModel m) => m.downloadsLength);

    return AudioPage(
      showAudioTileHeader: false,
      onTextTap: onTextTap,
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
      controlPanelButton: IconButton(
        tooltip: subscribed
            ? context.l10n.removeFromCollection
            : context.l10n.addToCollection,
        icon: subscribed
            ? Icon(
                Iconz().removeFromLibrary,
                color: theme.colorScheme.primary,
              )
            : Icon(
                Iconz().addToLibrary,
                color: theme.colorScheme.onSurface,
              ),
        onPressed: () {
          if (subscribed) {
            removePodcast(pageId);
          } else if (audios?.isNotEmpty == true) {
            addPodcast(pageId, audios!);
          }
        },
      ),
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
    context.select((LibraryModel m) => m.podcastUpdatesLength);
    final visible =
        context.read<LibraryModel>().podcastUpdateAvailable(feedUrl);
    return Badge(
      backgroundColor: context.t.colorScheme.primary,
      isLabelVisible: visible,
      alignment: Alignment.centerRight,
      child: Padding(
        padding: EdgeInsets.only(right: visible ? 10 : 0),
        child: Text(title),
      ),
    );
  }
}
