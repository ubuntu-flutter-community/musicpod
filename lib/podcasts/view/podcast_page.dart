import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:watch_it/watch_it.dart';
import 'package:yaru/yaru.dart';

import '../../app/view/music_pod_scaffold.dart';
import '../../common/data/audio.dart';
import '../../common/view/adaptive_container.dart';
import '../../common/view/audio_filter.dart';
import '../../common/view/audio_page_header.dart';
import '../../common/view/audio_page_header_html_description.dart';
import '../../common/view/avatar_play_button.dart';
import '../../common/view/explore_online_popup.dart';
import '../../common/view/header_bar.dart';
import '../../common/view/icons.dart';
import '../../common/view/safe_network_image.dart';
import '../../common/view/search_button.dart';
import '../../common/view/sliver_audio_page_control_panel.dart';
import '../../common/view/theme.dart';
import '../../constants.dart';
import '../../extensions/build_context_x.dart';
import '../../l10n/l10n.dart';
import '../../library/library_model.dart';
import '../../player/player_model.dart';
import '../../search/search_model.dart';
import '../../search/search_type.dart';
import '../../settings/settings_model.dart';
import '../podcast_model.dart';
import 'podcast_refresh_button.dart';
import 'podcast_reorder_button.dart';
import 'podcast_replay_button.dart';
import 'podcast_sub_button.dart';
import 'podcast_timer_button.dart';
import 'sliver_podcast_page_list.dart';

class PodcastPage extends StatefulWidget with WatchItStatefulWidgetMixin {
  const PodcastPage({
    super.key,
    this.imageUrl,
    required this.feedUrl,
    this.preFetchedEpisodes,
    required this.title,
  });

  final String? imageUrl;

  /// The feedUrl
  final String feedUrl;
  final String title;
  final List<Audio>? preFetchedEpisodes;

  @override
  State<PodcastPage> createState() => _PodcastPageState();
}

