import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:musicpod/app/common/audio_card.dart';
import 'package:musicpod/app/common/audio_page.dart';
import 'package:musicpod/app/common/constants.dart';
import 'package:musicpod/app/common/no_search_result_page.dart';
import 'package:musicpod/app/common/safe_network_image.dart';
import 'package:musicpod/app/player_model.dart';
import 'package:musicpod/app/playlists/playlist_model.dart';
import 'package:musicpod/app/podcasts/podcast_model.dart';
import 'package:musicpod/app/podcasts/podcast_search_field.dart';
import 'package:musicpod/app/podcasts/podcast_search_page.dart';
import 'package:musicpod/data/audio.dart';
import 'package:musicpod/data/countries.dart';
import 'package:musicpod/data/podcast_genre.dart';
import 'package:musicpod/l10n/l10n.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PodcastsPage extends StatefulWidget {
  const PodcastsPage({
    super.key,
    this.showWindowControls = true,
  });

  final bool showWindowControls;

  @override
  State<PodcastsPage> createState() => _PodcastsPageState();
}

class _PodcastsPageState extends State<PodcastsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<PodcastModel>().init(
            WidgetsBinding.instance.window.locale.countryCode?.toUpperCase(),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PodcastModel>();
    final startPlaylist = context.read<PlayerModel>().startPlaylist;
    final theme = Theme.of(context);
    final podcastSubscribed = context.read<PlaylistModel>().podcastSubscribed;
    final removePodcast = context.read<PlaylistModel>().removePodcast;
    final addPodcast = context.read<PlaylistModel>().addPodcast;
    final textStyle =
        theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w100);
    final buttonStyle = TextButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    );

    final light = theme.brightness == Brightness.light;

    final fallBackLoadingIcon = Shimmer.fromColors(
      baseColor: light ? kShimmerBaseLight : kShimmerBaseDark,
      highlightColor: light ? kShimmerHighLightLight : kShimmerHighLightDark,
      child: YaruBorderContainer(
        color: light ? kShimmerBaseLight : kShimmerBaseDark,
        height: 250,
        width: 250,
      ),
    );

    Widget grid;
    if (model.chartsPodcasts == null) {
      grid = GridView(
        gridDelegate: kImageGridDelegate,
        padding: kGridPadding,
        children: List.generate(30, (index) => Audio())
            .map((e) => const AudioCard())
            .toList(),
      );
    } else if (model.chartsPodcasts!.isEmpty == true) {
      grid = NoSearchResultPage(
        message: context.l10n.noPodcastChartsFound,
      );
    } else {
      grid = GridView.builder(
        padding: kGridPadding,
        itemCount: model.chartsPodcasts!.length,
        gridDelegate: kImageGridDelegate,
        itemBuilder: (context, index) {
          final podcast = model.chartsPodcasts!.elementAt(index);

          final image = SafeNetworkImage(
            fallBackIcon: fallBackLoadingIcon,
            url: podcast.firstOrNull?.imageUrl,
            fit: BoxFit.contain,
          );

          return AudioCard(
            image: image,
            onPlay: () {
              startPlaylist(podcast);
            },
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    final subscribed = podcast.first.album == null
                        ? false
                        : podcastSubscribed(podcast.first.album!);

                    return AudioPage(
                      audioPageType: AudioPageType.podcast,
                      showWindowControls: widget.showWindowControls,
                      sort: false,
                      showTrack: false,
                      controlPageButton: YaruIconButton(
                        icon: Icon(
                          YaruIcons.rss,
                          color: subscribed ? theme.primaryColor : null,
                        ),
                        onPressed: subscribed
                            ? () => removePodcast(
                                  podcast.first.album!,
                                )
                            : () {
                                addPodcast(
                                  podcast.first.album!,
                                  podcast,
                                );
                              },
                      ),
                      image: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          10,
                        ),
                        child: SafeNetworkImage(
                          fallBackIcon: SizedBox(
                            width: 200,
                            child: Center(
                              child: Icon(
                                YaruIcons.music_note,
                                size: 80,
                                color: theme.hintColor,
                              ),
                            ),
                          ),
                          url: podcast.first.imageUrl,
                          fit: BoxFit.fitWidth,
                          filterQuality: FilterQuality.medium,
                        ),
                      ),
                      title: const PodcastSearchField(),
                      deletable: false,
                      editableName: false,
                      audios: podcast,
                      pageId: podcast.first.album ??
                          podcast.first.title ??
                          podcast.toString(),
                    );
                  },
                ),
              );
            },
          );
        },
      );
    }

    final controlPanel = Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20, top: 20),
      child: Row(
        children: [
          Text(
            model.searchQuery?.isNotEmpty == true
                ? 'Search:     "${model.searchQuery!}"'
                : 'Top 10 Charts:',
            style: textStyle,
          ),
          const SizedBox(
            width: 10,
          ),
          if (model.searchQuery == null || model.searchQuery!.isEmpty)
            YaruPopupMenuButton<PodcastGenre>(
              style: buttonStyle,
              onSelected: (value) {
                model.podcastGenre = value;
                model.loadCharts();
              },
              initialValue: model.podcastGenre,
              child: Text(
                model.podcastGenre.localize(context.l10n),
                style: textStyle,
              ),
              itemBuilder: (context) {
                return [
                  for (final genre in model.sortedGenres)
                    PopupMenuItem(
                      value: genre,
                      child: Text(genre.localize(context.l10n)),
                    )
                ];
              },
            ),
          const SizedBox(
            width: 10,
          ),
          YaruPopupMenuButton<Country>(
            style: buttonStyle,
            onSelected: (value) {
              model.country = value;
              model.loadCharts();
            },
            initialValue: model.country,
            child: Text(
              codeToCountry[model.country.countryCode] ??
                  model.country.countryCode,
              style: textStyle,
            ),
            itemBuilder: (context) {
              return [
                for (final c in model.sortedCountries)
                  PopupMenuItem(
                    value: c,
                    child: Text(codeToCountry[c.countryCode] ?? c.countryCode),
                  )
              ];
            },
          ),
        ],
      ),
    );

    final page = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        controlPanel,
        const Divider(
          height: 0,
        ),
        const SizedBox(
          height: 15,
        ),
        Expanded(child: grid),
      ],
    );

    return Navigator(
      pages: [
        MaterialPage(
          child: YaruDetailPage(
            appBar: YaruWindowTitleBar(
              style: widget.showWindowControls
                  ? YaruTitleBarStyle.normal
                  : YaruTitleBarStyle.undecorated,
              title: const PodcastSearchField(),
            ),
            body: page,
          ),
        ),
        if (model.searchQuery?.isNotEmpty == true)
          MaterialPage(
            child: YaruDetailPage(
              appBar: YaruWindowTitleBar(
                style: widget.showWindowControls
                    ? YaruTitleBarStyle.normal
                    : YaruTitleBarStyle.undecorated,
                title: const PodcastSearchField(),
                leading: YaruBackButton(
                  style: YaruBackButtonStyle.rounded,
                  onPressed: () {
                    model.setSearchQuery('');
                    Navigator.maybePop(context);
                  },
                ),
              ),
              body: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  controlPanel,
                  const Divider(
                    height: 0,
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Expanded(
                    child: model.podcastSearchResult == null
                        ? GridView(
                            padding: kGridPadding,
                            gridDelegate: kImageGridDelegate,
                            children: List.generate(
                              30,
                              (index) => AudioCard(
                                image: fallBackLoadingIcon,
                              ),
                            ).toList(),
                          )
                        : model.podcastSearchResult!.isEmpty
                            ? NoSearchResultPage(
                                message: context.l10n.noPodcastFound,
                              )
                            : PodcastSearchPage(
                                showWindowControls: widget.showWindowControls,
                              ),
                  )
                ],
              ),
            ),
          )
      ],
      onPopPage: (route, result) => route.didPop(result),
    );
  }
}
