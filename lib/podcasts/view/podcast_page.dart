import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../common/data/audio.dart';
import '../../common/view/adaptive_container.dart';
import '../../common/view/audio_page_header.dart';
import '../../common/view/audio_page_header_html_description.dart';
import '../../common/view/avatar_play_button.dart';
import '../../common/view/explore_online_popup.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/icons.dart';
import '../../common/view/progress.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/search_button.dart';
import '../../common/view/side_bar_fall_back_image.dart';
import '../../common/view/sliver_audio_page_control_panel.dart';
import '../../common/view/theme.dart';
import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import '../../search/search_model.dart';
import '../../search/search_type.dart';
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

  final String? imageUrl;
  final String pageId;
  final String title;
  final List<Audio>? audios;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;

    watchPropertyValue((PlayerModel m) => m.lastPositions?.length);
    watchPropertyValue((LibraryModel m) => m.downloadsLength);
    final libraryModel = di<LibraryModel>();
    final audiosWithDownloads = audios
            ?.map((e) => e.copyWith(path: libraryModel.getDownload(e.url)))
            .toList() ??
        [];

    Future<void> onTap(text) async {
      await di<PodcastModel>()
          .init(updateMessage: context.l10n.updateAvailable);
      di<LibraryModel>().pushNamed(pageId: kSearchPageId);

      di<SearchModel>()
        ..setAudioType(AudioType.podcast)
        ..setSearchQuery(text)
        ..search();
    }

    return Scaffold(
      resizeToAvoidBottomInset: isMobile ? false : null,
      appBar: HeaderBar(
        adaptive: true,
        title: isMobile ? null : Text(title),
        actions: [
          Padding(
            padding: appBarSingleActionSpacing,
            child: SearchButton(
              onPressed: () {
                di<LibraryModel>().pushNamed(pageId: kSearchPageId);
                di<SearchModel>()
                  ..setAudioType(AudioType.podcast)
                  ..setSearchType(SearchType.podcastTitle);
              },
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: getAdaptiveHorizontalPadding(
                  constraints: constraints,
                  min: 40,
                ),
                sliver: SliverToBoxAdapter(
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
                    label: audios
                            ?.firstWhereOrNull((e) => e.genre != null)
                            ?.genre ??
                        context.l10n.podcast,
                    subTitle: audios?.firstOrNull?.artist,
                    description: AudioPageHeaderHtmlDescription(
                      description: audios?.firstOrNull?.albumArtist,
                      title: title,
                    ),
                    title: title,
                    onLabelTab: onTap,
                    onSubTitleTab: onTap,
                  ),
                ),
              ),
              SliverAudioPageControlPanel(
                controlPanel: _PodcastPageControlPanel(
                  audios: audiosWithDownloads,
                  pageId: pageId,
                  title: title,
                ),
              ),
              SliverPadding(
                padding: getAdaptiveHorizontalPadding(constraints: constraints),
                sliver: SliverPodcastPageList(
                  audios: audiosWithDownloads,
                  pageId: pageId,
                ),
              ),
            ],
          );
        },
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

  final List<Audio> audios;
  final String pageId;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = context.t;
    final libraryModel = di<LibraryModel>();

    final subscribed = libraryModel.isPodcastSubscribed(pageId);

    watchPropertyValue((PlayerModel m) => m.lastPositions?.length);
    watchPropertyValue((LibraryModel m) => m.downloadsLength);

    final checkingForUpdates =
        watchPropertyValue((PodcastModel m) => m.checkingForUpdates);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          tooltip: subscribed
              ? context.l10n.removeFromCollection
              : context.l10n.addToCollection,
          icon: checkingForUpdates
              ? const SideBarProgress()
              : Icon(
                  subscribed ? Iconz().removeFromLibrary : Iconz().addToLibrary,
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
        AvatarPlayButton(audios: audios, pageId: pageId),
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
    final visible = di<LibraryModel>().podcastUpdateAvailable(feedUrl);
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

class PodcastPageSideBarIcon extends StatelessWidget {
  const PodcastPageSideBarIcon({super.key, this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl == null) {
      return SideBarFallBackImage(
        child: Icon(Iconz().podcast),
      );
    }

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
}
