import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:music/app/common/audio_card.dart';
import 'package:music/app/common/audio_page.dart';
import 'package:music/app/common/constants.dart';
import 'package:music/app/player_model.dart';
import 'package:music/app/playlists/playlist_model.dart';
import 'package:music/app/podcasts/podcast_model.dart';
import 'package:music/app/podcasts/podcast_search_field.dart';
import 'package:music/data/audio.dart';
import 'package:music/data/countries.dart';
import 'package:music/l10n/l10n.dart';
import 'package:podcast_search/podcast_search.dart';
import 'package:provider/provider.dart';
import 'package:yaru_icons/yaru_icons.dart';
import 'package:yaru_widgets/yaru_widgets.dart';

class PodcastsPage extends StatelessWidget {
  const PodcastsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<PodcastModel>();
    final playerModel = context.watch<PlayerModel>();
    final playlistModel = context.watch<PlaylistModel>();
    final theme = Theme.of(context);

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
      grid = const SizedBox.shrink();
    } else {
      grid = GridView.builder(
        padding: kGridPadding,
        itemCount: model.chartsPodcasts!.length,
        gridDelegate: kImageGridDelegate,
        itemBuilder: (context, index) {
          final podcast = model.chartsPodcasts!.elementAt(index);
          final starred = playlistModel.playlists
              .containsKey(podcast.first.metadata?.album);
          return AudioCard(
            imageUrl: podcast.first.imageUrl,
            onPlay: () => playerModel.startPlaylist(podcast),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return AudioPage(
                      sort: false,
                      showTrack: false,
                      likeButton: YaruIconButton(
                        icon: Icon(
                          starred ? YaruIcons.star_filled : YaruIcons.star,
                        ),
                        onPressed: starred
                            ? () => playlistModel
                                .removePlaylist(podcast.first.metadata!.album!)
                            : () {
                                playlistModel.addPlaylist(
                                  podcast.first.metadata!.album!,
                                  podcast,
                                );
                              },
                      ),
                      imageUrl: podcast.first.imageUrl,
                      title: const PodcastSearchField(),
                      deletable: false,
                      audioPageType: AudioPageType.albumList,
                      editableName: false,
                      audios: podcast,
                      pageName: podcast.first.metadata?.album ??
                          podcast.first.metadata?.title ??
                          podcast.first.name ??
                          '',
                    );
                  },
                ),
              );
            },
          );
        },
      );
    }

    var textStyle = Theme.of(context)
        .textTheme
        .bodyLarge
        ?.copyWith(fontWeight: FontWeight.w100);
    var buttonStyle = TextButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
      ),
    );

    var controlPanel = Padding(
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
                model.podcastGenre.id,
                style: textStyle,
              ),
              itemBuilder: (context) {
                return [
                  for (final genre in model.sortedGenres)
                    PopupMenuItem(
                      value: genre,
                      child: Text(genre.id),
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
              title: PodcastSearchField(
                onPlay: playerModel.startPlaylist,
              ),
            ),
            body: page,
          ),
        ),
        if (model.searchQuery?.isNotEmpty == true)
          MaterialPage(
            child: YaruDetailPage(
              appBar: YaruWindowTitleBar(
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
                            padding: const EdgeInsets.all(kYaruPagePadding),
                            gridDelegate: kImageGridDelegate,
                            children:
                                List.generate(30, (index) => const AudioCard())
                                    .toList(),
                          )
                        : model.podcastSearchResult!.isEmpty
                            ? Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(50),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Text(
                                        '🐣🎙🎧❓',
                                        style: TextStyle(fontSize: 40),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        context.l10n.noPodcastFound,
                                        style: theme.textTheme.headlineLarge
                                            ?.copyWith(
                                          fontWeight: FontWeight.w100,
                                          color: theme.colorScheme.onSurface,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : GridView(
                                padding: const EdgeInsets.all(kYaruPagePadding),
                                gridDelegate: kImageGridDelegate,
                                children: [
                                  for (final Set<Audio> group
                                      in model.podcastSearchResult!)
                                    AudioCard(
                                      imageUrl: group.firstOrNull?.imageUrl,
                                      onPlay: () =>
                                          playerModel.startPlaylist(group),
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (context) {
                                              final starred = playlistModel
                                                  .playlists
                                                  .containsKey(
                                                group.first.metadata?.album,
                                              );
                                              return AudioPage(
                                                sort: false,
                                                showTrack: false,
                                                imageUrl: group.first.imageUrl,
                                                likeButton: YaruIconButton(
                                                  icon: Icon(
                                                    starred
                                                        ? YaruIcons.star_filled
                                                        : YaruIcons.star,
                                                  ),
                                                  onPressed: starred
                                                      ? () => playlistModel
                                                              .removePlaylist(
                                                            group
                                                                .first
                                                                .metadata!
                                                                .album!,
                                                          )
                                                      : () {
                                                          playlistModel
                                                              .addPlaylist(
                                                            group
                                                                .first
                                                                .metadata!
                                                                .album!,
                                                            group,
                                                          );
                                                        },
                                                ),
                                                title:
                                                    const PodcastSearchField(),
                                                deletable: false,
                                                audioPageType:
                                                    AudioPageType.albumList,
                                                editableName: false,
                                                audios: group,
                                                pageName: group.first.metadata
                                                        ?.album ??
                                                    '',
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    )
                                ],
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
