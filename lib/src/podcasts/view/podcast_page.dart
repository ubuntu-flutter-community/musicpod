import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:yaru/yaru.dart';

import '../../../build_context_x.dart';
import '../../../common.dart';
import '../../../constants.dart';
import '../../../data.dart';
import '../../../get.dart';
import '../../common/explore_online_popup.dart';
import '../../common/sliver_audio_page_control_panel.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../podcast_model.dart';
import 'sliver_podcast_page_list.dart';

class PodcastPage extends StatelessWidget with WatchItMixin {
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

    watchPropertyValue((LibraryModel m) => m.lastPositions?.length);
    watchPropertyValue((LibraryModel m) => m.downloadsLength);

    return YaruDetailPage(
      appBar: HeaderBar(
        adaptive: true,
        title: Text(title),
        leading: Navigator.canPop(context)
            ? const NavBackButton()
            : const SizedBox.shrink(),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: AudioPageHeader(
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
                      fit: BoxFit.fitHeight,
                      filterQuality: FilterQuality.medium,
                    ),
              label: audios?.firstWhereOrNull((e) => e.genre != null)?.genre ??
                  context.l10n.podcast,
              subTitle: audios?.firstOrNull?.artist,
              description: audios?.firstOrNull?.albumArtist,
              title: title,
            ),
          ),
          SliverAudioPageControlPanel(
            controlPanel: _PodcastPageControlPanel(
              audios: audios ?? {},
              pageId: pageId,
              title: title,
            ),
          ),
          SliverPodcastPageList(audios: audios ?? {}, pageId: pageId),
        ],
      ),
    );
  }
}

class _PodcastPageControlPanel extends StatelessWidget with WatchItMixin {
  const _PodcastPageControlPanel({
    required this.audios,
    required this.pageId,
    required this.title,
  });

  final Set<Audio> audios;
  final String pageId;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final libraryModel = getIt<LibraryModel>();

    final subscribed = libraryModel.podcastSubscribed(pageId);

    watchPropertyValue((LibraryModel m) => m.lastPositions?.length);
    watchPropertyValue((LibraryModel m) => m.downloadsLength);

    final checkingForUpdates =
        watchPropertyValue((PodcastModel m) => m.checkingForUpdates);
    final smallWindow = context.m.size.width < kMasterDetailBreakPoint;
    return Row(
      mainAxisAlignment:
          smallWindow ? MainAxisAlignment.center : MainAxisAlignment.start,
      children: [
        AvatarPlayButton(audios: audios, pageId: pageId),
        Padding(
          padding: const EdgeInsets.only(left: 10),
          child: IconButton(
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
                    } else if (audios.isNotEmpty) {
                      libraryModel.addPodcast(pageId, audios);
                    }
                  },
          ),
        ),
        ExploreOnlinePopup(text: title),
      ],
    );
  }
}

class PodcastPageTitle extends StatelessWidget with WatchItMixin {
  const PodcastPageTitle({
    super.key,
    required this.feedUrl,
    required this.title,
  });

  final String feedUrl;
  final String title;

  @override
  Widget build(BuildContext context) {
    watchPropertyValue((LibraryModel m) => m.podcastUpdatesLength);
    final visible = getIt<LibraryModel>().podcastUpdateAvailable(feedUrl);
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