class _PodcastPageState extends State<PodcastPage> {
  @override
  void initState() {
    super.initState();
    final libraryModel = di<LibraryModel>();
    if (!libraryModel.isPageInLibrary(widget.feedUrl)) return;

    final episodes =
        widget.preFetchedEpisodes ?? libraryModel.podcasts[widget.feedUrl];

    if (episodes == null || episodes.isEmpty) return;

    Future.delayed(const Duration(milliseconds: 500)).then(
      (_) {
        final episodesWithDownloads = episodes
            .map((e) => e.copyWith(path: libraryModel.getDownload(e.url)))
            .toList();
        di<PodcastModel>().update(
          oldPodcasts: {
            widget.feedUrl: episodesWithDownloads,
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final episodes = widget.preFetchedEpisodes ??
        watchPropertyValue((LibraryModel m) => m.podcasts[widget.feedUrl]);
    watchPropertyValue((PlayerModel m) => m.lastPositions?.length);
    watchPropertyValue((LibraryModel m) => m.downloadsLength);

    final libraryModel = di<LibraryModel>();
    if (watchPropertyValue(
      (LibraryModel m) => m.showPodcastAscending(widget.feedUrl),
    )) {
      sortListByAudioFilter(
        audioFilter: AudioFilter.year,
        audios: episodes ?? [],
      );
    }
    final episodesWithDownloads = (episodes ?? [])
        .map((e) => e.copyWith(path: libraryModel.getDownload(e.url)))
        .toList();

    return MusicPodScaffold(
      appBar: HeaderBar(
        adaptive: true,
        actions: [
          Padding(
            padding: appBarSingleActionSpacing,
            child: SearchButton(
              onPressed: () {
                di<LibraryModel>().push(pageId: kSearchPageId);
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
          return RefreshIndicator(
            onRefresh: () async => di<PodcastModel>().update(
              oldPodcasts: {widget.feedUrl: episodesWithDownloads},
            ),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: getAdaptiveHorizontalPadding(
                    constraints: constraints,
                    min: 40,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: AudioPageHeader(
                      image: widget.imageUrl == null
                          ? null
                          : _PodcastPageImage(imageUrl: widget.imageUrl),
                      label: episodesWithDownloads
                              .firstWhereOrNull((e) => e.genre != null)
                              ?.genre ??
                          context.l10n.podcast,
                      subTitle: episodesWithDownloads.firstOrNull?.artist,
                      description:
                          episodesWithDownloads.firstOrNull?.albumArtist == null
                              ? null
                              : AudioPageHeaderHtmlDescription(
                                  description: episodesWithDownloads
                                      .firstOrNull!.albumArtist!,
                                  title: widget.title,
                                ),
                      title: widget.title,
                      onLabelTab: (text) => _onGenreTap(
                        context: context,
                        text: text,
                      ),
                      onSubTitleTab: (text) => _onArtistTap(
                        context: context,
                        text: text,
                      ),
                    ),
                  ),
                ),
                SliverAudioPageControlPanel(
                  controlPanel: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: space(
                      children: [
                        if (!isMobile)
                          PodcastReplayButton(audios: episodesWithDownloads),
                        const PodcastTimerButton(),
                        PodcastSubButton(
                          audios: episodesWithDownloads,
                          pageId: widget.feedUrl,
                        ),
                        AvatarPlayButton(
                          audios: episodesWithDownloads,
                          pageId: widget.feedUrl,
                        ),
                        PodcastRefreshButton(pageId: widget.feedUrl),
                        PodcastReorderButton(feedUrl: widget.feedUrl),
                        if (!isMobile) ExploreOnlinePopup(text: widget.title),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: getAdaptiveHorizontalPadding(
                    min: isMobile ? 0 : 15,
                    constraints: constraints,
                  ).copyWith(bottom: kYaruPagePadding),
                  sliver: SliverPodcastPageList(
                    audios: episodesWithDownloads,
                    pageId: widget.feedUrl,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _onArtistTap({
    required BuildContext context,
    required String text,
  }) async {
    await di<PodcastModel>().init(updateMessage: context.l10n.updateAvailable);
    di<LibraryModel>().push(pageId: kSearchPageId);
    di<SearchModel>()
      ..setAudioType(AudioType.podcast)
      ..setSearchQuery(text)
      ..search();
  }

  Future<void> _onGenreTap({
    required BuildContext context,
    required String text,
  }) async {
    await di<PodcastModel>().init(updateMessage: context.l10n.updateAvailable);
    final genres =
        di<SearchModel>().getPodcastGenres(di<SettingsModel>().usePodcastIndex);

    final genreOrNull = genres.firstWhereOrNull(
      (e) =>
          e.localize(context.l10n).toLowerCase() == text.toLowerCase() ||
          e.id.toLowerCase() == text.toLowerCase() ||
          e.name.toLowerCase() == text.toLowerCase(),
    );
    di<LibraryModel>().push(pageId: kSearchPageId);
    if (genreOrNull != null) {
      di<SearchModel>()
        ..setAudioType(AudioType.podcast)
        ..setPodcastGenre(genreOrNull)
        ..search();
    } else {
      if (context.mounted) {
        _onArtistTap(context: context, text: text);
      }
    }
  }
}

class _PodcastPageImage extends StatelessWidget {
  const _PodcastPageImage({
    required this.imageUrl,
  });

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    var safeNetworkImage = SafeNetworkImage(
      fallBackIcon: Icon(
        Iconz.podcast,
        size: 80,
        color: theme.hintColor,
      ),
      errorIcon: Icon(
        Iconz.podcast,
        size: 80,
        color: theme.hintColor,
      ),
      url: imageUrl,
      fit: BoxFit.fitHeight,
      filterQuality: FilterQuality.medium,
    );

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      child: safeNetworkImage,
      onTap: () => showDialog(
        context: context,
        builder: (context) => SimpleDialog(
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: safeNetworkImage,
            ),
          ],
        ),
      ),
    );
  }
}
